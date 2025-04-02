import os
class Const:
    TARGET_URL = "http://192.168.31.41:888"
    LISTEN_PORT = int(os.environ.get('LISTEN_PORT', '777')) 

    @classmethod
    def get_target_url(cls):
        """获取目标URL"""
        return cls.TARGET_URL
    @classmethod
    def get_listen_port(cls):
        """获取监听端口"""
        return cls.LISTEN_PORT
    @classmethod
    def set_target_url(cls, url):
        """设置目标URL"""
        cls.TARGET_URL = url
    @classmethod
    def set_listen_port(cls, port):
        """设置监听端口"""
        cls.LISTEN_PORT = port