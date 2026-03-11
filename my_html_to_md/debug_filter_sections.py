import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content, parse_with_stack

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = get_rich_media_content(html_content)
    
    sections = parse_with_stack(content)
    
    print(f'总共找到 {len(sections)} 个section')
    
    for i, sec in enumerate(sections):
        print(f'\n--- Section {i+1} ---')
        # 检查section的class或其他特征
        class_match = re.search(r'class="([^"]+)"', sec)
        if class_match:
            print(f'  Class: {class_match.group(1)}')
        
        # 检查是否有img
        if '<img' in sec:
            print(f'  包含img标签')
        
        # 检查是否有p
        if '<p' in sec:
            print(f'  包含p标签')
        
        # 检查是否有CSS样式
        if ':host' in sec or '--weui' in sec:
            print(f'  包含CSS样式')
        
        print(f'  内容预览: {sec[:200]}')

if __name__ == '__main__':
    main()
