import re

def get_rich_media_content(html):
    """获取rich_media_content内容"""
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

def main():
    html_file = 'raw/美国打伊朗，比特币为何暴跌？.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    print('提取rich_media_content...')
    rich_content = get_rich_media_content(html_content)
    
    print('使用栈解析section...')
    sections = parse_with_stack(rich_content)
    
    print(f'共找到 {len(sections)} 个section')
    
    result = []
    for idx, section in enumerate(sections):
        if '<p' in section:
            inner_section_count = section.count('<section')
            if inner_section_count == 1:
                p_tags = re.findall(r'<p[^>]*>(.*?)</p>', section, re.DOTALL)
                
                for p in p_tags:
                    clean_text = re.sub(r'<[^>]+>', '', p)
                    clean_text = clean_text.strip()
                    if clean_text:
                        result.append(clean_text)
    
    print('写入test_text.txt...')
    with open('test_text.txt', 'w', encoding='utf-8') as f:
        for para in result:
            f.write(para + '\n\n')
    
    print(f'完成! 共解析出 {len(result)} 个段落')

if __name__ == '__main__':
    main()
