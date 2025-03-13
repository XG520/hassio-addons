import os
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime 

class WatchdogFilter(logging.Filter):
    def filter(self, record):
        return not record.name.startswith('watchdog')

def setup_logging(app_name):
    """配置日志系统"""
    # 创建logs目录
    log_dir = os.path.join(os.path.dirname(__file__), 'logs')
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    # 配置日志文件
    log_file = os.path.join(log_dir, 'proxy.log')
    file_handler = RotatingFileHandler(
        log_file,
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5,
        encoding='utf-8'
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    file_handler.addFilter(WatchdogFilter())

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    console_handler.addFilter(WatchdogFilter())

    # 配置日志
    logging.basicConfig(
        level=logging.DEBUG,
        handlers=[console_handler, file_handler]
    )

    # 禁用watchdog日志
    logging.getLogger('watchdog').setLevel(logging.ERROR)

    # 配置werkzeug日志
    werkzeug_logger = logging.getLogger('werkzeug')
    werkzeug_logger.setLevel(logging.INFO)
    werkzeug_logger.addHandler(file_handler)

    logger = logging.getLogger(app_name)
    return logger, log_file

def log_request_info(logger, request):
    """记录请求信息"""
    # logger.info("\n" + "="*80)
    # logger.info("收到新请求:")
    # logger.info(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')}")
    # logger.info(f"客户端IP: {request.remote_addr}")
    # logger.info(f"请求方法: {request.method}")
    # logger.info(f"完整URL: {request.url}")
    # logger.info(f"请求路径: {request.path}")
    # logger.info(f"查询参数: {dict(request.args)}")
    
    # logger.info("\n请求头:")
    # for name, value in request.headers.items():
    #     logger.info(f"  {name}: {value}")
    
    # logger.info("\nCookie信息:")
    # for name, value in request.cookies.items():
    #     logger.info(f"  {name}: {value}")
    
    # if request.form:
        # logger.info("\n表单数据:")
        # for name, value in request.form.items():
        #     logger.info(f"  {name}: {value}")
    
    if request.data:
        # logger.info("\n请求体:")
        try:
            logger.info(f"  {request.data.decode()}")
        except:
            logger.info(f"  {request.data}")
    
    # logger.info("="*80)

def log_response_info(logger, response):
    """记录响应信息"""
    # logger.info("\n" + "="*80)
    # logger.info("发送响应:")
    # logger.info(f"状态码: {response.status_code}")
    
    # logger.info("\n响应头:")
    # for name, value in response.headers.items():
    #     logger.info(f"  {name}: {value}")
    
    if response.content_type == 'text/html':
        # logger.info("\n响应体预览(HTML):")
        try:
            preview = response.data.decode()[:500] + "..." if len(response.data) > 500 else response.data.decode()
            # logger.info(f"{preview}")
        except:
            logger.info("无法解码响应体")
    
    # logger.info("="*80 + "\n")
    return response
