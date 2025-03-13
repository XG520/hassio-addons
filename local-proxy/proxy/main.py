import sys
import os
import logging

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'libs'))

from flask import Flask, request, Response, session
import requests
import re
from urllib.parse import urlparse
from .const import TARGET_URL, LISTEN_PORT
from .platform.firefly import modify_response_content
from .global_config import GlobalConfig
from .log_config import setup_logging, log_request_info, log_response_info

# 初始化日志
logger, log_file = setup_logging(__name__)

# 加载保存的配置
GlobalConfig.load_config()

app = Flask(__name__)
app.secret_key = 'your-secret-key'

# 创建一个Session对象用于保持会话
requests_session = requests.Session()

def is_absolute_url(url):
    """检查是否为绝对路径URL"""
    return bool(urlparse(url).netloc)

def get_ingress_path():
    """从请求头获取 ingress path，优先使用保存的值"""
    if GlobalConfig.INGRESS_PATH:
        return GlobalConfig.INGRESS_PATH
        
    ingress_path = request.headers.get('X-Ingress-Path', '')
    # logger.debug(f"从请求头获取到 Ingress 路径: {ingress_path}")
    return ingress_path

def convert_url_to_proxy(url, proxy_host, ingress_path):
    """将目标URL转换为代理URL，添加ingress前缀"""
    if not url:
        return url
    
    parsed_url = urlparse(url)
    
    # 如果已经包含了ingress路径，则不再添加
    if ingress_path in url:
        return url
        
    if parsed_url.netloc:  # 处理绝对URL
        path = parsed_url.path
        if parsed_url.query:
            path += f"?{parsed_url.query}"
        if parsed_url.fragment:
            path += f"#{parsed_url.fragment}"
        # 总是使用请求头中的主机和端口
        return f"{proxy_host}{ingress_path}/{path.lstrip('/')}"
    else:
        # 相对路径直接添加ingress前缀
        return f"{ingress_path}/{url.lstrip('/')}"

@app.before_request
def before_request():
    """请求前中间件"""
    log_request_info(logger, request)

@app.after_request
def after_request(response):
    """响应后中间件"""
    return log_response_info(logger, response)

def get_port_from_referer():
    """从 Referer 头中获取端口信息"""
    referer = request.headers.get('Referer', '')
    if referer:
        match = re.search(r':(\d+)', referer)
        if match:
            port = f":{match.group(1)}"
            return port
    return GlobalConfig.PROXY_PORT 

@app.route("/", defaults={'path': ''}, methods=["GET", "POST"])
@app.route("/<path:path>", methods=["GET", "POST"])
def proxy(path):
    """代理请求并修改返回的内容"""
    # 从请求头获取ingress路径和主机信息
    ingress_path = get_ingress_path()
    host = request.headers.get('X-Forwarded-Host', request.host).split(':')[0]  
    port = get_port_from_referer() 
    scheme = request.headers.get('X-Forwarded-Proto', request.scheme)
    
    GlobalConfig.init_proxy_host(scheme, host, port)
    if not GlobalConfig.INGRESS_PATH:
        GlobalConfig.init_ingress_path(ingress_path)
    
    proxy_base = GlobalConfig.PROXY_HOST + GlobalConfig.PROXY_PORT
    # logger.info(f"请求主机：{GlobalConfig.PROXY_HOST}")
    # logger.info(f"代理服务器基础URL: {proxy_base}")
    
    # 如果有ingress路径，从请求路径中移除它
    if path and ingress_path and path.startswith(ingress_path.lstrip('/')):
        path = path[len(ingress_path.lstrip('/')):].lstrip('/')
    
    url = f"{TARGET_URL}/{path}"
    # logger.info(f"代理请求URL: {url}")
    
    # 保留重要的请求头
    preserve_headers = [
        'User-Agent', 'Accept', 'Accept-Language', 'Accept-Encoding',
        'X-Remote-User-Id', 'X-Remote-User-Name', 'X-Remote-User-Display-Name',
        'X-Forwarded-For', 'X-Real-Ip', 'X-Forwarded-Proto',
        'X-Forwarded-Host', 'X-Forwarded-Scheme',
        'X-Hass-Source', 'Cookie'
    ]
    headers = {k: v for k, v in request.headers.items() 
              if k in preserve_headers or k.lower().startswith('x-')}
    
    # # 记录请求信息
    # logger.info(f"\n{'='*50}\n请求信息:")
    # logger.info(f"请求方法: {request.method}")
    # logger.info(f"原始路径: {request.path}")
    # logger.info(f"请求参数: {dict(request.args)}")
    # logger.info(f"请求头: {dict(request.headers)}")
    # logger.info(f"请求Cookie: {request.cookies}")
    # if request.form:
    #     logger.info(f"表单数据: {dict(request.form)}")
    # if request.get_data():
    #     logger.info(f"请求体: {request.get_data()}")
    
    # 准备请求头
    headers = {k:v for k,v in request.headers if k.lower() not in ('host', 'cookie')}
    # logger.info(f"发送到目标服务器的请求头: {headers}")
    
    # 处理请求数据
    data = None
    if request.method == 'POST':
        if request.form:
            data = request.form.to_dict()
            if '_csrf_token' in session:
                data['_token'] = session['_csrf_token']
        else:
            data = request.get_data()

    # logger.info(f"发送到目标服务器的请求数据: {data if data else '无'}")
    resp = requests_session.request(
        method=request.method,
        url=url,
        headers=headers,
        data=data,
        cookies=request.cookies,
        allow_redirects=False
    )
    
    # 处理重定向响应
    if resp.status_code in [301, 302, 303, 307, 308]:
        location = resp.headers.get('Location')
        if location and ingress_path:
            new_location = convert_url_to_proxy(location, proxy_base, ingress_path)
            logger.info(f"重定向地址转换: {location} -> {new_location}")
            resp.headers['Location'] = new_location

    # 处理响应头
    response_headers = []
    for k, v in resp.headers.items():
        if k.lower() not in ('transfer-encoding', 'content-encoding', 'content-length', 'set-cookie'):
            if k.lower() == 'location' and ingress_path:
                v = convert_url_to_proxy(v, proxy_base, ingress_path)
            response_headers.append((k, v))

    content = resp.content
    content_type = resp.headers.get('Content-Type', '')
    
    #html处理
    if content and content_type:
        if isinstance(content, bytes):
            try:
                content = content.decode('utf-8')
            except UnicodeDecodeError:
                return Response(content, status=resp.status_code, headers=response_headers)
        
        content = modify_response_content(content, content_type)
        content = content.encode() if isinstance(content, str) else content

    response = Response(content, status=resp.status_code, headers=response_headers)
    
    # 处理Cookie
    if 'Set-Cookie' in resp.headers:
        cookies = [resp.headers['Set-Cookie']] if isinstance(resp.headers['Set-Cookie'], str) else resp.headers['Set-Cookie']
        for cookie in cookies:
            if 'path=/' in cookie:
                cookie = cookie.replace('path=/', f'path={ingress_path}/')
            response.headers.add('Set-Cookie', cookie)

    # logger.info(f"{'='*50}")
    logger.info(f"代理请求完成 <- 状态码: {resp.status_code}")
    return response

if __name__ == "__main__":
    logger.info("代理服务启动中...")
    logger.info(f"日志保存到: {log_file}")
    app.run(host="0.0.0.0", port=LISTEN_PORT, debug=True)
else:
    file_handler = logging.FileHandler(log_file)
    werkzeug_logger = logging.getLogger('werkzeug')
    werkzeug_logger.setLevel(logging.INFO)
    werkzeug_logger.addHandler(file_handler)
