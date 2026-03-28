#!/usr/bin/env python3
"""
下载 HTML 页面的脚本
"""

import sys
import os
import time
import argparse
import urllib.request
import urllib.error
import re


def extract_tid_and_page(url: str) -> tuple:
    """
    从 URL 中提取 tid 和 page
    
    Args:
        url: URL 字符串
        
    Returns:
        (tid, page) 元组
    """
    tid_match = re.search(r'[?&]tid=(\d+)', url)
    page_match = re.search(r'[?&]page=(\d+)', url)
    
    tid = tid_match.group(1) if tid_match else None
    page = int(page_match.group(1)) if page_match else 1
    
    return tid, page


def extract_filename_from_url(url: str) -> str:
    """
    从 URL 中提取文件名
    
    Args:
        url: URL 字符串
        
    Returns:
        文件名
    """
    filename_match = re.search(r'/([^/]+\.html?)$', url, re.IGNORECASE)
    if filename_match:
        return filename_match.group(1)
    return 'downloaded.html'


def get_cookie_file_path() -> str:
    """
    获取 cookie 文件路径
    
    Returns:
        cookie 文件路径
    """
    skill_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tmp_files_dir = os.path.join(skill_dir, 'tmp_files')
    os.makedirs(tmp_files_dir, exist_ok=True)
    return os.path.join(tmp_files_dir, 'cookie.txt')


def save_cookie(cookie_str: str):
    """
    保存 cookie 到临时文件
    
    Args:
        cookie_str: Cookie 字符串
    """
    if not cookie_str:
        return
    
    cookie_file = get_cookie_file_path()
    try:
        with open(cookie_file, 'w', encoding='utf-8') as f:
            f.write(cookie_str)
        print(f"Cookie 已保存到: {cookie_file}")
    except Exception as e:
        print(f"保存 Cookie 失败: {e}")


def load_cookie() -> str:
    """
    从临时文件读取 cookie
    
    Returns:
        Cookie 字符串，失败返回空字符串
    """
    cookie_file = get_cookie_file_path()
    if not os.path.exists(cookie_file):
        return ""
    
    try:
        with open(cookie_file, 'r', encoding='utf-8') as f:
            cookie_str = f.read().strip()
        if cookie_str:
            print(f"已从文件读取 Cookie: {cookie_file}")
        return cookie_str
    except Exception as e:
        print(f"读取 Cookie 失败: {e}")
        return ""


def download_single_file(url: str, cookie_str: str, output_dir: str = 'htmls') -> bool:
    """
    下载单个 HTML 文件（如果文件已存在则跳过）
    
    Args:
        url: URL
        cookie_str: Cookie 字符串
        output_dir: 输出目录
        
    Returns:
        是否成功
    """
    os.makedirs(output_dir, exist_ok=True)
    
    filename = extract_filename_from_url(url)
    output_path = os.path.join(output_dir, filename)
    
    if os.path.exists(output_path):
        print(f"文件已存在，跳过下载: {output_path}")
        return True
    
    return download_page(url, cookie_str, output_path)


def extract_total_pages(html: str) -> int:
    """
    从 HTML 中提取总页数
    
    Args:
        html: HTML 内容
        
    Returns:
        总页数，失败返回 None
    """
    match = re.search(r'<a[^>]*href="[^"]*[?&](?:amp;)?page=(\d+)"[^>]*id="last"', html)
    if match:
        return int(match.group(1))
    return None


def download_page(url: str, cookie_str: str, output_path: str) -> bool:
    """
    下载单个页面（如果文件已存在则跳过）
    
    Args:
        url: 页面 URL
        cookie_str: Cookie 字符串
        output_path: 输出文件路径
        
    Returns:
        是否成功
    """
    if os.path.exists(output_path):
        print(f"文件已存在，跳过下载: {output_path}")
        return True
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Cookie': cookie_str
    }
    
    try:
        print(f"正在下载: {url}")
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            content = response.read()
            charset = response.headers.get_content_charset() or 'utf-8'
            html = content.decode(charset, errors='replace')
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"已保存到: {output_path}")
        return True
    except urllib.error.HTTPError as e:
        print(f"HTTP 错误 {e.code}: {e.reason}")
        return False
    except urllib.error.URLError as e:
        print(f"URL 错误: {e.reason}")
        return False
    except Exception as e:
        print(f"下载失败: {e}")
        return False


def main():
    """
    主函数
    """
    parser = argparse.ArgumentParser(description="下载 HTML 页面")
    parser.add_argument("--url", required=True, help="URL (单文件) 或基础 URL (多页，{} 会被替换为页码)")
    parser.add_argument("--single", action="store_true", help="单文件下载模式")
    parser.add_argument("--start", type=int, default=1, help="起始页码 (默认: 1)")
    parser.add_argument("--end", type=int, default=None, help="结束页码 (默认: 自动从第1页解析)")
    parser.add_argument("--cookies", default="", help="Cookie 字符串 (可选，如果不提供则从 tmp_files/cookie.txt 读取)")
    parser.add_argument("--output-dir", default="tmp_files/htmls", help="输出目录 (默认: tmp_files/htmls)")
    
    args = parser.parse_args()
    
    if not args.single and 'toread' not in args.url:
        print("错误: 链接必须包含 toread 参数")
        return 1
    
    os.makedirs(args.output_dir, exist_ok=True)
    
    cookie_str = args.cookies
    if not cookie_str:
        cookie_str = load_cookie()
    
    if args.cookies:
        save_cookie(args.cookies)
    
    if args.single:
        if download_single_file(args.url, cookie_str, args.output_dir):
            return 0
        else:
            return 1
    
    if args.end is None:
        print("自动检测总页数...")
        first_url = args.url.format(1)
        html = download_page_for_detect(first_url, cookie_str)
        if html:
            total_pages = extract_total_pages(html)
            if total_pages:
                args.end = total_pages
                print(f"检测到总页数: {total_pages}")
            else:
                print("警告: 无法检测总页数，默认下载 1 页")
                args.end = 1
        else:
            print("警告: 无法下载第1页来检测总页数，默认下载 1 页")
            args.end = 1
        print()
    
    success_count = 0
    total_pages = args.end - args.start + 1
    for page in range(args.start, args.end + 1):
        url = args.url.format(page)
        tid, _ = extract_tid_and_page(url)
        
        if tid is None:
            print(f"警告: 无法从 URL 中提取 tid: {url}")
            continue
        
        page_str = f"{page:06d}"
        filename = f"{tid}_{page_str}.html"
        output_path = os.path.join(args.output_dir, filename)
        
        if download_page(url, cookie_str, output_path):
            success_count += 1
        print()
        
        if page < args.end:
            time.sleep(1)
    
    print(f"完成！成功下载 {success_count}/{args.end - args.start + 1} 个页面")
    return 0 if success_count > 0 else 1


def download_page_for_detect(url: str, cookie_str: str) -> str:
    """
    下载页面用于检测总页数（不保存文件）
    
    Args:
        url: 页面 URL
        cookie_str: Cookie 字符串
        
    Returns:
        HTML 内容，失败返回 None
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Cookie': cookie_str
    }
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=30) as response:
            content = response.read()
            charset = response.headers.get_content_charset() or 'utf-8'
            return content.decode(charset, errors='replace')
    except Exception:
        return None


if __name__ == "__main__":
    sys.exit(main())