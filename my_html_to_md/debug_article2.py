import re
import sys
sys.path.insert(0, '.trae/skills/wechat-html-to-markdown')

from convert import get_rich_media_content, parse_content_to_markdown

def main():
    html_file = 'raw/相信年轻人.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    print('提取rich_media_content...')
    content = get_rich_media_content(html_content)
    
    print(f'内容长度: {len(content)}')
    print(f'是否有<section>: {"<section" in content}')
    print(f'是否有<p>: {"<p" in content}')
    
    # 检查content的前500字符
    print(f'\n前500字符:\n{content[:500]}')
    
    # 直接尝试提取p标签
    print(f'\n直接提取p标签:')
    p_tags = re.findall(r'<p[^>]*>(.*?)</p>', content, re.DOTALL)
    print(f'找到 {len(p_tags)} 个p标签')
    
    for i, p in enumerate(p_tags[:5]):
        clean_text = re.sub(r'<[^>]+>', '', p)
        clean_text = clean_text.strip()
        print(f'{i+1}. {clean_text[:100]}')
    
    # 测试parse_content_to_markdown
    print(f'\n测试parse_content_to_markdown:')
    markdown = parse_content_to_markdown(content)
    print(f'生成的markdown长度: {len(markdown)}')
    print(f'前500字符:\n{markdown[:500]}')

if __name__ == '__main__':
    main()
