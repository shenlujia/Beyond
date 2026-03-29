# 公众号信息管理使用指南

## 概述

`accounts.py` 模块用于记录和管理常用公众号的信息，支持添加、查询、删除等操作。

## 文件说明

- `accounts.py` - 公众号信息管理模块
- `accounts.json` - 公众号信息存储文件

## 使用方法

### 1. 列出所有公众号

```bash
python3 accounts.py
# 或
python3 accounts.py list
```

### 2. 获取指定公众号信息

```bash
python3 accounts.py get "晚点LatePost"
```

### 3. 获取指定公众号的 fakeid

```bash
python3 accounts.py fakeid "晚点LatePost"
```

### 4. 添加或更新公众号

```bash
python3 accounts.py add "公众号名称" "昵称" "fakeid" "别名" "简介" "备注"
```

示例：
```bash
python3 accounts.py add "晚点LatePost" "晚点LatePost" "MzA3NzAyMzMyMA==" "" "" "晚点LatePost 公众号"
```

### 5. 删除公众号

```bash
python3 accounts.py remove "公众号名称"
```

## 在 Python 代码中使用

```python
from accounts import load_accounts, get_account, get_fakeid, add_account

# 加载所有公众号
accounts = load_accounts()

# 获取指定公众号
account = get_account("晚点LatePost")
if account:
    print(f"昵称: {account['nickname']}")
    print(f"fakeid: {account['fakeid']}")

# 获取 fakeid
fakeid = get_fakeid("晚点LatePost")
if fakeid:
    print(f"fakeid: {fakeid}")

# 添加公众号
add_account(
    name="新公众号",
    nickname="新公众号",
    fakeid="Mzxxxxxxxxxx==",
    alias="",
    signature="",
    note="我的新公众号"
)
```

## 如何获取 fakeid

1. 使用 search 功能搜索公众号（需要有效的 auth-key）：
   ```bash
   python3 main.py search "公众号名称"
   ```

2. 从搜索结果中复制 fakeid

3. 使用 add 命令添加到 accounts.json
