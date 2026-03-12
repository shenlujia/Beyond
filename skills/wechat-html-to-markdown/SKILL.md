---
name: "wechat_html_to_markdown"
description: "将微信公众号HTML文章转换为Markdown格式。当输入wechat_html_to_markdown时，解析author标签并将raw文件夹中的HTML文件转换为对应名称的MD文件，存储到output文件夹中的作者同名文件夹。"
---

# WeChat HTML to Markdown

## 功能描述

此技能用于将微信公众号文章的 HTML 文件转换为 Markdown 格式。它会：

1. 读取 raw 文件夹中的所有 HTML 文件
2. HTML 文件名去除后缀后的字符串记为 `filename`
3. 解析 HTML 文件中的 author 标签，临时存储为 `author`
4. 提取 `img_list_indicator_wrp` 中的图片（只包含 https 开头的图片地址）
5. 从 JavaScript 代码中提取 `div class`等于`rich_media_content` 后面的 section 部分内容，记为`content`
6. 递归解析`content`中的所有实际内容，`<p>`标签内的文本作为一段
7. 将每个 HTML 文件转换为对应的 Markdown 文件
8. 将转换后的 Markdown 文件保存到 output 文件夹中的 `x` 文件夹（以作者名称命名）

## 调用方式

当用户输入 `wechat_html_to_markdown` 时，此技能会被触发，自动执行转换过程。

## 转换特点

- 支持标题、段落、粗体、斜体等基本格式转换
- 支持链接和图片的转换
- 支持彩色文本转换
- 智能合并连续的加粗标签
- 双源内容提取（同时支持rich_media_content和content_noencode）
- 支持多种HTML结构（section标签和p标签）

## 示例

1. 将微信公众号文章的 HTML 文件放入 raw 文件夹
2. 输入 `wechat_html_to_markdown` 命令
3. 转换后的 Markdown 文件会出现在 output 文件夹中的作者同名文件夹中