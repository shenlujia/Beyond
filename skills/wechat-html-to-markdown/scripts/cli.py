#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
命令行入口模块
整合所有功能的统一命令行界面
"""

import os
import re
import sys
import json
import time
from datetime import datetime
from api_client import APIClient
from accounts import load_accounts, get_account, get_fakeid, add_account, save_accounts
from downloader import download_html
from html_parser import extract_author, extract_images, get_rich_media_content, extract_content_noencode
from markdown_converter import parse_content_to_markdown


def print_auth_error_help():
    """打印认证错误帮助信息"""
    print()
    print("=" * 60)
    print("⚠️  认证信息无效或已过期")
    print("=" * 60)
    print()
    print("请按以下步骤获取新的 auth-key:")
    print()
    print("1. 访问: https://down.mptext.top")
    print("2. 注册/登录账号")
    print("3. 获取新的 auth-key")
    print("4. 使用 --auth-key 参数重新运行命令")
    print()
    print("示例:")
    print("  python3 cli.py search <公众号名称> --auth-key <新的auth-key> --save")
    print("  python3 cli.py fetch-all-articles <公众号> --use-accounts --auth-key <新的auth-key>")
    print("=" * 60)
    print()


def get_timestamp_prefix():
    """生成时间戳前缀（只到日期）"""
    return datetime.now().strftime('%Y%m%d')


def process_html_file(file_path):
    """处理单个HTML文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    filename = os.path.basename(file_path)
    filename = os.path.splitext(filename)[0]
    
    author = extract_author(html_content)
    images = extract_images(html_content)
    
    content1 = get_rich_media_content(html_content)
    content2 = extract_content_noencode(html_content)
    
    def count_content_quality(c):
        p_count = len(re.findall(r'<p[^>]*>', c))
        text_length = len(re.sub(r'<[^>]+>', '', c))
        return p_count, text_length
    
    p1, t1 = count_content_quality(content1)
    p2, t2 = count_content_quality(content2)
    
    if p2 > p1 or t2 > t1 * 2:
        content = content2
    else:
        content = content1
    
    markdown_content = parse_content_to_markdown(content)
    
    is_gallery_article = 'picture_page_info_list' in html_content and not get_rich_media_content(html_content)
    
    markdown = f'# {filename}\n\n'
    markdown += f'作者：{author}\n\n'
    
    if is_gallery_article:
        for img_url in images:
            markdown += f'![图片]({img_url})\n\n'
    
    markdown += markdown_content
    
    return author, markdown


def convert_html_to_markdown():
    """转换功能的主函数"""
    skill_root = os.path.dirname(os.path.dirname(__file__))
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    raw_dir = os.path.join(skill_root, 'raw')
    tmp_gen_dir = os.path.join(skill_root, 'tmp_files')
    output_dir = os.path.join(project_root, 'docs')
    
    input_dir = None
    if os.path.exists(tmp_gen_dir):
        input_dir = tmp_gen_dir
    elif os.path.exists(raw_dir):
        input_dir = raw_dir
    else:
        print(f'错误: 找不到 {tmp_gen_dir} 或 {raw_dir} 文件夹')
        return
    
    html_files = [f for f in os.listdir(input_dir) if f.endswith('.html')]
    
    if not html_files:
        print(f'错误: {input_dir} 文件夹中没有HTML文件')
        return
    
    print(f'找到 {len(html_files)} 个HTML文件')
    
    for html_file in html_files:
        file_path = os.path.join(input_dir, html_file)
        print(f'处理: {html_file}')
        
        try:
            author, markdown = process_html_file(file_path)
            
            author_dir = os.path.join(output_dir, author)
            os.makedirs(author_dir, exist_ok=True)
            
            filename = os.path.splitext(html_file)[0]
            timestamp_prefix = get_timestamp_prefix()
            md_file = os.path.join(author_dir, f'{timestamp_prefix}_{filename}.md')
            
            with open(md_file, 'w', encoding='utf-8') as f:
                f.write(markdown)
            
            print(f'  已保存到: {md_file}')
        except Exception as e:
            print(f'  错误: {e}')
            import traceback
            traceback.print_exc()
    
    print('转换完成!')


