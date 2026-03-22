import os
import re
import urllib.request
from urllib.parse import urlparse


def extract_title(html_content, encoding='utf-8'):
    """从HTML内容中提取标题"""
    try:
        html_str = html_content.decode(encoding, errors='ignore')
        
        wechat_title_match = re.search(r'<meta\s+property="og:title"\s+content="([^"]+)"', html_str)
        if wechat_title_match:
            return wechat_title_match.group(1).strip()
        
        wechat_title_var = re.search(r'var\s+title\s*=\s*"([^"]+)"', html_str)
        if wechat_title_var:
            return wechat_title_var.group(1).strip()
        
        title_match = re.search(r'<title>([^<]+)</title>', html_str, re.IGNORECASE)
        if title_match:
            title = title_match.group(1).strip()
            title = re.sub(r'\s*[-|_]\s*.*$', '', title)
            return title
        
        h1_match = re.search(r'<h1[^>]*>([^<]+)</h1>', html_str, re.IGNORECASE | re.DOTALL)
        if h1_match:
            return h1_match.group(1).strip()
        
    except Exception:
        pass
    
    return None


def sanitize_filename(url, html_content=None, encoding='utf-8'):
    """从URL或HTML标题中提取并清理文件名"""
    if html_content:
        title = extract_title(html_content, encoding)
        if title:
            filename = sanitize_string(title)
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return filename
    
    parsed = urlparse(url)
    path = parsed.path
    if path:
        filename = os.path.basename(path)
        if filename:
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return sanitize_string(filename)
    
    domain = parsed.netloc
    return sanitize_string(f'{domain}.html')


def sanitize_string(s):
    """清理文件名中的非法字符"""
    s = re.sub(r'[<>:"/\\\\|?*]', '_', s)
    s = re.sub(r'[\\n\\r\\t]', ' ', s)
    s = re.sub(r'\\s+', ' ', s)
    return s[:100].strip()


def download_html(url, output_dir='tmp_gen'):
    """从URL下载HTML文件"""
    os.makedirs(output_dir, exist_ok=True)
    
    print(f'正在下载: {url}')
    
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            html_content = response.read()
            
            content_type = response.headers.get('Content-Type', '')
            encoding = 'utf-8'
            
            if 'charset=' in content_type:
                charset = content_type.split('charset=')[-1]
                encoding = charset.strip()
            
            filename = sanitize_filename(url, html_content, encoding)
            filepath = os.path.join(output_dir, filename)
            
            with open(filepath, 'wb') as f:
                f.write(html_content)
            
            print(f'下载成功! 已保存到: {filepath}')
            return filepath
            
    except Exception as e:
        print(f'下载失败: {str(e)}')
        return None
