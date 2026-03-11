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

def get_rich_media_content(html):
    """直接从HTML中获取rich_media_content内容"""
    start_idx = html.find('<div')
    while start_idx != -1:
        end_of_tag = html.find('>', start_idx)
        if end_of_tag == -1:
            break
        tag_content = html[start_idx:end_of_tag]
        if 'rich_media_content' in tag_content:
            div_count = 1
            end_idx = end_of_tag + 1
            while end_idx < len(html) and div_count > 0:
                if html[end_idx:end_idx+5] == '</div':
                    div_end = html.find('>', end_idx)
                    if div_end != -1:
                        div_count -= 1
                        end_idx = div_end + 1
                    else:
                        end_idx += 1
                elif html[end_idx:end_idx+4] == '<div':
                    div_count += 1
                    end_idx += 1
                else:
                    end_idx += 1
            if div_count == 0:
                return html[end_of_tag+1:end_idx-6]
        start_idx = html.find('<div', end_of_tag)
    return ''

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

def parse_inline_elements(text):
    """解析内联元素：颜色、图片等"""
    result = text
    
    # 先处理图片标签
    # 匹配 <img ... data-src="url" ...>
    img_pattern = r'<img[^>]*data-src="([^"]+)"[^>]*>'
    def replace_img(match):
        url = match.group(1)
        return f'![图片]({url})'
    result = re.sub(img_pattern, replace_img, result)
    
    # 处理所有span标签，保留带颜色的
    # 用循环来处理嵌套的span
    while '<span' in result:
        # 查找最内层的span
        span_match = re.search(r'<span[^>]*>([^<]*)</span>', result)
        if not span_match:
            break
        
        span_full = span_match.group(0)
        span_inner = span_match.group(1)
        
        # 检查是否有颜色
        color_match = re.search(r'style="[^"]*color:\s*rgb\((\d+),\s*(\d+),\s*(\d+)\)[^"]*"', span_full)
        if color_match:
            r = color_match.group(1)
            g = color_match.group(2)
            b = color_match.group(3)
            result = result.replace(span_full, f'{{{{COLOR_SPAN:{r},{g},{b}:{span_inner}}}}}')
        else:
            # 没有颜色，直接替换为内容
            result = result.replace(span_full, span_inner)
    
    # 清理其他标签（除了我们的占位符）
    # 先把占位符保护起来
    temp_parts = []
    i = 0
    while True:
        start = result.find('{{COLOR_SPAN:', i)
        if start == -1:
            temp_parts.append(re.sub(r'<[^>]+>', '', result[i:]))
            break
        temp_parts.append(re.sub(r'<[^>]+>', '', result[i:start]))
        end = result.find('}}', start)
        if end == -1:
            temp_parts.append(result[start:])
            break
        temp_parts.append(result[start:end+2])
        i = end + 2
    result = ''.join(temp_parts)
    
    # 把占位符还原成span标签 - 处理所有占位符，包括可能的重复或部分匹配
    # 使用循环来确保所有占位符都被替换
    while '{{COLOR_SPAN:' in result:
        # 先尝试匹配完整的占位符
        match = re.search(r'\{\{COLOR_SPAN:(\d+),(\d+),(\d+):([^{}]*?)\}\}', result)
        if match:
            r = match.group(1)
            g = match.group(2)
            b = match.group(3)
            inner = match.group(4)
            result = result.replace(match.group(0), f'<span style="color: rgb({r},{g},{b})">{inner}</span>')
        else:
            # 如果没有完整匹配，尝试查找并清理不完整的占位符
            partial_match = re.search(r'\{\{COLOR_SPAN:[^}]*', result)
            if partial_match:
                result = result.replace(partial_match.group(0), '')
            else:
                break
    
    return result

def parse_content_to_markdown(content):
    """解析内容为Markdown格式 - 支持图片和颜色，保持原始顺序"""
    markdown = ''
    
    paragraphs = []
    
    # 需要过滤的section class列表
    excluded_classes = ['mp_profile_iframe_wrp', 'channels_iframe_wrp']
    
    # 首先找到所有p标签的位置和内容
    p_matches = []
    for match in re.finditer(r'<p[^>]*>(.*?)</p>', content, re.DOTALL):
        p_matches.append({
            'type': 'p',
            'start': match.start(),
            'content': match.group(1)
        })
    
    # 然后找到所有包含img标签且没有p标签的section的位置和内容
    if '<section' in content:
        sections = parse_with_stack(content)
        
        for section in sections:
            inner_section_count = section.count('<section')
            if inner_section_count == 1:
                # 检查是否是需要排除的section
                skip = False
                for excluded_class in excluded_classes:
                    if excluded_class in section:
                        skip = True
                        break
                if skip:
                    continue
                
                # 检查是否有img标签但没有p标签
                if '<img' in section and '<p' not in section:
                    # 找到这个section在content中的位置
                    pos = content.find(section)
                    if pos != -1:
                        p_matches.append({
                            'type': 'img_section',
                            'start': pos,
                            'content': section
                        })
    
    # 按start位置排序
    p_matches.sort(key=lambda x: x['start'])
    
    # 处理每个匹配项
    seen = set()
    for match in p_matches:
        if match['type'] == 'p':
            parsed_text = parse_inline_elements(match['content'])
        else:
            parsed_text = parse_inline_elements(match['content'])
        
        parsed_text = parsed_text.strip()
        if parsed_text and parsed_text not in seen:
            seen.add(parsed_text)
            paragraphs.append(parsed_text)
    
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
    
    # 4. 优先直接从HTML中提取rich_media_content，如果没有则尝试从JavaScript中提取content_noencode
    content = get_rich_media_content(html_content)
    if not content:
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
