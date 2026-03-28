# 下载 HTML 页面使用说明

## 下载单页

```bash
python3 scripts/download_html.py \
  --url "https://cb.u97kxr.info/read.php?tid=7187084&fpage=0&toread=2&page={}" \
  --start 1 \
  --end 1 \
  --cookies "ismob=0; 227c9_ck_info=%2F%09; 227c9_winduser=UwwEUlBbMFBRVwUMUQZRDAMJW1sBVAJWWAINUlJaB1dfBgdTUwtUaA%3D%3D; 227c9_groupid=8; 227c9_lastvisit=0%091774691578%09%2Fread.php%3Ftid%3D7187084%26fpage%3D0%26toread%3D2%26page%3D2"
```

## 下载多页（1-12页）

```bash
python3 scripts/download_html.py \
  --url "https://cb.u97kxr.info/read.php?tid=7187084&fpage=0&toread=2&page={}" \
  --start 1 \
  --end 12 \
  --cookies "ismob=0; 227c9_ck_info=%2F%09; 227c9_winduser=UwwEUlBbMFBRVwUMUQZRDAMJW1sBVAJWWAINUlJaB1dfBgdTUwtUaA%3D%3D; 227c9_groupid=8; 227c9_lastvisit=0%091774691578%09%2Fread.php%3Ftid%3D7187084%26fpage%3D0%26toread%3D2%26page%3D2"
```

## 参数说明

| 参数 | 说明 |
|------|------|
| `--url` | 基础 URL，`{}` 会被替换为页码 |
| `--start` | 起始页码（默认 1） |
| `--end` | 结束页码（默认 1） |
| `--cookies` | Cookie 字符串（可选，如果不提供则从 tmp_files/cookie.txt 读取） |
| `--output-dir` | 输出目录（默认 tmp_files/htmls） |
| `--single` | 单文件下载模式（不使用页码） |

## Cookie 说明

- 首次使用时需要通过 `--cookies` 参数传入 Cookie
- Cookie 会自动保存到 `tmp_files/cookie.txt`
- 后续使用时如果不提供 `--cookies` 参数，会自动从文件中读取
- 如果提供了新的 `--cookies` 参数，会更新保存的 Cookie

## 下载后解析

下载完成后，使用以下命令解析并合并：

```bash
# 解析 HTML 到 JSON
python3 scripts/main.py parse

# 合并 JSON 到 TXT
python3 scripts/main.py merge

# 或者一次性执行
python3 scripts/main.py all
```

## 注意事项

1. **Cookie 有效期**：Cookie 可能有有效期，如果下载失败请重新从浏览器获取最新的 Cookie
2. **网络问题**：如果遇到网络问题，可以分批下载（例如先下载 1-6 页，再下载 7-12 页）
3. **文件命名**：下载的文件会自动命名为 `{tid}_{page:06d}.html`，保持顺序（如 `7187084_000001.html`）
4. **下载间隔**：多页下载时，页面之间会有 1 秒等待间隔，避免请求过于频繁
5. **自动检测总页数**：如果不指定 --end 参数，会自动从第 1 页解析总页数