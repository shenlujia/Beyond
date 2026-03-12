import os
import re

def extract_author(html_content):
    """从HTML中提取author"""
    meta_author = re.search(r'<meta name="author" content="([^"]+)"', html_content)
    if meta_author:
        return meta_author.group(1)
    return '未知作者'

def extract_matching_brackets(text, start_pos):
    """从start_pos开始找到匹配的方括号对"""
    stack = []
    i = start_pos
    n = len(text)
    
    while i < n:
        if text[i] == '[':
            stack.append(i)
        elif text[i] == ']':
            if stack:
                start = stack.pop()
                if not stack:
                    return text[start:i+1]
        i += 1
    return None

def extract_images(html_content):
    """提取图片列表（支持两种结构：img_list_indicator_wrp和picture_page_info_list）"""
    images = []
    
    # 先尝试从picture_page_info_list中提取图片（图片集文章）
    # 查找所有picture_page_info_list的位置
    ppil_positions = [m.start() for m in re.finditer(r'picture_page_info_list', html_content)]
    
    max_cdn_count = 0
    best_ppil_content = None
    
    for pos in ppil_positions:
        # 从picture_page_info_list后面找[
        bracket_start = html_content.find('[', pos)
        if bracket_start != -1:
            # 找到匹配的方括号对
            ppil_content = extract_matching_brackets(html_content, bracket_start)
            if ppil_content:
                # 统计这个数组中的cdn_url数量
                cdn_count = len(re.findall(r'cdn_url', ppil_content))
                if cdn_count > max_cdn_count:
                    max_cdn_count = cdn_count
                    best_ppil_content = ppil_content
    
    if best_ppil_content:
        # 提取所有cdn_url
        cdn_urls = re.findall(r'cdn_url\s*[:=]\s*(?:JsDecode\([\'"]([^\'"]+)[\'"]\)|[\'"]([^\'"]+)[\'"])', best_ppil_content)
        for url1, url2 in cdn_urls:
            url = url1 if url1 else url2
            if url.startswith('https'):
                # 解码URL中的HTML实体
                url = url.replace('\\x26amp;', '&')
                url = url.replace('&amp;', '&')
                # 只包含from=appmsg的图片，这些是内容图片
                if 'from=appmsg' in url:
                    images.append(url)
    
    # 如果没有找到，尝试从img_list_indicator_wrp中提取
    if not images:
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

def merge_consecutive_bold_spans(text):
    """合并连续的加粗span标签"""
    result = text
    
    while True:
        # 查找第一个加粗span
        bold_pattern = r'<span[^>]*style="[^"]*font-weight:\s*bold[^"]*"[^>]*>(.*?)</span>'
        first_match = re.search(bold_pattern, result, re.DOTALL)
        if not first_match:
            break
        
        first_start = first_match.start()
        first_end = first_match.end()
        first_content = first_match.group(1)
        
        # 查找后面是否还有连续的加粗span（中间只有其他标签或空白）
        current_pos = first_end
        merged_content = first_content
        found_more = False
        
        while True:
            # 跳过中间的非加粗标签和空白
            between_match = re.match(r'^(<[^>]*>|\s)*', result[current_pos:])
            if between_match:
                between = between_match.group(0)
                current_pos += len(between)
            else:
                break
            
            # 检查下一个是否是加粗span
            next_match = re.match(bold_pattern, result[current_pos:], re.DOTALL)
            if next_match:
                found_more = True
                merged_content += between + next_match.group(1)
                current_pos += len(next_match.group(0))
            else:
                break
        
        if found_more:
            # 合并这些加粗span
            merged_span = f'<span style="font-weight: bold">{merged_content}</span>'
            result = result[:first_start] + merged_span + result[current_pos:]
        else:
            # 没有找到更多，移动到下一个位置
            break
    
    return result

