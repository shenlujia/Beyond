import re
from html_parser import parse_with_stack


def merge_consecutive_bold_spans(text):
    """合并连续的加粗span标签"""
    result = text
    
    while True:
        bold_pattern = r'<span[^>]*style="[^"]*font-weight:\s*bold[^"]*"[^>]*>(.*?)</span>'
        first_match = re.search(bold_pattern, result, re.DOTALL)
        if not first_match:
            break
        
        first_start = first_match.start()
        first_end = first_match.end()
        first_content = first_match.group(1)
        
        current_pos = first_end
        merged_content = first_content
        found_more = False
        
        while True:
            between_match = re.match(r'^(<[^>]*>|\s)*', result[current_pos:])
            if between_match:
                between = between_match.group(0)
                current_pos += len(between)
            else:
                break
            
            next_match = re.match(bold_pattern, result[current_pos:], re.DOTALL)
            if next_match:
                found_more = True
                merged_content += between + next_match.group(1)
                current_pos += len(next_match.group(0))
            else:
                break
        
        if found_more:
            merged_span = f'<span style="font-weight: bold">{merged_content}</span>'
            result = result[:first_start] + merged_span + result[current_pos:]
        else:
            break
    
    return result


def parse_inline_elements(text):
    """解析内联元素：颜色、图片、加粗、超链接等"""
    result = text
    
    result = merge_consecutive_bold_spans(result)
    
    while '<span' in result:
        span_match = re.search(r'<span[^>]*>([^<]*)</span>', result)
        if not span_match:
            break
        
        span_full = span_match.group(0)
        span_inner = span_match.group(1)
        
        is_bold = re.search(r'style="[^"]*font-weight:\s*bold[^"]*"', span_full) is not None
        is_italic = re.search(r'style="[^"]*font-style:\s*italic[^"]*"', span_full) is not None
        
        if is_bold:
            span_inner = f'**{span_inner}**'
        if is_italic:
            span_inner = f'*{span_inner}*'
        
        color_match = re.search(r'style="[^"]*color:\s*rgb\((\d+),\s*(\d+),\s*(\d+)\)[^"]*"', span_full)
        if color_match:
            r = color_match.group(1)
            g = color_match.group(2)
            b = color_match.group(3)
            result = result.replace(span_full, f'{{{{COLOR_SPAN:{r},{g},{b}:{span_inner}}}}}')
        else:
            result = result.replace(span_full, span_inner)
    
    img_pattern = r'<img[^>]*data-src="([^"]+)"[^>]*>'
    def replace_img(match):
        url = match.group(1)
        return f'![图片]({url})'
    result = re.sub(img_pattern, replace_img, result)
    
    result = re.sub(r'<strong[^>]*>(.*?)</strong>', r'**\1**', result, flags=re.DOTALL)
    result = re.sub(r'<b[^>]*>(.*?)</b>', r'**\1**', result, flags=re.DOTALL)
    
    result = re.sub(r'<em[^>]*>(.*?)</em>', r'*\1*', result, flags=re.DOTALL)
    result = re.sub(r'<i[^>]*>(.*?)</i>', r'*\1*', result, flags=re.DOTALL)
    
    def replace_link(match):
        href = match.group(1)
        text = match.group(2)
        return f'[{text}]({href})'
    result = re.sub(r'<a[^>]*href="([^"]+)"[^>]*>(.*?)</a>', replace_link, result, flags=re.DOTALL)
    
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
    
    while '{{COLOR_SPAN:' in result:
        match = re.search(r'\{\{COLOR_SPAN:(\d+),(\d+),(\d+):([^{}]*?)\}\}', result)
        if match:
            r = int(match.group(1))
            g = int(match.group(2))
            b = int(match.group(3))
            inner = match.group(4)
            
            if r > 240 and g > 240 and b > 240:
                r, g, b = 0, 0, 0
            
            result = result.replace(match.group(0), f'<span style="color: rgb({r},{g},{b})">{inner}</span>')
        else:
            partial_match = re.search(r'\{\{COLOR_SPAN:[^}]*', result)
            if partial_match:
                result = result.replace(partial_match.group(0), '')
            else:
                break
    
    while True:
        bold_positions = []
        for match in re.finditer(r'\*\*', result):
            bold_positions.append(match.start())
        
        merged = False
        for i in range(0, len(bold_positions) - 2, 2):
            if i + 3 >= len(bold_positions):
                break
            current_end = bold_positions[i + 1] + 2
            next_start = bold_positions[i + 2]
            
            between = result[current_end:next_start]
            
            has_text = False
            for c in between:
                if c.isalnum():
                    has_text = True
                    break
            
            if not has_text:
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
    
    if '<' not in content or '>' not in content:
        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            if line:
                paragraphs.append(line)
    else:
        excluded_classes = ['mp_profile_iframe_wrp', 'channels_iframe_wrp']
        excluded_keywords = ['--weui-', ':host {', '.wx_root,']
        
        p_matches = []
        
        if '<section' in content:
            sections = parse_with_stack(content)
            
            for section in sections:
                inner_section_count = section.count('<section')
                if inner_section_count == 1:
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
                    
                    p_in_section = list(re.finditer(r'<p[^>]*>(.*?)</p>', section, re.DOTALL))
                    
                    if p_in_section:
                        section_start = content.find(section)
                        for p_match in p_in_section:
                            p_matches.append({
                                'type': 'p',
                                'start': section_start + p_match.start(),
                                'content': p_match.group(1)
                            })
                    else:
                        pos = content.find(section)
                        if pos != -1:
                            p_matches.append({
                                'type': 'section',
                                'start': pos,
                                'content': section
                            })
        
        for match in re.finditer(r'<p[^>]*>(.*?)</p>', content, re.DOTALL):
            p_matches.append({
                'type': 'p',
                'start': match.start(),
                'content': match.group(1)
            })
        
        for h_level in range(1, 7):
            tag = f'h{h_level}'
            prefix = '#' * h_level
            for match in re.finditer(rf'<{tag}[^>]*>(.*?)</{tag}>', content, re.DOTALL):
                inner_content = match.group(1)
                parsed_inner = parse_inline_elements(inner_content)
                if parsed_inner.strip():
                    p_matches.append({
                        'type': tag,
                        'start': match.start(),
                        'content': f'{prefix} {parsed_inner.strip()}'
                    })
        
        p_matches.sort(key=lambda x: x['start'])
        
        seen = set()
        for match in p_matches:
            if match['type'].startswith('h'):
                parsed_text = match['content']
            else:
                parsed_text = parse_inline_elements(match['content'])
                parsed_text = parsed_text.strip()
            if parsed_text and parsed_text not in seen:
                seen.add(parsed_text)
                paragraphs.append(parsed_text)
    
    for para in paragraphs:
        markdown += para + '\n\n'
    
    return markdown
