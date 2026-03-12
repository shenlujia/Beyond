---
name: "download-html"
description: "Downloads HTML files from URLs to the tmp_gen folder. Invoke when user provides a URL and wants to download the HTML file."
---

# HTML Downloader

This skill downloads HTML files from URLs and saves them to the tmp_gen folder.

## Features

- Downloads HTML content from any valid URL
- Saves files to the tmp_gen directory
- Handles common URL formats (http, https)
- Provides feedback about download status

## Usage

When user provides a URL and asks to download the HTML file, this skill will be invoked.

## Example

1. User provides a URL like "https://example.com/article"
2. Skill downloads the HTML content
3. Saves to tmp_download/article.html
4. Provides confirmation and file path
