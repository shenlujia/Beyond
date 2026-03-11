import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = get_rich_media_content(html_content)
    
    # 查找图片标签
    print('--- 查找图片标签 ---')
    img_tags = re.findall(r'<img[^>]+>', content)
    print(f'找到 {len(img_tags)} 个img标签')
    for i, img in enumerate(img_tags[:5]):
        print(f'{i+1}. {img}')
    
    # 查找带颜色的span标签
    print('\n--- 查找带颜色的span标签 ---')
    color_spans = re.findall(r'<span[^>]*style[^>]*color[^>]*>(.*?)</span>', content, re.DOTALL)
    print(f'找到 {len(color_spans)} 个带颜色的span')
    for i, span in enumerate(color_spans[:5]):
        print(f'{i+1}. {span[:100]}')
    
    # 查找带style的span标签
    print('\n--- 查找带style的span标签 ---')
    style_spans = re.findall(r'<span[^>]*style[^>]*>(.*?)</span>', content, re.DOTALL)
    print(f'找到 {len(style_spans)} 个带style的span')
    
    # 查找一个带style的span标签的完整内容
    print('\n--- 查找一个带style的span标签的完整内容 ---')
    match = re.search(r'(<span[^>]*style[^>]*>.*?</span>)', content, re.DOTALL)
    if match:
        print(match.group(1)[:500])

if __name__ == '__main__':
    main()
