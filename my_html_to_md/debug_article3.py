import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content, parse_with_stack

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = get_rich_media_content(html_content)
    
    print(f'section标签数量: {content.count("<section")}')
    
    # 查找所有section标签的位置
    positions = []
    i = 0
    while True:
        pos = content.find('<section', i)
        if pos == -1:
            break
        positions.append(pos)
        i = pos + 1
    
    print(f'section位置: {positions}')
    
    # 查看每个section的内容
    for idx, pos in enumerate(positions):
        print(f'\n--- Section {idx+1} ---')
        snippet = content[pos:pos+300]
        print(snippet)
    
    # 使用parse_with_stack测试
    print(f'\n--- 使用parse_with_stack ---')
    sections = parse_with_stack(content)
    print(f'找到 {len(sections)} 个section')

if __name__ == '__main__':
    main()
