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
    
    excluded_classes = ['mp_profile_iframe_wrp', 'channels_iframe_wrp']
    
    for i, sec in enumerate(sections):
        print(f'\n--- Section {i+1} ---')
        
        # 检查是否是需要排除的section
        skip = False
        for excluded_class in excluded_classes:
            if excluded_class in sec:
                skip = True
                break
        
        if skip:
            print(f'  跳过（被过滤）')
            continue
        
        inner_section_count = sec.count('<section')
        print(f'  inner_section_count: {inner_section_count}')
        
        if inner_section_count == 1:
            print(f'  检查是否有p标签: {"<p" in sec}')
            print(f'  检查是否有img标签: {"<img" in sec}')
            
            if '<p' in sec:
                print(f'  包含p标签')
            elif '<img' in sec:
                print(f'  包含img标签但没有p标签')
        else:
            print(f'  不是最内层的section')

if __name__ == '__main__':
    main()
