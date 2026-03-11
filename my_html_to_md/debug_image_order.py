import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content, parse_with_stack, parse_content_to_markdown

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = get_rich_media_content(html_content)
    
    print('--- 先看一下parse_with_stack返回的section顺序 ---')
    sections = parse_with_stack(content)
    print(f'总共找到 {len(sections)} 个section')
    
    for i, sec in enumerate(sections):
        print(f'\n--- Section {i+1} ---')
        if '<img' in sec:
            print(f'  包含img标签')
        if '<p' in sec:
            print(f'  包含p标签')
        print(f'  内容预览: {sec[:100]}')
    
    print('\n--- 现在看parse_content_to_markdown返回的markdown ---')
    markdown = parse_content_to_markdown(content)
    lines = markdown.split('\n\n')
    print(f'总共 {len(lines)} 个段落')
    for i, line in enumerate(lines[:20]):
        if line:
            preview = line[:80]
            if '![' in preview:
                print(f'{i+1}. [图片] {preview}')
            else:
                print(f'{i+1}. {preview}')

if __name__ == '__main__':
    main()
