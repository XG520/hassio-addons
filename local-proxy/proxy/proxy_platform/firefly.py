import re
from bs4 import BeautifulSoup
from urllib.parse import urlparse, urljoin
from global_config import GlobalConfig
from log_config import setup_logging
from const import Const
TARGET_URL = Const.get_target_url()

logger, log_file = setup_logging(__name__)

def parse_url(url):
    """解析完整/不完整URL"""
    if not re.match(r'^[a-zA-Z]+://', url):
        url = f'//{url}'
    
    parsed = urlparse(url)
    hostname = parsed.hostname or ''
    port = parsed.port or None
    
    if parsed.hostname and parsed.hostname.startswith('['):
        hostname = parsed.hostname[1:-1]
    
    return hostname

def modify_response_content(content, content_type):
    """根据内容类型修改响应内容"""
    if not content:
        return content

    if 'text/html' in content_type:
        return modify_html_content(content)
    elif 'text/css' in content_type:
        return modify_css_content(content)
    elif 'application/javascript' in content_type:
        return modify_js_content(content)
    else:
        return content

def modify_html_content(html_content):
    """修改HTML中的资源路径"""
    soup = BeautifulSoup(html_content, 'html.parser')
    ingress_path = GlobalConfig.INGRESS_PATH
    proxy_base = f"{GlobalConfig.PROXY_HOST}{GlobalConfig.PROXY_PORT}"

    # 处理各类资源标签
    for tag, attr in {
        "script": "src",
        "link": "href",
        "img": "src",
        "a": "href",
        "form": "action",
        "base": "href"
    }.items():
        for element in soup.find_all(tag):
            if attr in element.attrs:
                url = element[attr]
                if not url or url.startswith(('data:', 'javascript:', 'mailto:', '#', './')):
                    continue

                # 处理绝对URL
                if url.startswith(('http://', 'https://')):
                    parsed_url = urlparse(url)
                    proxy_parsed = urlparse(proxy_base)
                    logger.info(f"格式: {parse_url(parsed_url.netloc)} {parse_url(proxy_parsed.netloc)}")
                    
                    if (parse_url(parsed_url.netloc) == parse_url(proxy_parsed.netloc) 
                        or
                        parse_url(urlparse(TARGET_URL).netloc) == parse_url(parsed_url.netloc)
                    ):                    
                        path = parsed_url.path
                        if parsed_url.query:
                            path += f"?{parsed_url.query}"
                        if parsed_url.fragment:
                            path += f"#{parsed_url.fragment}"
                        element[attr] = f"{proxy_base}{ingress_path}/{path.lstrip('/')}"
                else:
                    # 只处理以 / 开头的相对路径
                    if url.startswith('/'):
                        element[attr] = f"{ingress_path}/{url.lstrip('/')}"

# 处理内联样式中的url()
    for script in soup.find_all('script'):
        if script.string:
            # 处理绝对 URL
            script.string = re.sub(
                r'''(var\s+[\w_]+\s*=\s*["'])(https?://[^\s"']+)(["'])''',
                lambda m: f'{m.group(1)}{process_url(m.group(2), ingress_path, proxy_base)}{m.group(3)}',
                script.string
            )
            
            # 处理相对路径（以 / 开头）
            script.string = re.sub(
                r'''(var\s+[\w_]+\s*=\s*["'])(/[^\s"']*)(["'])''',
                lambda m: f'{m.group(1)}{ingress_path}/{m.group(2).lstrip("/")}{m.group(3)}',
                script.string
            )

    # 处理所有具有 data-path 属性的元素
    for element in soup.find_all(attrs={"data-path": True}):
        path = element["data-path"]
        if not path.startswith(('http://', 'https://')):
            element["data-path"] = f"{ingress_path}/{path.lstrip('/')}"

    # 处理内联样式中的url()
    for tag in soup.find_all(style=True):
        tag['style'] = modify_css_content(tag['style'])

    return str(soup)

def modify_css_content(css_content):
    """修改CSS中的资源路径"""
    ingress_path = GlobalConfig.INGRESS_PATH
    proxy_base = f"{GlobalConfig.PROXY_HOST}{GlobalConfig.PROXY_PORT}"
    
    # 替换所有 url() 中的路径
    def replace_url(match):
        url = match.group(1).strip('"\'')
        if url.startswith(('data:', 'http://', 'https://')):
            # 处理绝对URL
            parsed_url = urlparse(url)
            proxy_parsed = urlparse(proxy_base)
            if parsed_url.netloc == proxy_parsed.netloc:
                path = parsed_url.path
                return f'url({proxy_base}{ingress_path}/{path.lstrip("/")})'
            return f'url({url})'
        # 不处理 ./ 开头的相对路径
        elif url.startswith('/'):
            return f'url({ingress_path}/{url.lstrip("/")})'
        return f'url({url})'

    return re.sub(r'url\([\'"]?([^\)"\']+)[\'"]?\)', replace_url, css_content)

def modify_js_content(js_content):
    """修改JavaScript中的资源路径"""
    ingress_path = GlobalConfig.INGRESS_PATH
    proxy_base = f"{GlobalConfig.PROXY_HOST}{GlobalConfig.PROXY_PORT}"
    
    # 替换类似 "/build/assets/" 这样的路径
    def replace_path(match):
        url = match.group(1)
        if url.startswith(('http://', 'https://')):
            parsed_url = urlparse(url)
            proxy_parsed = urlparse(proxy_base)
            if parsed_url.netloc == proxy_parsed.netloc:
                path = parsed_url.path
                return f'"{proxy_base}{ingress_path}/{path.lstrip("/")}"'
            return f'"{url}"'
        # 只处理以 / 开头的相对路径
        elif url.startswith('/'):
            return f'"{ingress_path}/{url.lstrip("/")}"'
        return f'"{url}"'

    return re.sub(r'"([^"]+)"', replace_path, js_content)


def process_url(url, ingress_path, proxy_base):
    """统一处理 URL（适用于标签属性和 script 变量）"""
    if url.startswith(('http://', 'https://')):
        parsed_url = urlparse(url)
        proxy_parsed = urlparse(proxy_base)
        target_parsed = urlparse(TARGET_URL)
        
        if (
            parse_url(parsed_url.netloc) == parse_url(proxy_parsed.netloc)
            or parse_url(parsed_url.netloc) == parse_url(target_parsed.netloc)
        ):
            path = parsed_url.path
            if parsed_url.query:
                path += f"?{parsed_url.query}"
            if parsed_url.fragment:
                path += f"#{parsed_url.fragment}"
            return f"{proxy_base}{ingress_path}/{path.lstrip('/')}"
        else:
            return url
    elif url.startswith('/'):
        return f"{ingress_path}/{url.lstrip('/')}"
    else:
        return url