def parse_inline_elements(text):
    """解析内联元素：颜色、图片、加粗、超链接等"""
    result = text
    
    # 先合并连续的加粗span标签
    result = merge_consecutive_bold_spans(result)
    
    # 处理所有span标签，保留带颜色的，用占位符保护起来，同时处理加粗
    # 用循环来处理嵌套的span
    while '<span' in result:
        # 查找最内层的span
        span_match = re.search(r'<span[^>]*>([^<]*)</span>', result)
        if not span_match:
            break
        
        span_full = span_match.group(0)
        span_inner = span_match.group(1)
        
        # 检查是否有font-weight: bold
        is_bold = re.search(r'style="[^"]*font-weight:\s*bold[^"]*"', span_full) is not None
        # 检查是否有font-style: italic
        is_italic = re.search(r'style="[^"]*font-style:\s*italic[^"]*"', span_full) is not None
        
        # 如果是加粗，先把内容用**包裹起来
        if is_bold:
            span_inner = f'**{span_inner}**'
        # 如果是斜体，把内容用*包裹起来
        if is_italic:
            span_inner = f'*{span_inner}*'
        
        # 检查是否有颜色
        color_match = re.search(r'style="[^"]*color:\s*rgb\((\d+),\s*(\d+),\s*(\d+)\)[^"]*"', span_full)
        if color_match:
            r = color_match.group(1)
            g = color_match.group(2)
            b = color_match.group(3)
            result = result.replace(span_full, f'{{{{COLOR_SPAN:{r},{g},{b}:{span_inner}}}}}')
        else:
            # 没有颜色，直接替换为内容（可能已经包含加粗）
            result = result.replace(span_full, span_inner)
    
    # 处理图片标签
    # 匹配 <img ... data-src="url" ...>
    img_pattern = r'<img[^>]*data-src="([^"]+)"[^>]*>'
    def replace_img(match):
        url = match.group(1)
        return f'![图片]({url})'
    result = re.sub(img_pattern, replace_img, result)
    
    # 处理加粗标签 <strong> 和 <b>
    result = re.sub(r'<strong[^>]*>(.*?)</strong>', r'**\1**', result, flags=re.DOTALL)
    result = re.sub(r'<b[^>]*>(.*?)</b>', r'**\1**', result, flags=re.DOTALL)
    
    # 处理斜体标签 <em> 和 <i>
    result = re.sub(r'<em[^>]*>(.*?)</em>', r'*\1*', result, flags=re.DOTALL)
    result = re.sub(r'<i[^>]*>(.*?)</i>', r'*\1*', result, flags=re.DOTALL)
    
    # 处理超链接标签 <a>
    def replace_link(match):
        href = match.group(1)
        text = match.group(2)
        return f'[{text}]({href})'
    result = re.sub(r'<a[^>]*href="([^"]+)"[^>]*>(.*?)</a>', replace_link, result, flags=re.DOTALL)
    
    # 清理其他标签（只保留我们的占位符）
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
            r = int(match.group(1))
            g = int(match.group(2))
            b = int(match.group(3))
            inner = match.group(4)
            
            # 检测白色或接近白色的颜色，改成黑色
            # 如果RGB值都大于240，认为是白色或接近白色
            if r > 240 and g > 240 and b > 240:
                r, g, b = 0, 0, 0
            
            result = result.replace(match.group(0), f'<span style="color: rgb({r},{g},{b})">{inner}</span>')
        else:
            # 如果没有完整匹配，尝试查找并清理不完整的占位符
            partial_match = re.search(r'\{\{COLOR_SPAN:[^}]*', result)
            if partial_match:
                result = result.replace(partial_match.group(0), '')
            else:
                break
    
    # 最终清理：合并真正连续的加粗标记
    # 查找所有**的位置
    while True:
        bold_positions = []
        for match in re.finditer(r'\*\*', result):
            bold_positions.append(match.start())
        
        merged = False
        # 检查是否有可以合并的加粗对
        for i in range(0, len(bold_positions) - 2, 2):
            # 当前加粗对的结束位置
            current_end = bold_positions[i + 1] + 2
            # 下一个加粗对的开始位置
            next_start = bold_positions[i + 2]
            
            # 检查两个加粗对之间的内容
            between = result[current_end:next_start]
            
            # 检查中间是否只有空白、标点或HTML标签残留
            # 如果中间没有字母或数字，就合并
            has_text = False
            for c in between:
                if c.isalnum():
                    has_text = True
                    break
            
            if not has_text:
                # 合并这两个加粗对
                first = bold_positions[i]
                last = bold_positions[i + 3]
                content = result[first + 2:last]
                content = content.replace('**', '')
                result = result[:first] + f'**{content}**' + result[last + 2:]
                merged = True
                break
        
        if not merged:
            break
    
    return result

