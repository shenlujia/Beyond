import os
import re
import time
import urllib.request
from datetime import datetime
from urllib.parse import urlparse

def extract_author(html_content):
    """从HTML中提取author（优先使用nick_name）"""
    # 1. 优先从nick_name中提取
    nick_name_match = re.search(r'nick_name:\s*JsDecode\([\'"]([^\'"]+)[\'"]\)', html_content)
    if nick_name_match:
        return nick_name_match.group(1)
    
    # 2. 尝试直接匹配nick_name: 'xxx'格式
    nick_name_direct = re.search(r'nick_name:\s*[\'"]([^\'"]+)[\'"]', html_content)
    if nick_name_direct:
        return nick_name_direct.group(1)
    
    # 3. 如果没有nick_name，从meta标签中提取
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

def get_timestamp_prefix():
    """生成时间戳前缀（只到日期）"""
    return datetime.now().strftime('%Y%m%d')

def extract_title_for_download(html_content, encoding='utf-8'):
    """从HTML内容中提取标题（用于下载功能）"""
    try:
        html_str = html_content.decode(encoding, errors='ignore')
        
        # 1. 首先尝试从微信公众号的meta标签中提取
        wechat_title_match = re.search(r'<meta\s+property="og:title"\s+content="([^"]+)"', html_str)
        if wechat_title_match:
            return wechat_title_match.group(1).strip()
        
        # 2. 尝试从微信公众号的title变量中提取
        wechat_title_var = re.search(r'var\s+title\s*=\s*"([^"]+)"', html_str)
        if wechat_title_var:
            return wechat_title_var.group(1).strip()
        
        # 3. 尝试从<title>标签中提取
        title_match = re.search(r'<title>([^<]+)</title>', html_str, re.IGNORECASE)
        if title_match:
            title = title_match.group(1).strip()
            # 移除常见的网站后缀
            title = re.sub(r'\s*[-|_]\s*.*$', '', title)
            return title
        
        # 4. 尝试从h1标签中提取
        h1_match = re.search(r'<h1[^>]*>([^<]+)</h1>', html_str, re.IGNORECASE | re.DOTALL)
        if h1_match:
            return h1_match.group(1).strip()
        
    except Exception:
        pass
    
    return None


def sanitize_filename_for_download(url, html_content=None, encoding='utf-8'):
    """从URL或HTML标题中提取并清理文件名（用于下载功能）"""
    # 首先尝试从HTML内容中提取标题
    if html_content:
        title = extract_title_for_download(html_content, encoding)
        if title:
            filename = sanitize_string_for_download(title)
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return filename
    
    # 如果没有HTML内容或提取不到标题，从URL中提取
    parsed = urlparse(url)
    
    # 尝试从路径中提取文件名
    path = parsed.path
    if path:
        # 获取路径的最后一部分
        filename = os.path.basename(path)
        if filename:
            # 如果没有扩展名，添加.html
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return sanitize_string_for_download(filename)
    
    # 如果路径中没有文件名，使用域名
    domain = parsed.netloc
    return sanitize_string_for_download(f'{domain}.html')


def sanitize_string_for_download(s):
    """清理文件名中的非法字符（用于下载功能）"""
    # 移除或替换非法字符
    s = re.sub(r'[<>:"/\\\\|?*]', '_', s)
    # 移除换行符和制表符
    s = re.sub(r'[\\n\\r\\t]', ' ', s)
    # 合并多个空格
    s = re.sub(r'\\s+', ' ', s)
    # 限制长度
    return s[:100].strip()


def download_html(url, output_dir='tmp_gen'):
    """从URL下载HTML文件"""
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    print(f'正在下载: {url}')
    
    try:
        # 设置User-Agent以避免被一些网站拒绝
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            html_content = response.read()
            
            # 检测编码
            content_type = response.headers.get('Content-Type', '')
            encoding = 'utf-8'
            
            if 'charset=' in content_type:
                charset = content_type.split('charset=')[-1]
                encoding = charset.strip()
            
            # 生成文件名（优先使用文章标题）
            filename = sanitize_filename_for_download(url, html_content, encoding)
            filepath = os.path.join(output_dir, filename)
            
            # 写入文件
            with open(filepath, 'wb') as f:
                f.write(html_content)
            
            print(f'下载成功! 已保存到: {filepath}')
            return filepath
            
    except Exception as e:
        print(f'下载失败: {str(e)}')
        return None


def main_download():
    """下载功能的主函数 - 交互式下载"""
    import sys
    
    if len(sys.argv) > 1:
        # 从命令行参数获取URL
        url = sys.argv[1]
        download_html(url)
    else:
        # 交互式输入
        print('HTML 下载器')
        print('=' * 40)
        
        while True:
            url = input('\\n请输入要下载的URL (输入 q 退出): ').strip()
            
            if url.lower() == 'q':
                print('再见!')
                break
            
            if not url:
                continue
            
            # 如果没有协议，添加https
            if not url.startswith(('http://', 'https://')):
                url = 'https://' + url
            
            download_html(url)


def main_convert():
    """转换功能的主函数"""
    # 支持从 raw 或 tmp_gen 文件夹读取
    raw_dir = 'raw'
    tmp_gen_dir = 'tmp_gen'
    output_dir = 'docs'
    
    # 确定使用哪个目录
    input_dir = None
    if os.path.exists(tmp_gen_dir):
        input_dir = tmp_gen_dir
    elif os.path.exists(raw_dir):
        input_dir = raw_dir
    else:
        print(f'错误: 找不到 {tmp_gen_dir} 或 {raw_dir} 文件夹')
        return
    
    # 遍历文件夹中的HTML文件
    html_files = [f for f in os.listdir(input_dir) if f.endswith('.html')]
    
    if not html_files:
        print(f'错误: {input_dir} 文件夹中没有HTML文件')
        return
    
    print(f'找到 {len(html_files)} 个HTML文件')
    
    for html_file in html_files:
        file_path = os.path.join(input_dir, html_file)
        print(f'处理: {html_file}')
        
        try:
            author, markdown = process_html_file(file_path)
            
            # 创建作者文件夹
            author_dir = os.path.join(output_dir, author)
            os.makedirs(author_dir, exist_ok=True)
            
            # 保存Markdown文件（带时间戳前缀）
            filename = os.path.splitext(html_file)[0]
            timestamp_prefix = get_timestamp_prefix()
            md_file = os.path.join(author_dir, f'{timestamp_prefix}_{filename}.md')
            
            with open(md_file, 'w', encoding='utf-8') as f:
                f.write(markdown)
            
            print(f'  已保存到: {md_file}')
        except Exception as e:
            print(f'  错误: {e}')
            import traceback
            traceback.print_exc()
    
    print('转换完成!')


def main():
    """主函数 - 根据参数选择功能"""
    import sys
    
    if len(sys.argv) > 1:
        # 检查是否是下载命令
        if sys.argv[1] == 'download' and len(sys.argv) > 2:
            # download-html 子能力
            url = sys.argv[2]
            download_html(url)
        elif sys.argv[1] == 'convert':
            # wechat-html-to-markdown 子能力
            main_convert()
        elif sys.argv[1].startswith(('http://', 'https://')):
            # 如果第一个参数是URL，默认为下载
            url = sys.argv[1]
            download_html(url)
        else:
            # 默认为转换功能
            main_convert()
    else:
        # 没有参数时，默认为转换功能
        main_convert()


if __name__ == '__main__':
    main()
