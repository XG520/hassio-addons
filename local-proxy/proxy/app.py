import os
import sys
from flask import Flask
import logging

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT_DIR)

# 导入其他模块
from apps.proxy import proxy_bp
from const import Const
from log_config import setup_logging, log_file

def create_app():
    app = Flask(__name__)
    app.secret_key = 'your-secret-key'
    app.register_blueprint(proxy_bp)
    return app

def init_logging():
    werkzeug_logger = logging.getLogger('werkzeug')
    werkzeug_logger.setLevel(logging.INFO)
    file_handler = logging.FileHandler(log_file)
    werkzeug_logger.addHandler(file_handler)

if __name__ == '__main__':
    logger, _ = setup_logging(__name__)
    logger.info("代理服务启动中...")
    logger.info(f"日志保存到: {log_file}")
    
    init_logging()
    app = create_app()
    app.run(host="0.0.0.0", port=Const.get_listen_port(), debug=True)
