from flask import request, Response, session
import requests
import re
from urllib.parse import urlparse

from . import proxy_bp
from const import Const 
from proxy_platform.firefly import modify_response_content
from global_config import GlobalConfig
from log_config import setup_logging, log_request_info, log_response_info

logger, _ = setup_logging(__name__)

# 加载保存的配置
GlobalConfig.load_config()

# 创建一个Session对象用于保持会话
requests_session = requests.Session()

def is_absolute_url(url):
    """检查是否为绝对路径URL"""
    return bool(urlparse(url).netloc)

def get_ingress_path():
    """从请求头获取 ingress path，优先使用保存的值"""
    if GlobalConfig.INGRESS_PATH:
        return GlobalConfig.INGRESS_PATH
    return request.headers.get('X-Ingress-Path', '')

def convert_url_to_proxy(url, proxy_host, ingress_path):
    """将目标URL转换为代理URL，添加ingress前缀"""
    if not url:
        return url
    
    parsed_url = urlparse(url)
    
    if ingress_path in url:
        return url
        
    if parsed_url.netloc:
        path = parsed_url.path
        if parsed_url.query:
            path += f"?{parsed_url.query}"
        if parsed_url.fragment:
            path += f"#{parsed_url.fragment}"
        return f"{proxy_host}{ingress_path}/{path.lstrip('/')}"
    else:
        return f"{ingress_path}/{url.lstrip('/')}"

def get_port_from_referer():
    """从 Referer 头中获取端口信息"""
    referer = request.headers.get('Referer', '')
    if referer:
        match = re.search(r':(\d+)', referer)
        if match:
            return f":{match.group(1)}"
    return GlobalConfig.PROXY_PORT

@proxy_bp.before_request
def before_request():
    """请求前中间件"""
    log_request_info(logger, request)

@proxy_bp.after_request
def after_request(response):
    """响应后中间件"""
    return log_response_info(logger, response)

@proxy_bp.route("/", defaults={'path': ''}, methods=["GET", "POST"])
@proxy_bp.route("/<path:path>", methods=["GET", "POST"])
def proxy(path):
    """代理请求并修改返回的内容"""
    TARGET_URL = Const.get_target_url()
    ingress_path = get_ingress_path()
    host = request.headers.get('X-Forwarded-Host', request.host).split(':')[0]  
    port = get_port_from_referer()
    scheme = request.headers.get('X-Forwarded-Proto', request.scheme)
    
    GlobalConfig.init_proxy_host(scheme, host, port)
    if not GlobalConfig.INGRESS_PATH:
        GlobalConfig.init_ingress_path(ingress_path)
        
    proxy_host = GlobalConfig.PROXY_HOST if isinstance(GlobalConfig.PROXY_HOST, str) else ""
    proxy_port = GlobalConfig.PROXY_PORT if isinstance(GlobalConfig.PROXY_PORT, str) else ""
    proxy_base = proxy_host + proxy_port
    
    if path and ingress_path and path.startswith(ingress_path.lstrip('/')):
        path = path[len(ingress_path.lstrip('/')):].lstrip('/')
    
    url = f"{TARGET_URL}/{path}"
    
    preserve_headers = [
        'User-Agent', 'Accept', 'Accept-Language', 'Accept-Encoding',
        'X-Remote-User-Id', 'X-Remote-User-Name', 'X-Remote-User-Display-Name',
        'X-Forwarded-For', 'X-Real-Ip', 'X-Forwarded-Proto',
        'X-Forwarded-Host', 'X-Forwarded-Scheme',
        'X-Hass-Source', 'Cookie'
    ]
    headers = {k:v for k,v in request.headers if k.lower() not in ('host', 'cookie')}
    
    data = None
    if request.method == 'POST':
        if request.form:
            data = request.form.to_dict()
            if '_csrf_token' in session:
                data['_token'] = session['_csrf_token']
        else:
            data = request.get_data()

    resp = requests_session.request(
        method=request.method,
        url=url,
        headers=headers,
        data=data,
        cookies=request.cookies,
        allow_redirects=False
    )
    
    if resp.status_code in [301, 302, 303, 307, 308]:
        location = resp.headers.get('Location')
        if location and ingress_path:
            new_location = convert_url_to_proxy(location, proxy_base, ingress_path)
            logger.info(f"重定向地址转换: {location} -> {new_location}")
            resp.headers['Location'] = new_location

    response_headers = []
    for k, v in resp.headers.items():
        if k.lower() not in ('transfer-encoding', 'content-encoding', 'content-length', 'set-cookie'):
            if k.lower() == 'location' and ingress_path:
                v = convert_url_to_proxy(v, proxy_base, ingress_path)
            response_headers.append((k, v))

    content = resp.content
    content_type = resp.headers.get('Content-Type', '')
    
    if content and content_type:
        if isinstance(content, bytes):
            try:
                content = content.decode('utf-8')
            except UnicodeDecodeError:
                return Response(content, status=resp.status_code, headers=response_headers)
        
        content = modify_response_content(content, content_type)
        content = content.encode() if isinstance(content, str) else content

    response = Response(content, status=resp.status_code, headers=response_headers)
    
    if 'Set-Cookie' in resp.headers:
        cookies = [resp.headers['Set-Cookie']] if isinstance(resp.headers['Set-Cookie'], str) else resp.headers['Set-Cookie']
        for cookie in cookies:
            if 'path=/' in cookie:
                cookie = cookie.replace('path=/', f'path={ingress_path}/')
            response.headers.add('Set-Cookie', cookie)

    logger.info(f"代理请求完成 <- 状态码: {resp.status_code}")
    return response
