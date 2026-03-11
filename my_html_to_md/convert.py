import os
import re

# 读取 HTML 文件
def read_html_file(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        return f.read()

# 提取图片 URL
def extract_images(html):
    picture_urls = []
    # 解析 img_list_indicator_wrp 中的图片
    img_list_match = re.search(r'img_list_indicator_wrp[^>]*>([\s\S]*?)</div>', html, re.DOTALL)
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
    return picture_urls

def get_rich_media_content(html):
    start_idx = html.find('rich_media_content')
    if start_idx != -1:
        # 找到当前 div 的结束位置
        end_of_tag = html.find('/div>', start_idx)
        if end_of_tag != -1:
            tag_content = html[start_idx:end_of_tag]
            return tag_content
    return ''

# 简单的 HTML 转 Markdown 函数
def html_to_markdown(html):
    # 提取标题
    title_match = re.search(r'<h1[^>]*>\s*([\s\S]*?)\s*</h1>', html)
    title = title_match.group(1) if title_match else ''
    # 清理标题中的 HTML 标签
    title = re.sub(r'<[^>]*>', '', title)
    
    # 从 JavaScript 中提取内容
    content = ''
    # 优先尝试从 rich_media_content 中提取内容
    rich_media_content = get_rich_media_content(html)
    if rich_media_content:
        content = rich_media_content.strip()
        # 提取所有 <p> 标签内容
        p_matches = []
        # 使用字符串处理方法提取 p 标签
        p_start = content.find('<p')
        while p_start != -1:
            # 找到 p 标签的结束位置
            p_end = content.find('>', p_start)
            if p_end == -1:
                break
            # 找到对应的 </p> 标签
            p_close = content.find('</p>', p_end)
            if p_close == -1:
                break
            # 提取 p 标签内容
            p_content = content[p_end+1:p_close].strip()
            # 移除 p 标签内的其他 HTML 标签
            clean_content = ''
            in_tag = False
            for char in p_content:
                if char == '<':
                    in_tag = True
                elif char == '>':
                    in_tag = False
                elif not in_tag:
                    clean_content += char
            clean_content = clean_content.strip()
            if clean_content:
                p_matches.append(clean_content)
            # 查找下一个 p 标签
            p_start = content.find('<p', p_close)
        if p_matches:
            content = '\n\n'.join(p_matches)
        else:
            # 如果没有 <p> 标签，移除所有 HTML 标签后使用内容
            clean_content = ''
            in_tag = False
            for char in content:
                if char == '<':
                    in_tag = True
                elif char == '>':
                    in_tag = False
                elif not in_tag:
                    clean_content += char
            content = clean_content.strip()
    # 提取图片
    picture_urls = extract_images(html)
    
    # 组合标题和内容
    markdown = f'# {title}\n\n'
    
    # 添加图片
    if picture_urls:
        for img_url in picture_urls:
            markdown += f'![Image]({img_url})\n\n'
    
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