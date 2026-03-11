import re

def main():
    html_file = 'raw/美国打伊朗，比特币为何暴跌？.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 查找带color的span或p标签
    print('--- 查找带color的标签 ---')
    
    # 查找p标签带color的
    p_tags = re.findall(r'<p[^>]*color[^>]*>.*?</p>', content, re.DOTALL)
    print(f'找到 {len(p_tags)} 个带color的p标签')
    for i, p in enumerate(p_tags[:3]):
        print(f'{i+1}. {p[:300]}')
    
    # 查找span标签带color的
    span_tags = re.findall(r'<span[^>]*color[^>]*>.*?</span>', content, re.DOTALL)
    print(f'\n找到 {len(span_tags)} 个带color的span标签')
    for i, span in enumerate(span_tags[:5]):
        print(f'{i+1}. {span[:200]}')

if __name__ == '__main__':
    main()
