import os

TARGET_URL = os.environ.get('TARGET_URL', 'http://127.0.0.1:8080')
LISTEN_PORT = int(os.environ.get('LISTEN_PORT', '777')) 
