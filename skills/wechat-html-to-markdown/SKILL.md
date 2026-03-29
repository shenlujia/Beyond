---
name: "wechat_html_to_markdown"
description: "集成了六个子能力：1) search-account：通过公众号名称查询公众号ID（需要auth-key鉴权）；2) fetch-articles：获取公众号文章列表（需要auth-key鉴权）；3) fetch-all-articles：批量获取公众号所有文章，每次获取十篇，间隔3秒调用一次，将结果合并到docs文件夹中作者对应文件夹中的articles.json（需要auth-key鉴权）；4) download-article：下载文章内容（支持HTML/Markdown/Text/JSON格式）；5) download-html：从URL下载HTML文件到tmp_gen文件夹；6) 将微信公众号HTML文章转换为Markdown格式，解析author标签并将HTML文件转换为对应名称的MD文件，存储到docs文件夹中的作者同名文件夹。"
---

# WeChat HTML to Markdown

## 子能力一：Search Account

### 功能描述

通过公众号名称查询公众号ID，需要从 https://down.mptext.top 获取 auth-key 进行鉴权。

### 特点

- 根据公众号名称或关键字搜索
- 支持分页查询
- 返回公众号的 fakeid、别名、简介等信息
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要查询公众号ID时，此能力将被调用。

### 示例

1. 用户提供公众号名称如 "12306"
2. 技能调用 API 搜索公众号
3. 返回匹配的公众号列表及 fakeid

---

## 子能力二：Fetch Articles

### 功能描述

获取公众号的历史文章列表，需要从 https://down.mptext.top 获取 auth-key 进行鉴权。

### 特点

- 根据公众号 fakeid 获取文章列表
- 支持分页查询（begin 和 size 参数）
- 返回文章标题、链接、作者、发布时间等信息
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要获取公众号文章列表时，此能力将被调用。

### 示例

1. 用户提供公众号 fakeid（通过 search-account 获取）
2. 技能调用 API 获取文章列表
3. 返回文章列表及详细信息

---

## 子能力三：Fetch All Articles

### 功能描述

批量获取公众号的所有文章，每次获取十篇，间隔3秒调用一次，将结果合并保存到docs文件夹中作者对应文件夹的articles.json文件中。需要从 https://down.mptext.top 获取 auth-key 进行鉴权。

### 特点

- 支持从 accounts.json 中读取已保存的公众号 fakeid
- 可自定义每次获取的文章数量（默认10篇）
- 可自定义调用间隔（默认3秒）
- 自动合并所有文章并保存为 JSON 格式
- 保存到 docs/作者名/articles.json
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要批量获取公众号所有文章时，此能力将被调用。

### 示例

1. 用户提供公众号名称如 "晚点LatePost"
2. 技能从 accounts.json 中获取 fakeid
3. 批量调用 API 获取所有文章（每次10篇，间隔3秒）
4. 合并所有文章并保存到 docs/晚点LatePost/articles.json

---

## 子能力四：Download Article

### 功能描述

下载微信公众号文章内容，支持 HTML、Markdown、Text、JSON 四种格式。
**注意：此接口不需要 auth-key**

### 特点

- 支持多种输出格式（html/markdown/text/json）
- 直接从微信公众号获取文章内容
- 可以保存到文件或直接输出
- 使用 urllib 内置库，无需额外依赖

### 调用方式

当用户需要下载微信公众号文章内容时，此能力将被调用。

### 示例

1. 用户提供文章链接
2. 选择输出格式（默认为 html）
3. 技能下载文章内容
4. 可以选择保存到文件或直接显示

---

## 子能力四：Download HTML

### 功能描述

从URL下载HTML文件并保存到tmp_gen文件夹。

### 特点

- 下载HTML内容从任何有效的URL
- 保存文件到tmp_gen目录
- 处理常见的URL格式（http, https）
- 提供下载状态反馈
- 自动从HTML内容中提取标题作为文件名

### 调用方式

当用户提供URL并要求下载HTML文件时，此能力将被调用。

### 示例

1. 用户提供URL如 "https://example.com/article"
2. 技能下载HTML内容
3. 保存到tmp_gen/article.html
4. 提供确认和文件路径

---

## 子能力六：WeChat HTML to Markdown

### 功能描述

此技能用于将微信公众号文章的 HTML 文件转换为 Markdown 格式。它会：

1. 读取 tmp_gen 或 raw 文件夹中的所有 HTML 文件
2. HTML 文件名去除后缀后的字符串记为 `filename`
3. 解析 HTML 文件中的 author 标签，临时存储为 `author`
4. 提取 `img_list_indicator_wrp` 中的图片（只包含 https 开头的图片地址）
5. 从 JavaScript 代码中提取 `div class`等于`rich_media_content` 后面的 section 部分内容，记为`content`
6. 递归解析`content`中的所有实际内容，`<p>`标签内的文本作为一段
7. 将每个 HTML 文件转换为对应的 Markdown 文件
8. 将转换后的 Markdown 文件保存到 docs 文件夹中的 `x` 文件夹（以作者名称命名）

