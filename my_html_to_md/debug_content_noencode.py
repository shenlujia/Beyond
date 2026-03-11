import re

def js_decode(s):
    """JavaScript解码函数"""
    if not s:
        return s
    s = s.replace(r'\x5c', '\\')
    s = s.replace(r'\x0d', '\r')
    s = s.replace(r'\x22', '"')
    s = s.replace(r'\x26', '&')
    s = s.replace(r'\x27', "'")
    s = s.replace(r'\x3c', '<')
    s = s.replace(r'\x3e', '>')
    s = s.replace(r'\x0a', '\n')
    return s

def extract_content_noencode(html_content):
    """从JavaScript中提取content_noencode"""
    match = re.search(r'content_noencode:\s*JsDecode\((.*?)\),', html_content, re.DOTALL)
    if match:
        encoded_str = match.group(1)
        if encoded_str.startswith("'") and encoded_str.endswith("'"):
            encoded_str = encoded_str[1:-1]
        elif encoded_str.startswith('"') and encoded_str.endswith('"'):
            encoded_str = encoded_str[1:-1]
        return js_decode(encoded_str)
    return ''

def main():
    file_path = 'raw/美国打伊朗，比特币为何暴跌？.html'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    content = extract_content_noencode(html_content)
    
    print('content_noencode中的leaf标签内容（前30个）:')
    
    leaf_matches = re.findall(r'<span[^>]*leaf[^>]*>(.*?)</span>', content, re.DOTALL)
    
    for i, leaf in enumerate(leaf_matches[:30]):
        text = re.sub(r'<[^>]+>', '', leaf)
        text = text.strip()
        if text:
            print(f'{i+1}. {text}')

if __name__ == '__main__':
    main()
