#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
公众号信息管理模块
用于记录和管理常用公众号的信息
只存储 nickname 和 fakeid
"""

import json
import os
from typing import Dict, Optional, Any

ACCOUNTS_FILE = os.path.join(os.path.dirname(__file__), 'accounts.json')

DEFAULT_ACCOUNTS = {
    "晚点LatePost": {
        "nickname": "晚点LatePost",
        "fakeid": "MzU3Mjk1OTQ0Ng=="
    }
}


def load_accounts() -> Dict[str, Any]:
    """
    加载公众号信息
    
    Returns:
        公众号信息字典
    """
    if os.path.exists(ACCOUNTS_FILE):
        try:
            with open(ACCOUNTS_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    
    return DEFAULT_ACCOUNTS.copy()


def save_accounts(accounts: Dict[str, Any]) -> bool:
    """
    保存公众号信息
    
    Args:
        accounts: 公众号信息字典
        
    Returns:
        是否保存成功
    """
    try:
        with open(ACCOUNTS_FILE, 'w', encoding='utf-8') as f:
            json.dump(accounts, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"保存失败: {e}")
        return False


def get_account(name: str) -> Optional[Dict[str, Any]]:
    """
    获取指定公众号的信息
    
    Args:
        name: 公众号名称
        
    Returns:
        公众号信息，未找到返回 None
    """
    accounts = load_accounts()
    return accounts.get(name)


def get_fakeid(name: str) -> Optional[str]:
    """
    获取指定公众号的 fakeid
    
    Args:
        name: 公众号名称
        
    Returns:
        fakeid，未找到返回 None
    """
    account = get_account(name)
    return account.get('fakeid') if account else None


def add_account(name: str, account_info: Dict[str, Any]) -> bool:
    """
    添加或更新公众号信息
    
    Args:
        name: 公众号名称（作为键）
        account_info: 公众号完整信息
        
    Returns:
        是否添加成功
    """
    accounts = load_accounts()
    accounts[name] = account_info
    return save_accounts(accounts)


def remove_account(name: str) -> bool:
    """
    删除公众号信息
    
    Args:
        name: 公众号名称
        
    Returns:
        是否删除成功
    """
    accounts = load_accounts()
    if name in accounts:
        del accounts[name]
        return save_accounts(accounts)
    return False


def list_accounts() -> Dict[str, Any]:
    """
    列出所有公众号信息
    
    Returns:
        公众号信息字典
    """
    return load_accounts()


def print_accounts():
    """
    打印所有公众号信息
    """
    accounts = load_accounts()
    print(f"已记录 {len(accounts)} 个公众号:\n")
    for name, info in accounts.items():
        print(f"  {name}:")
        print(f"    昵称: {info.get('nickname', '')}")
        print(f"    fakeid: {info.get('fakeid', '')}")
        if info.get('alias'):
            print(f"    别名: {info.get('alias', '')}")
        if info.get('signature'):
            print(f"    简介: {info.get('signature', '')}")
        print()


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) == 1:
        print_accounts()
    elif sys.argv[1] == 'list':
        print_accounts()
    elif sys.argv[1] == 'get' and len(sys.argv) > 2:
        name = sys.argv[2]
        account = get_account(name)
        if account:
            print(f"{name}:")
            print(f"  昵称: {account.get('nickname', '')}")
            print(f"  fakeid: {account.get('fakeid', '')}")
        else:
            print(f"未找到公众号: {name}")
    elif sys.argv[1] == 'fakeid' and len(sys.argv) > 2:
        name = sys.argv[2]
        fakeid = get_fakeid(name)
        if fakeid:
            print(fakeid)
        else:
            print(f"未找到公众号: {name}")
    elif sys.argv[1] == 'add' and len(sys.argv) >= 5:
        name = sys.argv[2]
        nickname = sys.argv[3]
        fakeid = sys.argv[4]
        if add_account(name, nickname, fakeid):
            print(f"添加成功: {name}")
        else:
            print("添加失败")
    elif sys.argv[1] == 'remove' and len(sys.argv) > 2:
        name = sys.argv[2]
        if remove_account(name):
            print(f"删除成功: {name}")
        else:
            print(f"未找到公众号: {name}")
    else:
        print("使用方法:")
        print("  python3 accounts.py                    - 列出所有公众号")
        print("  python3 accounts.py list               - 列出所有公众号")
        print("  python3 accounts.py get <name>         - 获取指定公众号信息")
        print("  python3 accounts.py fakeid <name>      - 获取指定公众号的 fakeid")
        print("  python3 accounts.py add <name> <nickname> <fakeid>")
        print("  python3 accounts.py remove <name>      - 删除指定公众号")
