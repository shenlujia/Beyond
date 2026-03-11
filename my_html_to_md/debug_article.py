import re

def get_rich_media_content(html):
    """直接从HTML中获取rich_media_content内容"""
    start_idx = html.find('<div')
    while start_idx != -1:
        end_of_tag = html.find('>', start_idx)
        if end_of_tag == -1:
            break
        tag_content = html[start_idx:end_of_tag]
        if 'rich_media_content' in tag_content:
            print(f'找到rich_media_content在位置: {start_idx}')
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
    print('未找到rich_media_content')
    return ''

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    print(f'HTML总长度: {len(html_content)}')
    
    # 查找rich_media相关的div
    print('\n查找rich_media相关的div:')
    div_matches = re.findall(r'<div[^>]*class="[^"]*rich[^"]*"[^>]*>', html_content)
    for i, match in enumerate(div_matches[:10]):
        print(f'{i+1}. {match[:100]}')
    
    # 尝试提取rich_media_content
    print('\n尝试提取rich_media_content:')
    content = get_rich_media_content(html_content)
    if content:
        print(f'提取到内容，长度: {len(content)}')
        print(f'前500字符:\n{content[:500]}')
        
        # 查找section
        print(f'\nsection数量: {content.count("<section")}')
        
        # 查找p标签
        print(f'p标签数量: {content.count("<p")}')
    
    # 保存完整HTML到文件
    with open('temp/full_html.txt', 'w', encoding='utf-8') as f:
        f.write(html_content)
    print('\n完整HTML已保存到 temp/full_html.txt')

if __name__ == '__main__':
    main()