### 调用方式

当用户输入 `wechat_html_to_markdown` 时，此技能会被触发，自动执行转换过程。

### 转换特点

- 支持标题、段落、粗体、斜体等基本格式转换
- 支持链接和图片的转换
- 支持彩色文本转换
- 智能合并连续的加粗标签
- 双源内容提取（同时支持rich_media_content和content_noencode）
- 支持多种HTML结构（section标签和p标签）

### 示例

1. 将微信公众号文章的 HTML 文件放入 tmp_gen 或 raw 文件夹
2. 输入 `wechat_html_to_markdown` 命令
3. 转换后的 Markdown 文件会出现在 docs 文件夹中的作者同名文件夹中

## 模块架构

代码已拆分为以下原子能力模块：

### 1. wechat_account_finder.py
- **功能**：通过公众号名称查询公众号ID
- **主要类和函数**：
  - `WeChatAccountFinder` - 公众号查询器类
  - `search_account(keyword, begin, size)` - 搜索公众号
  - `get_account_list(keyword, begin, size)` - 获取公众号列表
  - `find_account_by_name(name)` - 根据名称精确查找
  - `get_fakeid(name)` - 获取公众号fakeid
  - `search_wechat_account()` - 便捷函数
  - `get_wechat_account_fakeid()` - 便捷函数

### 2. article_fetcher.py
- **功能**：获取公众号文章列表
- **主要类和函数**：
  - `ArticleFetcher` - 文章列表获取器类
  - `fetch_articles(fakeid, begin, size)` - 获取文章列表
  - `get_all_articles(fakeid, max_count)` - 获取所有文章（支持分页）
  - `fetch_and_save_all_articles(fakeid, author_name, batch_size, interval, output_dir)` - 批量获取所有文章并保存
  - `fetch_wechat_articles()` - 便捷函数
  - `get_all_wechat_articles()` - 便捷函数
  - `fetch_and_save_all_wechat_articles()` - 批量获取并保存的便捷函数

### 3. article_downloader.py
- **功能**：下载微信公众号文章内容
- **主要类和函数**：
  - `ArticleDownloader` - 文章下载器类
  - `download(url, format)` - 下载文章内容
  - `download_html(url)` - 下载HTML格式
  - `download_markdown(url)` - 下载Markdown格式
  - `download_text(url)` - 下载纯文本格式
  - `download_json(url)` - 下载JSON格式
  - `download_wechat_article()` - 便捷函数
  - `save_article_to_file()` - 保存文章到文件

### 4. downloader.py
- **功能**：负责从URL下载HTML文件
- **主要函数**：
  - `download_html(url, output_dir)` - 下载HTML文件
  - `extract_title(html_content)` - 从HTML提取标题
  - `sanitize_filename(url, html_content)` - 生成安全的文件名

### 5. html_parser.py
- **功能**：负责解析HTML文件，提取各种元数据和内容
- **主要函数**：
  - `extract_author(html_content)` - 提取作者信息
  - `extract_images(html_content)` - 提取图片列表
  - `get_rich_media_content(html)` - 提取rich_media_content内容
  - `extract_content_noencode(html_content)` - 提取content_noencode内容
  - `parse_with_stack(content)` - 使用栈解析嵌套的section标签

### 6. markdown_converter.py
- **功能**：负责将HTML内容转换为Markdown格式
- **主要函数**：
  - `parse_inline_elements(text)` - 解析内联元素（颜色、图片、加粗、链接等）
  - `parse_content_to_markdown(content)` - 将内容解析为Markdown格式
  - `merge_consecutive_bold_spans(text)` - 合并连续的加粗span标签

### 7. main.py
- **功能**：主入口文件，协调各个模块
- **主要函数**：
  - `process_html_file(file_path)` - 处理单个HTML文件
  - `main_convert()` - 转换功能的主函数
  - `main_search_account()` - 搜索公众号功能的主函数
  - `main_fetch_articles()` - 获取文章列表功能的主函数
  - `main_fetch_all_articles()` - 批量获取所有文章并保存的主函数
  - `main_download_article()` - 下载文章功能的主函数
  - `main()` - 主函数，根据参数选择功能

## 目录结构

- `SKILL.md` - 技能主文档
- `references/` - 存放其他参考文档（MD 文件）
- `scripts/` - 存放所有 Python 脚本和配置文件
- `tmp_files/` - 存放临时文件

## 开发规范

### 文件存放位置

- 非 SKILL.md 的其他 md 文件放到 `references/` 文件夹
- 所有脚本文件放到 `scripts/` 文件夹
- 中途产生的临时文件放到 `tmp_files/` 文件夹