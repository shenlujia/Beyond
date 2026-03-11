import os
import re

def extract_author(html_content):
    """从HTML中提取author"""
    meta_author = re.search(r'<meta name="author" content="([^"]+)"', html_content)
    if meta_author:
        return meta_author.group(1)
    return '未知作者'

def extract_images(html_content):
    """提取img_list_indicator_wrp中的图片（只包含https开头的图片地址）"""
    images = []
    img_section = re.search(r'<div[^>]*class="[^"]*img_list_indicator_wrp[^"]*"[^>]*>(.*?)</div>', html_content, re.DOTALL)
    if img_section:
        img_urls = re.findall(r'data-src="(https[^"]+)"', img_section.group(1))
        images.extend(img_urls)
    return images

def js_decode(s):
    """JavaScript解码函数"""
    if not s:
        return s
    s = s.replace(r'\x5c', '\\')
    s = s.replace(r'\x0d', '\r')
    s = s.replace(r'\x22', '"')
    s = s.replace(r'\x26', '&')
    s = s.replace(r'\x27', "'")
    s = s.replace(r'\x3c', '<')
    s = s.replace(r'\x3e', '>')
    s = s.replace(r'\x0a', '\n')
    return s

def extract_content_noencode(html_content):
    """从JavaScript中提取content_noencode"""
    match = re.search(r'content_noencode:\s*JsDecode\((.*?)\),', html_content, re.DOTALL)
    if match:
        encoded_str = match.group(1)
        if encoded_str.startswith("'") and encoded_str.endswith("'"):
            encoded_str = encoded_str[1:-1]
        elif encoded_str.startswith('"') and encoded_str.endswith('"'):
            encoded_str = encoded_str[1:-1]
        return js_decode(encoded_str)
    return ''

def parse_with_stack(content):
    """使用栈来解析嵌套的section"""
    stack = []
    sections = []
    i = 0
    n = len(content)
    
    while i < n:
        open_tag = content.find('<section', i)
        close_tag = content.find('</section>', i)
        
        if open_tag == -1 and close_tag == -1:
            break
        
        if open_tag != -1 and (close_tag == -1 or open_tag < close_tag):
            stack.append(open_tag)
            i = open_tag + len('<section')
        else:
            if stack:
                start_pos = stack.pop()
                section_content = content[start_pos:close_tag + len('</section>')]
                sections.append(section_content)
            i = close_tag + len('</section>')
    
    return sections

def parse_content_to_markdown(content):
    """解析内容为Markdown格式 - 最内层每个<p>作为单独一段"""
    markdown = ''
    
    # 使用栈解析嵌套的section
    sections = parse_with_stack(content)
    
    paragraphs = []
    for section in sections:
        if '<p' in section:
            inner_section_count = section.count('<section')
            if inner_section_count == 1:
                # 提取所有p标签，每个作为单独一段
                p_tags = re.findall(r'<p[^>]*>(.*?)</p>', section, re.DOTALL)
                
                for p in p_tags:
                    clean_text = re.sub(r'<[^>]+>', '', p)
                    clean_text = clean_text.strip()
                    if clean_text:
                        paragraphs.append(clean_text)
    
    # 组合Markdown
    for para in paragraphs:
        markdown += para + '\n\n'
    
    return markdown

def process_html_file(file_path):
    """处理单个HTML文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # 1. 获取文件名（不含后缀）
    filename = os.path.basename(file_path)
    filename = os.path.splitext(filename)[0]
    
    # 2. 解析author标签
    author = extract_author(html_content)
    
    # 3. 提取图片
    images = extract_images(html_content)
    
    # 4. 获取content_noencode
    content = extract_content_noencode(html_content)
    
    # 5. 解析内容为Markdown
    markdown_content = parse_content_to_markdown(content)
    
    # 6. 组合Markdown
    markdown = f'# {filename}\n\n'
    markdown += f'作者：{author}\n\n'
    
    # 添加图片
    for img_url in images:
        markdown += f'![图片]({img_url})\n\n'
    
    markdown += markdown_content
    
    return author, markdown

def main():
    raw_dir = 'raw'
    output_dir = 'output'
    
    if not os.path.exists(raw_dir):
        print(f'错误: 找不到 {raw_dir} 文件夹')
        return
    
    # 遍历raw文件夹中的HTML文件
    html_files = [f for f in os.listdir(raw_dir) if f.endswith('.html')]
    
    if not html_files:
        print(f'错误: {raw_dir} 文件夹中没有HTML文件')
        return
    
    print(f'找到 {len(html_files)} 个HTML文件')
    
    for html_file in html_files:
        file_path = os.path.join(raw_dir, html_file)
        print(f'处理: {html_file}')
        
        try:
            author, markdown = process_html_file(file_path)
            
            # 创建作者文件夹
            author_dir = os.path.join(output_dir, author)
            os.makedirs(author_dir, exist_ok=True)
            
            # 保存Markdown文件
            filename = os.path.splitext(html_file)[0]
            md_file = os.path.join(author_dir, f'{filename}.md')
            
            with open(md_file, 'w', encoding='utf-8') as f:
                f.write(markdown)
            
            print(f'  已保存到: {md_file}')
        except Exception as e:
            print(f'  错误: {e}')
            import traceback
            traceback.print_exc()
    
    print('转换完成!')

if __name__ == '__main__':
    main()
