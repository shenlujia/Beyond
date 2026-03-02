import os
import re

# 读取 HTML 文件
def read_html_file(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        return f.read()

# 提取 picture_page_info_list 中的图片

def extract_picture_page_info(html):
    picture_urls = []
    # 检查是否是全景式佛教巡礼归来文章
    if '全景式佛教巡礼归来' in html:
        # 尝试解析 img_list_indicator_wrp 元素
        img_list_match = re.search(r'img_list_indicator_wrp[^>]*>(.*?)</div>', html, re.DOTALL)
        if img_list_match:
            img_list_content = img_list_match.group(1)
            # 提取图片 URL
            img_urls = re.findall(r'https://[^"\']+', img_list_content)
            for img_url in img_urls:
                # 只添加有效的图片 URL，且必须是 https 开头
                if img_url.startswith('https://') and 'mmbiz.qpic.cn' in img_url and 'wx_fmt' in img_url:
                    # 避免重复添加相同的图片
                    if img_url not in picture_urls:
                        picture_urls.append(img_url)
        # 如果 img_list_indicator_wrp 不存在，回退到解析 window.picture_page_info_list
        if not picture_urls:
            # 提取 window.picture_page_info_list 中的所有图片
            img_urls = re.findall(r'cdn_url\s*:\s*["\']([^"\']+)["\']', html)
            for img_url in img_urls:
                # 处理 URL 中的转义字符
                img_url = img_url.replace('\\x26amp;', '&').replace('\\', '')
                # 只添加有效的图片 URL，且必须是 https 开头
                if img_url.startswith('https://') and 'mmbiz.qpic.cn' in img_url and 'wx_fmt' in img_url:
                    # 避免重复添加相同的图片
                    if img_url not in picture_urls:
                        picture_urls.append(img_url)
    return picture_urls

# 简单的 HTML 转 Markdown 函数
def html_to_markdown(html):
    # 提取标题
    title_match = re.search(r'<h1[^>]*>\s*([\s\S]*?)\s*</h1>', html)
    title = title_match.group(1) if title_match else ''
    # 清理标题中的 HTML 标签
    title = re.sub(r'<[^>]*>', '', title)
    
    # 从 JavaScript 中提取 content_noencode 部分
    content = ''
    # 尝试从 window.cgiDataNew 中提取 content_noencode
    # 使用字符串分割的方法，更可靠
    if 'content_noencode: JsDecode(' in html:
        # 找到 content_noencode 的开始位置
        start_idx = html.find('content_noencode: JsDecode(') + len('content_noencode: JsDecode(')
        # 找到第一个单引号
        quote_start = html.find("'", start_idx)
        if quote_start != -1:
            # 找到匹配的单引号，考虑转义的情况
            quote_end = quote_start + 1
            while quote_end < len(html):
                if html[quote_end] == "'" and html[quote_end - 1] != '\\':
                    break
                quote_end += 1
            if quote_end < len(html):
                encoded_content = html[quote_start + 1:quote_end]
                # 处理转义字符
                import codecs
                try:
                    content = codecs.escape_decode(encoded_content)[0].decode('utf-8')
                    # 移除作者介绍及其后面的内容
                    if '南七道' in content:
                        # 找到作者介绍的位置
                        author_pos = content.find('南七道')
                        if author_pos != -1:
                            # 找到作者介绍前的位置
                            content = content[:author_pos]
                except Exception as e:
                    print(f"解码错误: {e}")
                    content = encoded_content
    # 尝试从 HTML 标签中提取 content_noencode
    if not content:
        content_match = re.search(r'content_noencode[^>]*>([\s\S]*?)</div>', html, re.DOTALL)
        if content_match:
            content = content_match.group(1)
            # 移除作者介绍及其后面的内容
            if '南七道' in content:
                # 找到作者介绍的位置
                author_pos = content.find('南七道')
                if author_pos != -1:
                    # 找到作者介绍前的位置
                    content = content[:author_pos]
    
    # 提取 picture_page_info_list 中的图片
    picture_urls = extract_picture_page_info(html)
    
    # 组合标题和内容
    markdown = f'# {title}\n\n'
    
    # 添加 picture_page_info_list 中的图片
    if picture_urls:
        for img_url in picture_urls:
            markdown += f'![Image]({img_url})\n\n'
    
    # 处理内容
    if content:
        # 移除脚本和样式
        content = re.sub(r'<script[\s\S]*?</script>', '', content)
        content = re.sub(r'<style[\s\S]*?</style>', '', content)
        
        # 转换段落
        content = re.sub(r'<p[^>]*>([\s\S]*?)</p>', r'\1\n\n', content)
        
        # 转换粗体和斜体
        content = re.sub(r'<strong[^>]*>([\s\S]*?)</strong>', r'**\1**', content)
        content = re.sub(r'<b[^>]*>([\s\S]*?)</b>', r'**\1**', content)
        content = re.sub(r'<em[^>]*>([\s\S]*?)</em>', r'*\1*', content)
        content = re.sub(r'<i[^>]*>([\s\S]*?)</i>', r'*\1*', content)
        
        # 转换链接
        content = re.sub(r'<a[^>]*href="([^"]*)"[^>]*>([\s\S]*?)</a>', r'[\2](\1)', content)
        
        # 处理图片和下方的文案，使其显示在图片下方正中间
        # 查找包含图片和后续括号内容的模式
        content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*>\s*\(([^)]+)\)', r'![Image](\1)\n\n> \2', content)
        # 处理其他可能的图片格式
        content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*alt="([^"]*)"[^>]*>\s*\(([^)]+)\)', r'![\2](\1)\n\n> \3', content)
        # 处理没有文案的图片
        content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*alt="([^"]*)"[^>]*>', r'![\2](\1)', content)
        content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*>', r'![Image](\1)', content)
        
        # 处理Markdown中图片后紧跟括号内容的情况
        content = re.sub(r'(!\[.*?\]\([^)]+\))\(([^)]+)\)', r'\1\n\n> \2', content)
        
        # 转换列表
        def replace_ul(match):
            ul_content = match.group(1)
            items = re.findall(r'<li[^>]*>([\s\S]*?)</li>', ul_content)
            return '\n'.join([f'- {item}' for item in items]) + '\n\n'
        
        def replace_ol(match):
            ol_content = match.group(1)
            items = re.findall(r'<li[^>]*>([\s\S]*?)</li>', ol_content)
            return '\n'.join([f'{i+1}. {item}' for i, item in enumerate(items)]) + '\n\n'
        
        content = re.sub(r'<ul[^>]*>([\s\S]*?)</ul>', replace_ul, content)
        content = re.sub(r'<ol[^>]*>([\s\S]*?)</ol>', replace_ol, content)
        
        # 移除其他 HTML 标签
        content = re.sub(r'<[^>]*>', '', content)
        content = content.replace('&nbsp;', ' ')
        content = content.replace('&lt;', '<')
        content = content.replace('&gt;', '>')
        content = content.replace('&amp;', '&')
        
        # 清理空白
        content = re.sub(r'\n{3,}', '\n\n', content)
        content = content.strip()
        
        # 处理图片后紧跟括号内容的情况，使其显示在图片下方正中间
        content = re.sub(r'(!\[.*?\]\([^)]+\))\(([^)]+)\)', r'\1\n\n> \2', content)
        
        # 移除作者介绍及其后面的内容
        # 先检查是否有作者介绍部分
        if '南七道' in content:
            # 找到作者介绍的位置
            author_pos = content.find('\n南七道\n')
            if author_pos != -1:
                # 找到作者介绍前的分割线
                divider_pos = content.rfind('\n****\n', 0, author_pos)
                if divider_pos != -1:
                    content = content[:divider_pos]
                else:
                    content = content[:author_pos]
        
        markdown += content
    
    # 清理最终结果
    markdown = re.sub(r'\n{3,}', '\n\n', markdown)
    markdown = markdown.strip()
    # 确保标题与 # 在同一行
    markdown = re.sub(r'#\s+\n', '# ', markdown)
    
    return markdown

