---
name: "wechat_html_to_markdown"
description: "微信公众号文章下载和转换工具，包含四个子能力：1) 根据公众号名字获取公众号id，并记录到缓存中；2) 获取特定公众号文章列表；3) 下载特定公众号文章到临时文件夹中，以 html 格式；4) 基于子能力2和子能力3，下载特定公众号所有文章到目标文件夹，以 md 格式。"
---

# WeChat HTML to Markdown

## 子能力一：根据公众号名字获取公众号id，并记录到缓存中

### 功能描述

通过公众号名称查询公众号ID，需要从 https://down.mptext.top 获取 auth-key 进行鉴权，并将结果保存到 accounts.json 缓存中。

### 特点

- 根据公众号名称或关键字搜索
- 支持分页查询
- 返回公众号的 fakeid、别名、简介等信息
- 自动将公众号信息保存到 accounts.json 缓存中
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要查询并保存公众号ID时，此能力将被调用。

### 示例

1. 用户提供公众号名称如 "12306"
2. 技能调用 API 搜索公众号
3. 返回匹配的公众号列表
4. 将公众号信息保存到 accounts.json 中

---

## 子能力二：获取特定公众号文章列表

### 功能描述

批量获取公众号的所有文章，每次获取十篇，间隔3秒调用一次，将结果合并保存到docs文件夹中作者对应文件夹的articles.json文件中。需要从 https://down.mptext.top 获取 auth-key 进行鉴权。

### 优化特点

- **智能增量获取**：从索引0开始获取最新文章，自动检测与本地缓存的交集
- **基于字典的合并**：将本地缓存和新获取的文章都解析为以 aid 为 key 的字典，高效去重和合并
- **交集检测与合并**：当检测到新获取的文章与本地缓存有交集时，自动将本地缓存合并到新数据中
- **索引智能调整**：合并后索引调整为总文章数-1，继续获取剩余文章
- **临时回溯文件**：每次获取的数据都会保存到 skill 中的 tmp_files 文件夹，便于调试和数据恢复
- **按时间排序**：最终结果按创建时间降序排序，最新文章在前
- **支持从 accounts.json 中读取已保存的公众号 fakeid**
- **可自定义每次获取的文章数量（默认10篇）**
- **可自定义调用间隔（默认3秒）**
- **保存到 docs/作者名/articles.json**
- **使用 urllib 内置库，无需额外依赖**

### 工作流程

1. **读取本地缓存**：从 docs/作者名/articles.json 读取已有的文章列表，解析为字典 Y_dict（key 为 aid）
2. **开始获取**：索引从 0 开始，每次获取指定数量的文章（默认10篇）
3. **构建数据结构 X**：将新获取的文章解析为字典 X_dict（key 为 aid）
4. **交集检测**：检查 X_dict 中是否有文章的 aid 在 Y_dict 中存在
5. **合并数据**：如果有交集，将 Y_dict 中不在 X_dict 的文章合并到 X_dict 中
6. **调整索引**：新的索引 = X_dict 中的文章数 - 1
7. **保存回溯文件**：每次获取的数据保存到 tmp_files/articles_batch_N.json
8. **重复直到完成**：持续获取直到 API 返回的文章数少于请求数
9. **排序与保存**：将最终结果按时间降序排序后保存到 docs/作者名/articles.json

### 调用方式

当用户需要批量获取公众号所有文章列表时，此能力将被调用。

### 示例

1. 用户提供公众号名称如 "晚点LatePost"
2. 技能从 accounts.json 中获取 fakeid
3. 从索引 0 开始批量调用 API 获取文章
4. 自动检测与本地缓存的交集并合并
5. 合并所有文章并保存到 docs/晚点LatePost/articles.json

---

## 子能力三：下载特定公众号文章到临时文件夹中，以 html 格式

### 功能描述

下载微信公众号文章的 HTML 内容，保存到 skill 的 tmp_files 临时文件夹中。
**注意：此接口不需要 auth-key**

### 特点

- 直接从微信公众号获取文章 HTML 内容
- 保存到 skill 的 tmp_files 文件夹
- 自动使用文章标题作为文件名
- 提供下载状态反馈
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要下载微信公众号文章的 HTML 版本时，此能力将被调用。

### 示例

1. 用户提供公众号名称和文章链接
2. 技能下载文章 HTML 内容
3. 保存到 tmp_files/YYYYMMDD_标题_aid.html
4. 提供确认和文件路径

---

## 子能力四：基于子能力2和子能力3，下载特定公众号所有文章到目标文件夹，以 md 格式

### 功能描述

基于子能力二（获取文章列表）和子能力三（下载 HTML），批量下载特定公众号的所有文章，转换为 Markdown 格式并保存到目标文件夹。

### 工作流程

