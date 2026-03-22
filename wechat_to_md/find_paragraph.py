import re

with open('raw/一文搞懂拉达克暴乱的前因后果.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 找到rich_media_content
match = re.search(r'var msg_cdn_url = "[^"]*";\s*var rich_media_content = "(.*?)";', html, re.DOTALL)
if match:
    content = match.group(1)
    # 解码转义字符
    content = content.replace('&quot;', '"').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>')
    
    # 找到包含"一边是"的部分
    idx = content.find('一边是')
    if idx != -1:
        # 输出前后1000个字符
        print(content[max(0, idx-1000):idx+2000])
