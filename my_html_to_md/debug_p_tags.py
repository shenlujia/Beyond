import re

def main():
    with open('temp/temp.txt', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 找到所有的p标签
    p_tags = re.findall(r'<p[^>]*>(.*?)</p>', content, re.DOTALL)
    
    print(f'找到 {len(p_tags)} 个p标签')
    print('\n前20个p标签的内容:')
    for i, p in enumerate(p_tags[:20]):
        # 提取leaf标签的内容
        leaf_matches = re.findall(r'<span[^>]*leaf[^>]*>(.*?)</span>', p, re.DOTALL)
        text_parts = []
        for leaf in leaf_matches:
            text = re.sub(r'<[^>]+>', '', leaf)
            text = text.strip()
            if text:
                text_parts.append(text)
        
        print(f'{i+1}. {" ".join(text_parts)}')

if __name__ == '__main__':
    main()
