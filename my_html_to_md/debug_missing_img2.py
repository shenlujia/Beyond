import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content, parse_with_stack

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = get_rich_media_content(html_content)
    
    # 查找"有个老登就发了谰言"附近的内容
    keyword = '有个老登就发了谰言'
    pos = content.find(keyword)
    
    if pos != -1:
        start = max(0, pos - 200)
        end = pos + len(keyword) + 1000
        snippet = content[start:end]
        print(f'--- "{keyword}" 附近的内容 ---')
        print(snippet)
        
        # 查找这个区域内的img标签
        print(f'\n--- 区域内的img标签 ---')
        img_tags = re.findall(r'<img[^>]+>', snippet)
        for i, img in enumerate(img_tags):
            print(f'{i+1}. {img[:300]}')
        
        # 查找这个区域内的section标签
        print(f'\n--- 区域内的section标签 ---')
        sections = parse_with_stack(snippet)
        print(f'找到 {len(sections)} 个section')
        for i, sec in enumerate(sections):
            print(f'\n--- Section {i+1} ---')
            print(sec[:500])
            # 检查section内是否有img
            if 'img' in sec:
                print('  包含img标签')

if __name__ == '__main__':
    main()
