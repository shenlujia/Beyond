#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import shutil

src = '/Users/zzz/Downloads/Beyond/ai_workspace/.trae/skills/wechat-html-to-markdown/scripts/cli.py'
dst = '/Users/zzz/Downloads/Beyond/skills/wechat-html-to-markdown/scripts/cli.py'

shutil.copy2(src, dst)
print(f'已同步 cli.py 到: {dst}')
print('完成！')
