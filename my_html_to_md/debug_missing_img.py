import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content

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
        end = pos + len(keyword) + 500
        snippet = content[start:end]
        print(f'--- "{keyword}" 附近的内容 ---')
        print(snippet)
        
        # 查找这个区域内的img标签
        print(f'\n--- 区域内的img标签 ---')
        img_tags = re.findall(r'<img[^>]+>', snippet)
        for i, img in enumerate(img_tags):
            print(f'{i+1}. {img}')

if __name__ == '__main__':
    main()