def parse_content_to_markdown(content):
    """解析内容为Markdown格式 - 支持图片和颜色，保持原始顺序，同时支持纯文本"""
    markdown = ''
    
    paragraphs = []
    
    # 检查是否是纯文本（没有HTML标签）
    if '<' not in content or '>' not in content:
        # 纯文本，按换行符分割
        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            if line:
                paragraphs.append(line)
    else:
        # 需要过滤的section class列表和内容关键词
        excluded_classes = ['mp_profile_iframe_wrp', 'channels_iframe_wrp']
        excluded_keywords = ['--weui-', ':host {', '.wx-root,']
        
        # 同时提取section标签和p标签，然后去重
        p_matches = []
        
        # 首先提取section标签的内容
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
                    if not skip:
                        for keyword in excluded_keywords:
                            if keyword in section:
                                skip = True
                                break
                    if skip:
                        continue
                    
                    # 检查section里面是否有p标签
                    p_in_section = list(re.finditer(r'<p[^>]*>(.*?)</p>', section, re.DOTALL))
                    
                    if p_in_section:
                        # 如果section里面有p标签，就提取这些p标签
                        section_start = content.find(section)
                        for p_match in p_in_section:
                            p_matches.append({
                                'type': 'p',
                                'start': section_start + p_match.start(),
                                'content': p_match.group(1)
                            })
                    else:
                        # 如果section里面没有p标签，就直接处理整个section
                        pos = content.find(section)
                        if pos != -1:
                            p_matches.append({
                                'type': 'section',
                                'start': pos,
                                'content': section
                            })
        
        # 然后提取所有直接在content中的p标签（不是在section中的）
        for match in re.finditer(r'<p[^>]*>(.*?)</p>', content, re.DOTALL):
            p_matches.append({
                'type': 'p',
                'start': match.start(),
                'content': match.group(1)
            })
        
        # 按start位置排序
        p_matches.sort(key=lambda x: x['start'])
        
        # 处理每个匹配项，避免重复
        seen = set()
        for match in p_matches:
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
    
    # 4. 尝试两种方式提取内容，选择更好的那个
    content1 = get_rich_media_content(html_content)
    content2 = extract_content_noencode(html_content)
    
    # 统计两种内容中的p标签数量和文本长度
    def count_content_quality(c):
        p_count = len(re.findall(r'<p[^>]*>', c))
        # 粗略估计文本长度（去除HTML标签）
        text_length = len(re.sub(r'<[^>]+>', '', c))
        return p_count, text_length
    
    p1, t1 = count_content_quality(content1)
    p2, t2 = count_content_quality(content2)
    
    # 选择p标签更多或者文本更长的那个内容
    if p2 > p1 or t2 > t1 * 2:
        content = content2
    else:
        content = content1
    
    # 5. 解析内容为Markdown
    markdown_content = parse_content_to_markdown(content)
    
    # 6. 判断是否是图片集文章（有picture_page_info_list但没有rich_media_content）
    is_gallery_article = 'picture_page_info_list' in html_content and not get_rich_media_content(html_content)
    
    # 7. 组合Markdown
    markdown = f'# {filename}\n\n'
    markdown += f'作者：{author}\n\n'
    
    # 只有图片集文章才在前面添加图片列表
    if is_gallery_article:
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
