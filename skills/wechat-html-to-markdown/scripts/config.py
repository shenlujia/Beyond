#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
配置文件
"""

import os
import json

def get_auth_key_file_path():
    """获取 auth_key 存储文件路径"""
    skill_root = os.path.dirname(os.path.dirname(__file__))
    return os.path.join(skill_root, 'tmp_files', 'auth_key.json')

def get_stored_auth_key():
    """从 tmp_files 获取存储的 auth_key"""
    auth_key_file = get_auth_key_file_path()
    if os.path.exists(auth_key_file):
        try:
            with open(auth_key_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get('auth_key')
        except Exception:
            pass
    return None

def save_auth_key(auth_key: str):
    """将 auth_key 保存到 tmp_files"""
    auth_key_file = get_auth_key_file_path()
    os.makedirs(os.path.dirname(auth_key_file), exist_ok=True)
    with open(auth_key_file, 'w', encoding='utf-8') as f:
        json.dump({'auth_key': auth_key}, f, ensure_ascii=False, indent=2)

DEFAULT_AUTH_KEY = None

BASE_URL_ACCOUNT = 'https://down.mptext.top/api/public/v1/account'
BASE_URL_ARTICLE = 'https://down.mptext.top/api/public/v1/article'
BASE_URL_DOWNLOAD = 'https://down.mptext.top/api/public/v1/download'
