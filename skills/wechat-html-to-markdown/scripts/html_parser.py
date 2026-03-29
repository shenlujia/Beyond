import re


def extract_original_url(html_content):
    """从HTML中提取原文链接"""
    og_url_match = re.search(r'<meta property="og:url" content="([^"]+)"', html_content)
    if og_url_match:
        return og_url_match.group(1)
    
    return None


def extract_author(html_content):
    """从HTML中提取author（优先使用nick_name）"""
    nick_name_match = re.search(r'nick_name:\s*JsDecode\([\'"]([^\'"]+)[\'"]\)', html_content)
    if nick_name_match:
        return nick_name_match.group(1)
    
    nick_name_direct = re.search(r'nick_name:\s*[\'"]([^\'"]+)[\'"]', html_content)
    if nick_name_direct:
        return nick_name_direct.group(1)
    
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
    
    ppil_positions = [m.start() for m in re.finditer(r'picture_page_info_list', html_content)]
    
    max_cdn_count = 0
    best_ppil_content = None
    
    for pos in ppil_positions:
        bracket_start = html_content.find('[', pos)
        if bracket_start != -1:
            ppil_content = extract_matching_brackets(html_content, bracket_start)
            if ppil_content:
                cdn_count = len(re.findall(r'cdn_url', ppil_content))
                if cdn_count > max_cdn_count:
                    max_cdn_count = cdn_count
                    best_ppil_content = ppil_content
    
    if best_ppil_content:
        cdn_urls = re.findall(r'cdn_url\s*[:=]\s*(?:JsDecode\([\'"]([^\'"]+)[\'"]\)|[\'"]([^\'"]+)[\'"])', best_ppil_content)
        for url1, url2 in cdn_urls:
            url = url1 if url1 else url2
            if url.startswith('https'):
                url = url.replace('\\x26amp;', '&')
                url = url.replace('&amp;', '&')
                if 'from=appmsg' in url:
                    images.append(url)
    
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
