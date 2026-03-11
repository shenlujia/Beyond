import os
import re

def extract_author(html_content):
    """从HTML中提取author"""
    meta_author = re.search(r'<meta name="author" content="([^"]+)"', html_content)
    if meta_author:
        return meta_author.group(1)
    return '未知作者'

def get_rich_media_content(html):
    """获取rich_media_content内容"""
    start_idx = html.find('<div')
    while start_idx != -1:
        end_of_tag = html.find('>', start_idx)
        if end_of_tag == -1:
            break
        tag_content = html[start_idx:end_of_tag]
        if 'class="rich_media_content"' in tag_content:
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

def main():
    file_path = 'raw/美国打伊朗，比特币为何暴跌？.html'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    print(f'文件长度: {len(html_content)}')
    
    author = extract_author(html_content)
    print(f'作者: {author}')
    
    content = get_rich_media_content(html_content)
    print(f'content长度: {len(content)}')
    print(f'content前500字符:\n{content[:500]}')
    
    # 查找section标签
    sections = re.findall(r'<section[^>]*>(.*?)</section>', content, re.DOTALL)
    print(f'找到 {len(sections)} 个section')
    
    # 查找p标签
    p_tags = re.findall(r'<p[^>]*>(.*?)</p>', content, re.DOTALL)
    print(f'找到 {len(p_tags)} 个p标签')
    
    # 查找leaf标签
    leaf_spans = re.findall(r'<span[^>]*leaf[^>]*>(.*?)</span>', content, re.DOTALL)
    print(f'找到 {len(leaf_spans)} 个leaf span')
    if leaf_spans:
        print('前5个leaf内容:')
        for i, leaf in enumerate(leaf_spans[:5]):
            print(f'{i+1}. {leaf[:100]}')

if __name__ == '__main__':
    main()
