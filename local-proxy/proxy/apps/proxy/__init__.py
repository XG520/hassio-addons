from flask import Blueprint

proxy_bp = Blueprint('proxy', __name__)

from . import views