def search_accounts(keyword: str, auth_key: str = None, save: bool = False):
    """搜索公众号"""
    client = APIClient(auth_key)
    result = client.search_account(keyword)
    
    base_resp = result.get('base_resp', {})
    if base_resp.get('is_auth_error', False):
        print_auth_error_help()
        return
    
    if base_resp.get('ret') == 0:
        accounts_list = result.get('list', [])
        print(f"找到 {result.get('total', 0)} 个公众号:")
        for i, account in enumerate(accounts_list, 1):
            print(f"\n{i}. {account.get('nickname')}")
            print(f"   fakeid: {account.get('fakeid')}")
            print(f"   别名: {account.get('alias', '')}")
            print(f"   简介: {account.get('signature', '')}")
        
        if save and accounts_list:
            first_account = accounts_list[0]
            nickname = first_account.get('nickname', '')
            account_info = {
                'nickname': nickname,
                'fakeid': first_account.get('fakeid', ''),
                'alias': first_account.get('alias', ''),
                'signature': first_account.get('signature', '')
            }
            if add_account(nickname, account_info):
                print(f"\n已保存到 accounts.json: {nickname}")
            else:
                print(f"\n保存失败")
    else:
        print(f"查询失败: {base_resp.get('err_msg', '未知错误')}")


def fetch_article_list(fakeid: str, begin: int = 0, size: int = 5, auth_key: str = None):
    """获取文章列表"""
    client = APIClient(auth_key)
    result = client.fetch_articles(fakeid, begin, size)
    
    base_resp = result.get('base_resp', {})
    if base_resp.get('is_auth_error', False):
        print_auth_error_help()
        return
    
    if base_resp.get('ret') == 0:
        articles = result.get('articles', [])
        print(f"\n找到 {len(articles)} 篇文章:")
        for i, article in enumerate(articles, 1):
            print(f"\n{i}. {article.get('title')}")
            print(f"   作者: {article.get('author_name', '')}")
            print(f"   链接: {article.get('link')}")
            create_time = article.get('create_time')
            if create_time:
                print(f"   时间: {datetime.fromtimestamp(create_time)}")
    else:
        print(f"\n获取失败: {base_resp.get('err_msg', '未知错误')}")