1. **检查文章是否已存在**：首先检查 docs/作者名/ 文件夹中是否已存在对应的 MD 文件
2. **检查 HTML 是否存在**：如果 MD 不存在，检查 tmp_files/ 中是否有对应的 HTML 文件
3. **下载 HTML（如果需要）**：如果 HTML 也不存在，从微信公众号下载 HTML 到 tmp_files/
4. **转换为 Markdown**：读取 HTML 文件，解析内容并转换为 Markdown 格式
5. **保存结果**：将转换后的 Markdown 文件保存到 docs/作者名/ 文件夹

### 特点

- **智能跳过**：如果 MD 文件已存在，直接跳过
- **增量转换**：如果 HTML 已存在，直接转换，不用重新下载
- **重复文章处理**：支持使用 appmsgid 作为后缀处理重复标题的文章
- **最终格式**：保存为 Markdown 格式，包含标题、作者、原文链接、内容等
- **输出目录**：保存到 docs/作者名/ 文件夹
- **临时文件**：HTML 保存到 skill 的 tmp_files/ 文件夹

### 命名规则

- **单篇文章**：`YYYYMMDD_标题.md`
- **重复文章**：`YYYYMMDD_标题_<appmsgid>.md`（使用 appmsgid 作为后缀）

### 调用方式

当用户需要批量下载并转换公众号所有文章为 Markdown 格式时，此能力将被调用。

### 示例

1. 用户提供公众号名称如 "周喆吾"
2. 技能从 docs/周喆吾/articles.json 读取文章列表
3. 检查每篇文章是否已存在 MD 文件
4. 对于缺失的文章，下载 HTML（如果需要）并转换为 Markdown
5. 将所有 Markdown 文件保存到 docs/周喆吾/ 文件夹

## 模块架构

代码已重构为以下更合理的模块结构：

### 1. api_client.py
- **功能**：统一的 API 客户端，整合所有 API 调用
- **主要类和函数**：
  - `APIClient` - 统一 API 客户端类
  - `search_account()` - 搜索公众号
  - `fetch_articles()` - 获取文章列表
  - `get_all_articles()` - 获取所有文章（分页）
  - `download_article()` - 下载文章内容

### 2. accounts.py
- **功能**：公众号信息管理模块
- **主要函数**：
  - `load_accounts()` - 加载公众号信息
  - `save_accounts()` - 保存公众号信息
  - `get_account()` - 获取指定公众号信息
  - `get_fakeid()` - 获取指定公众号的 fakeid
  - `add_account()` - 添加或更新公众号信息

### 3. downloader.py
- **功能**：通用 HTML 下载器
- **主要函数**：
  - `download_html()` - 从 URL 下载 HTML 文件
  - `extract_title()` - 从 HTML 提取标题
  - `sanitize_filename()` - 生成安全的文件名

### 4. html_parser.py
- **功能**：HTML 解析器，提取元数据和内容
- **主要函数**：
  - `extract_author()` - 提取作者信息
  - `extract_images()` - 提取图片列表
  - `get_rich_media_content()` - 提取 rich_media_content 内容
  - `extract_content_noencode()` - 提取 content_noencode 内容
  - `parse_with_stack()` - 使用栈解析嵌套的 section 标签

### 5. markdown_converter.py
- **功能**：HTML 到 Markdown 转换器
- **主要函数**：
  - `parse_inline_elements()` - 解析内联元素（颜色、图片、加粗、链接等）
  - `parse_content_to_markdown()` - 将内容解析为 Markdown 格式
  - `merge_consecutive_bold_spans()` - 合并连续的加粗 span 标签

### 6. cli.py
- **功能**：统一的命令行入口
- **主要命令**：
  - `download` - 下载 HTML 文件
  - `convert` - 转换 HTML 为 Markdown
  - `search` - 搜索公众号
  - `fetch-articles` - 获取文章列表
  - `fetch-all-articles` - 批量获取所有文章
  - `download-article` - 下载文章内容

### 7. config.py
- **功能**：配置文件，包含 API 端点和默认鉴权密钥

## 目录结构

### 项目目录
- `SKILL.md` - 技能主文档
- `references/` - 存放其他参考文档（MD 文件）
- `scripts/` - 存放所有 Python 脚本和配置文件
- `tmp_files/` - 存放中间临时文件（如批量获取的文章批次、临时 HTML 等）

### 最终输出目录
最终处理完成的文件会保存到项目根目录的 `docs/` 文件夹中：
- `docs/<作者名>/articles.json` - 该作者的所有文章列表
- `docs/<作者名>/all_names.json` - 该作者的所有文章标题列表
- `docs/<作者名>/<YYYYMMDD_标题>.md` - 单篇文章的 Markdown 格式
- `docs/<作者名>/<YYYYMMDD_标题_<appmsgid>>.md` - 重复文章的 Markdown 格式（使用 appmsgid 作为后缀）

## 开发规范

### 文件存放位置

- 非 SKILL.md 的其他 md 文件放到 `references/` 文件夹
- 所有脚本文件放到 `scripts/` 文件夹
- 中途产生的临时文件放到 `tmp_files/` 文件夹
