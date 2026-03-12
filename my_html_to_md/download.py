import os
import re
import urllib.request
from urllib.parse import urlparse


def extract_title(html_content, encoding='utf-8'):
    """从HTML内容中提取标题"""
    try:
        html_str = html_content.decode(encoding, errors='ignore')
        
        # 1. 首先尝试从微信公众号的meta标签中提取
        wechat_title_match = re.search(r'<meta\s+property="og:title"\s+content="([^"]+)"', html_str)
        if wechat_title_match:
            return wechat_title_match.group(1).strip()
        
        # 2. 尝试从微信公众号的title变量中提取
        wechat_title_var = re.search(r'var\s+title\s*=\s*"([^"]+)"', html_str)
        if wechat_title_var:
            return wechat_title_var.group(1).strip()
        
        # 3. 尝试从<title>标签中提取
        title_match = re.search(r'<title>([^<]+)</title>', html_str, re.IGNORECASE)
        if title_match:
            title = title_match.group(1).strip()
            # 移除常见的网站后缀
            title = re.sub(r'\s*[-|_]\s*.*$', '', title)
            return title
        
        # 4. 尝试从h1标签中提取
        h1_match = re.search(r'<h1[^>]*>([^<]+)</h1>', html_str, re.IGNORECASE | re.DOTALL)
        if h1_match:
            return h1_match.group(1).strip()
        
    except Exception:
        pass
    
    return None


def sanitize_filename(url, html_content=None, encoding='utf-8'):
    """从URL或HTML标题中提取并清理文件名"""
    # 首先尝试从HTML内容中提取标题
    if html_content:
        title = extract_title(html_content, encoding)
        if title:
            filename = sanitize_string(title)
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return filename
    
    # 如果没有HTML内容或提取不到标题，从URL中提取
    parsed = urlparse(url)
    
    # 尝试从路径中提取文件名
    path = parsed.path
    if path:
        # 获取路径的最后一部分
        filename = os.path.basename(path)
        if filename:
            # 如果没有扩展名，添加.html
            if not os.path.splitext(filename)[1]:
                filename += '.html'
            return sanitize_string(filename)
    
    # 如果路径中没有文件名，使用域名
    domain = parsed.netloc
    return sanitize_string(f'{domain}.html')


def sanitize_string(s):
    """清理文件名中的非法字符"""
    # 移除或替换非法字符
    s = re.sub(r'[<>:"/\\|?*]', '_', s)
    # 移除换行符和制表符
    s = re.sub(r'[\n\r\t]', ' ', s)
    # 合并多个空格
    s = re.sub(r'\s+', ' ', s)
    # 限制长度
    return s[:100].strip()


def download_html(url, output_dir='tmp_gen'):
    """从URL下载HTML文件"""
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    print(f'正在下载: {url}')
    
    try:
        # 设置User-Agent以避免被一些网站拒绝
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            html_content = response.read()
            
            # 检测编码
            content_type = response.headers.get('Content-Type', '')
            encoding = 'utf-8'
            
            if 'charset=' in content_type:
                charset = content_type.split('charset=')[-1]
                encoding = charset.strip()
            
            # 生成文件名（优先使用文章标题）
            filename = sanitize_filename(url, html_content, encoding)
            filepath = os.path.join(output_dir, filename)
            
            # 写入文件
            with open(filepath, 'wb') as f:
                f.write(html_content)
            
            print(f'下载成功! 已保存到: {filepath}')
            return filepath
            
    except Exception as e:
        print(f'下载失败: {str(e)}')
        return None


def main():
    """主函数 - 交互式下载"""
    import sys
    
    if len(sys.argv) > 1:
        # 从命令行参数获取URL
        url = sys.argv[1]
        download_html(url)
    else:
        # 交互式输入
        print('HTML 下载器')
        print('=' * 40)
        
        while True:
            url = input('\n请输入要下载的URL (输入 q 退出): ').strip()
            
            if url.lower() == 'q':
                print('再见!')
                break
            
            if not url:
                continue
            
            # 如果没有协议，添加https
            if not url.startswith(('http://', 'https://')):
                url = 'https://' + url
            
            download_html(url)


if __name__ == '__main__':
    main()