def fetch_all_articles(author_name: str, use_accounts: bool = False, auth_key: str = None, batch_size: int = 5, interval: float = 3.0):
    """
    批量获取所有文章 - 优化版本
    
    优化逻辑：
    1. 第一次调用优先拉取最新文章列表，即索引为0，文章数5
    2. 接口返回数据，不要直接写到本地缓存，应该先记到数据结构X
    3. 如果X与本地缓存没有交集，则下次接口调用 索引 = X数量-1
    4. 如果X与本地缓存有交集，按顺序合并X与本地缓存，最新内容放最上面，下次接口调用 索引 = X数量-1
    5. 不断重复，直到文章列表下载完成
    """
    fakeid = None
    if use_accounts:
        fakeid = get_fakeid(author_name)
        if not fakeid:
            print(f"错误: 在 accounts.json 中找不到 '{author_name}' 的 fakeid")
            return
        print(f"从 accounts.json 获取 fakeid: {fakeid}")
    else:
        print("请提供 fakeid 或使用 --use-accounts")
        return
    
    client = APIClient(auth_key)
    
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    output_dir = os.path.join(project_root, 'docs')
    author_dir = os.path.join(output_dir, author_name)
    os.makedirs(author_dir, exist_ok=True)
    output_file = os.path.join(author_dir, 'articles.json')
    
    existing_articles = []
    existing_aids = set()
    
    if os.path.exists(output_file):
        print(f'读取本地文件: {output_file}')
        try:
            with open(output_file, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
                existing_articles = existing_data.get('articles', [])
                existing_aids = {a.get('aid') for a in existing_articles if a.get('aid')}
                print(f'  已有 {len(existing_articles)} 篇文章')
        except Exception as e:
            print(f'  读取失败: {e}')
    
    data_x = []
    data_x_aids = set()
    batch = 1
    begin = 0
    
    print()
    print(f'开始批量获取文章...')
    print(f'  作者: {author_name}')
    print(f'  每次获取: {batch_size} 篇')
    print(f'  调用间隔: {interval} 秒')
    print()
    
    while True:
        print(f'第 {batch} 次获取 (begin={begin})...')
        result = client.fetch_articles(fakeid, begin, batch_size)
        
        base_resp = result.get('base_resp', {})
        if base_resp.get('is_auth_error', False):
            print_auth_error_help()
            return
        
        if base_resp.get('ret') != 0:
            print(f'  获取失败: {base_resp.get("err_msg", "未知错误")}')
            break
        
        articles = result.get('articles', [])
        if not articles:
            print('  没有更多文章了')
            break
        
        print(f'  获取到 {len(articles)} 篇')
        
        has_intersection = False
        for article in articles:
            aid = article.get('aid')
            if aid and aid in existing_aids:
                has_intersection = True
                break
        
        if has_intersection:
            print('  检测到与本地缓存有交集，开始合并...')
        else:
            print('  未检测到与本地缓存的交集')
        
        for article in articles:
            aid = article.get('aid')
            if aid and aid not in data_x_aids:
                data_x.append(article)
                data_x_aids.add(aid)
        
        print(f'  数据结构X当前数量: {len(data_x)} 篇')
        
        if len(articles) < batch_size:
            print('  已获取全部文章')
            break
        
        begin = len(data_x) - 1
        print(f'  下次调用索引: {begin}')
        print(f'  等待 {interval} 秒...')
        time.sleep(interval)
        batch += 1
        print()
    
    print()
    print('合并数据结构X与本地缓存...')
    
    merged_articles = []
    merged_aids = set()
    
    for article in data_x:
        aid = article.get('aid')
        if aid and aid not in merged_aids:
            merged_articles.append(article)
            merged_aids.add(aid)
    
    for article in existing_articles:
        aid = article.get('aid')
        if aid and aid not in merged_aids:
            merged_articles.append(article)
            merged_aids.add(aid)
    
    print()
    print(f'合并后共 {len(merged_articles)} 篇文章')
    
    print()
    print('按时间降序排序（最新文章在前）...')
    merged_articles.sort(key=lambda x: x.get('create_time', 0), reverse=True)
    
    article_names = [article.get('title', '') for article in merged_articles]
    
    result_data = {
        'all_names': article_names,
        'articles': merged_articles
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result_data, f, ensure_ascii=False, indent=2)
    
    print()
    print(f'已保存到: {output_file}')


def download_single_article(url: str, format: str = 'html', save: bool = False):
    """下载单篇文章"""
    client = APIClient()
    result = client.download_article(url, format)
    
    if result.get('base_resp', {}).get('ret') == 0:
        if save:
            skill_root = os.path.dirname(os.path.dirname(__file__))
            output_dir = os.path.join(skill_root, 'tmp_files')
            os.makedirs(output_dir, exist_ok=True)
            
            content = result.get('content', '')
            if not content and format == 'json':
                content = json.dumps(result, ensure_ascii=False, indent=2)
            
            filename = f"article_{hash(url) % 10000}.{format}"
            filepath = os.path.join(output_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"\n下载成功! 已保存到: {filepath}")
        else:
            print(f"\n下载成功!")
            if 'content' in result:
                print(f"\n内容预览 (前500字符):\n{result['content'][:500]}...")
            else:
                print(f"\n完整内容:\n{json.dumps(result, ensure_ascii=False, indent=2)}")
    else:
        print(f"\n下载失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")


def print_usage():
    """打印使用说明"""
    print("使用方法:")
    print("  python3 cli.py download <URL>                                    - 下载HTML文件")
    print("  python3 cli.py convert                                          - 转换HTML为Markdown")
    print("  python3 cli.py search <公众号名称> [--save]                     - 搜索公众号")
    print("  python3 cli.py search --auth-key <auth-key> <公众号名称> --save")
    print("  python3 cli.py fetch-articles <fakeid> [begin] [size] [--auth-key <auth-key>]")
    print("  python3 cli.py fetch-all-articles <公众号> --use-accounts [选项] - 批量获取所有文章")
    print("  python3 cli.py download-article <url> [format] [--save]       - 下载文章内容")
    print("\n说明: auth-key 需要从 https://down.mptext.top 获取")


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print_usage()
        return
    
    cmd = sys.argv[1]
    
    if cmd == 'download' and len(sys.argv) > 2:
        download_html(sys.argv[2])
    elif cmd == 'convert':
        convert_html_to_markdown()
    elif cmd == 'search':
        auth_key = None
        keyword = None
        save = False
        i = 2
        while i < len(sys.argv):
            arg = sys.argv[i]
            if arg in ['--auth-key', '-k'] and i + 1 < len(sys.argv):
                auth_key = sys.argv[i + 1]
                i += 2
            elif arg == '--save':
                save = True
                i += 1
            elif not keyword:
                keyword = arg
                i += 1
            else:
                i += 1
        if keyword:
            search_accounts(keyword, auth_key, save)
        else:
            print("请提供公众号名称")
    elif cmd == 'fetch-articles':
        auth_key = None
        fakeid = None
        begin = 0
        size = 5
        i = 2
        while i < len(sys.argv):
            arg = sys.argv[i]
            if arg in ['--auth-key', '-k'] and i + 1 < len(sys.argv):
                auth_key = sys.argv[i + 1]
                i += 2
            elif not fakeid:
                fakeid = arg
                i += 1
            elif fakeid and i == 3:
                begin = int(arg)
                i += 1
            elif fakeid and i == 4:
                size = int(arg)
                i += 1
            else:
                i += 1
        if fakeid:
            fetch_article_list(fakeid, begin, size, auth_key)
        else:
            print("请提供 fakeid")
    elif cmd == 'fetch-all-articles':
        auth_key = None
        author_name = None
        batch_size = 10
        interval = 3.0
        use_accounts = False
        i = 2
        while i < len(sys.argv):
            arg = sys.argv[i]
            if arg in ['--auth-key', '-k'] and i + 1 < len(sys.argv):
                auth_key = sys.argv[i + 1]
                i += 2
            elif arg in ['--batch', '-b'] and i + 1 < len(sys.argv):
                batch_size = int(sys.argv[i + 1])
                i += 2
            elif arg in ['--interval', '-i'] and i + 1 < len(sys.argv):
                interval = float(sys.argv[i + 1])
                i += 2
            elif arg == '--use-accounts':
                use_accounts = True
                i += 1
            elif not author_name:
                author_name = arg
                i += 1
            else:
                i += 1
        if author_name:
            fetch_all_articles(author_name, use_accounts, auth_key, batch_size, interval)
        else:
            print("请提供公众号名称")
    elif cmd == 'download-article':
        url = None
        format = 'html'
        save = False
        i = 2
        while i < len(sys.argv):
            arg = sys.argv[i]
            if arg == '--save':
                save = True
                i += 1
            elif not url:
                url = arg
                i += 1
            elif url and not save:
                format = arg
                i += 1
            else:
                i += 1
        if url:
            download_single_article(url, format, save)
        else:
            print("请提供文章URL")
    elif cmd.startswith(('http://', 'https://')):
        download_html(cmd)
    else:
        convert_html_to_markdown()


if __name__ == '__main__':
    main()
