---
name: "cl-html-to-txt"
description: "下载 HTML、解析 HTML 到 JSON 缓存、合并 JSON 为 TXT 文章"
---

# CL HTML to TXT

## 功能描述

此技能提供三个主要子能力：

### 1. 下载 HTML
- 如果没有额外描述，只下载当前链接
- 如果加了描述需要下载完整文章或所有页码，则下载所有关联的 HTML
- 支持自动检测总页数
- 文件命名规则：`{tid}_{page:06d}.html`（如 `7194307_000001.html`）
- 多页下载时，页面之间有 1 秒等待间隔
- **Cookie 自动保存**：首次使用时通过 `--cookies` 传入，后续自动从 `tmp_files/cookie.txt` 读取
- **本地缓存**：如果 HTML 文件已存在，自动跳过下载
- **参数校验**：多页下载时链接必须包含 `toread` 参数

### 2. 解析 HTML
- 解析 HTML 到 caches 中
- 如果不指定特定 HTML，则解析所有 HTML
- 保存为 JSON 格式，包含 title 和 tpc_content
- 支持新老文件名格式排序

### 3. 合并 JSON
- 将 JSON 合并为文章 TXT
- 按标题合并，相同标题的文章合并到同一个 TXT
- 自动去重
- TXT 文件名即标题

## 使用方法

### 1. 下载 HTML

```bash
# 单文件下载
python3 scripts/download_html.py --single --url "https://cb.u97kxr.info/htm_data/2603/20/7194178.html"

# 多页下载（自动检测总页数，首次使用需要传入 Cookie）
python3 scripts/download_html.py --url "https://cb.u97kxr.info/read.php?tid=7194307&toread=2&page={}" --cookies "your_cookies"

# 多页下载（后续使用，自动读取已保存的 Cookie）
python3 scripts/download_html.py --url "https://cb.u97kxr.info/read.php?tid=7194307&toread=2&page={}"

# 指定起始和结束页码
python3 scripts/download_html.py --url "https://cb.u97kxr.info/read.php?tid=7194307&toread=2&page={}" --start 1 --end 10 --cookies "your_cookies"
```

### 2. 解析 HTML

```bash
# 仅解析 HTML 到 JSON 缓存
python3 scripts/main.py parse

# 解析指定目录
python3 scripts/main.py parse --input my_htmls --cache my_caches
```

### 3. 合并 JSON

```bash
# 仅合并 JSON 到 TXT
python3 scripts/main.py merge

# 合并指定缓存目录
python3 scripts/main.py merge --cache my_caches --output my_output
```

### 4. 完整流程（从 URL 到 TXT）

如果传了链接，且有下载完整文章的描述，则按序调用所有子能力、最终生成 txt：

```bash
# 1. 下载所有 HTML
python3 scripts/download_html.py --url "https://cb.u97kxr.info/read.php?tid=7194307&toread=2&page={}" --cookies "your_cookies"

# 2. 解析所有 HTML 到 JSON 缓存
python3 scripts/main.py parse

# 3. 合并 JSON 为 TXT
python3 scripts/main.py merge

# 或者一条命令完成解析和合并
python3 scripts/main.py all
```

### 5. 单独执行某个子能力

```bash
# 仅解析 HTML 到 JSON 缓存
python3 scripts/main.py parse

# 仅合并 JSON 到 TXT
python3 scripts/main.py merge

# 自定义目录
python3 scripts/main.py all --input htmls --cache caches --output output
```

## 模块架构

### 1. scripts/download_html.py
- **功能**：下载 HTML 页面
- **主要函数**：
  - `extract_tid_and_page(url)` - 从 URL 提取 tid 和 page
  - `extract_filename_from_url(url)` - 从 URL 提取文件名
  - `extract_total_pages(html)` - 从 HTML 提取总页数
  - `download_page(url, cookie_str, output_path)` - 下载单个页面
  - `download_single_file(url, cookie_str, output_dir)` - 下载单个文件
  - `download_page_for_detect(url, cookie_str)` - 下载页面用于检测
  - `get_cookie_file_path()` - 获取 cookie 文件路径
  - `save_cookie(cookie_str)` - 保存 cookie 到临时文件
  - `load_cookie()` - 从临时文件读取 cookie
  - `main()` - 主函数

### 2. scripts/parser.py
- **功能**：负责解析 HTML 并提取结构化数据
- **主要函数**：
  - `extract_title(html)` - 从 HTML 提取标题
  - `extract_tpc_content(html)` - 提取 tpc_content 或 contpc 内容
  - `clean_html_tags(html)` - 清除 HTML 标签，优化 <br> 处理
  - `normalize_text(text)` - 规范化文本
  - `parse_html_to_structured(html)` - 将 HTML 解析为结构化数据
  - `sanitize_filename(title)` - 生成安全的文件名

### 3. scripts/main.py
- **功能**：主入口文件，解析、缓存和合并文章
- **主要函数**：
  - `get_sort_key(filename)` - 获取文件名排序键
  - `parse_and_save_to_cache(html_path, cache_dir)` - 解析单个 HTML 到缓存
  - `parse_all_to_cache(input_dir, cache_dir)` - 批量解析所有 HTML 到缓存
  - `merge_articles_by_title(cache_dir, output_dir)` - 按标题合并文章
  - `main()` - 主函数

## 输出格式

### 下载的 HTML 文件（tmp_files/htmls/）
- 单文件：保持原文件名（如 `7194178.html`）
- 多页：`{tid}_{page:06d}.html`（如 `7194307_000001.html`）

### 缓存文件（tmp_files/caches/）
- 文件名：与原 HTML 文件名相同，后缀改为 .json
- 格式：
  ```json
  {
    "title": "文章标题",
    "tpc_content": [
      [
        "第一行内容",
        "第二行内容"
      ],
      [
        "第二个 tpc_content 的第一行"
      ]
    ]
  }
  ```

### Cookie 文件（tmp_files/cookie.txt）
- 保存上次使用的 Cookie 字符串
- 下次使用时自动读取，无需重复输入

### 合并文件（tmp_output/）
- 文件名：从文章标题生成的安全文件名
- 内容：
  - 文章标题
  - 标题分隔线
  - 合并的文章内容（按顺序，去重）
  - 多个部分用分隔线分隔

## 目录结构

```
cl-html-to-txt/
├── tmp_output/          # 最终生成的 TXT 文章
├── references/          # 参考文档
│   └── README_DOWNLOAD.md
├── scripts/             # 脚本文件
│   ├── download_html.py # 下载 HTML
│   ├── main.py          # 主入口
│   └── parser.py        # HTML 解析
├── tmp_files/           # 临时文件
│   ├── htmls/           # 下载的 HTML 文件
│   ├── caches/          # JSON 缓存文件
│   └── cookie.txt       # Cookie 保存
└── SKILL.md             # 技能说明
```