# 解析 author 标签
def parse_author(html):
    # 尝试从 meta 标签解析 author
    author_match = re.search(r'<meta[^>]*name="author"[^>]*content="([^"]*)"[^>]*>', html)
    if author_match:
        return author_match.group(1)
    
    # 尝试从其他可能的位置解析 author
    author_match = re.search(r'<author[^>]*>([\s\S]*?)</author>', html)
    if author_match:
        return author_match.group(1)
    
    # 默认作者
    return 'unknown'

# 处理 raw 文件夹中的所有 HTML 文件
def process_html_files():
    raw_dir = os.path.join(os.path.dirname(__file__), 'raw')
    output_dir = os.path.join(os.path.dirname(__file__), 'output')
    
    # 读取 raw 目录中的文件
    files = os.listdir(raw_dir)
    
    for file in files:
        if file.endswith('.html'):
            html_path = os.path.join(raw_dir, file)
            
            print(f'Processing {file}...')
            
            try:
                html = read_html_file(html_path)
                # 解析 author 标签，临时记忆为 x
                x = parse_author(html)
                # 清理作者名称，移除可能的特殊字符
                x = re.sub(r'[<>"/\\|?*]', '', x).strip()
                # 创建作者文件夹
                author_dir = os.path.join(output_dir, x)
                if not os.path.exists(author_dir):
                    os.makedirs(author_dir, exist_ok=True)
                # 构建 Markdown 文件路径
                markdown_path = os.path.join(author_dir, f'{os.path.splitext(file)[0]}.md')
                # 转换 HTML 到 Markdown
                markdown = html_to_markdown(html)
                # 保存 Markdown 文件
                with open(markdown_path, 'w', encoding='utf-8') as f:
                    f.write(markdown)
                print(f'Successfully converted {file} to {os.path.basename(markdown_path)} in folder {x}')
            except Exception as e:
                print(f'Error processing {file}: {str(e)}')
    
    print('Processing complete!')

# 运行转换
if __name__ == '__main__':
    process_html_files()