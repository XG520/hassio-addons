import os
import json

class GlobalConfig:
    PROXY_HOST = None  
    INGRESS_PATH = None 
    PROXY_PORT = None  
    CONFIG_FILE = os.path.join(os.path.dirname(__file__), 'config.json')

    @classmethod
    def init_proxy_host(cls, scheme, host, port=None):
        """初始化代理主机信息"""
        cls.PROXY_HOST = f"{scheme}://{host}"
        if port and port != ':':
            cls.PROXY_PORT = port
            cls.PROXY_HOST

    @classmethod
    def init_ingress_path(cls, path):
        """初始化并持久化ingress路径"""
        if not cls.INGRESS_PATH:
            cls.INGRESS_PATH = path
            cls._save_config()

    @classmethod
    def _save_config(cls):
        """只保存 ingress_path 到文件"""
        config = {
            'ingress_path': cls.INGRESS_PATH
        }
        with open(cls.CONFIG_FILE, 'w') as f:
            json.dump(config, f)

    @classmethod
    def load_config(cls):
        """只加载 ingress_path"""
        if os.path.exists(cls.CONFIG_FILE):
            try:
                with open(cls.CONFIG_FILE, 'r') as f:
                    config = json.load(f)
                cls.INGRESS_PATH = config.get('ingress_path')
                return True
            except:
                return False
        return False
