import os
import re
from datetime import datetime
from downloader import download_html
from html_parser import extract_author, extract_images, get_rich_media_content, extract_content_noencode
from markdown_converter import parse_content_to_markdown
from wechat_account_finder import search_wechat_account
from article_fetcher import fetch_wechat_articles, fetch_and_save_all_wechat_articles
from article_downloader import download_wechat_article, save_article_to_file
from accounts import get_fakeid


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


def main_convert():
    """转换功能的主函数"""
    raw_dir = 'raw'
    tmp_gen_dir = 'tmp_gen'
    output_dir = 'docs'
    
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


def main_search_account():
    """搜索公众号功能的主函数"""
    import sys
    from accounts import add_account
    
    auth_key = None
    keyword = None
    save = False
    
    if len(sys.argv) > 2:
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
    
    if not keyword:
        print("使用方法:")
        print("  python3 main.py search <公众号名称> [--save] [--auth-key <auth-key>]")
        print("  python3 main.py search -k <auth-key> <公众号名称> --save")
        print("\n选项:")
        print("  --save              保存第一个找到的公众号到 accounts.json")
        print("\n说明: auth-key 需要从 https://down.mptext.top 获取")
        return
    
    print(f"搜索公众号: {keyword}")
    if auth_key:
        print("使用提供的 auth-key 进行鉴权")
    if save:
        print("将保存第一个找到的公众号")
    
    result = search_wechat_account(keyword, auth_key=auth_key)
    
    if result.get('base_resp', {}).get('ret') == 0:
        accounts = result.get('list', [])
        print(f"找到 {result.get('total', 0)} 个公众号:")
        for i, account in enumerate(accounts, 1):
            print(f"\n{i}. {account.get('nickname')}")
            print(f"   fakeid: {account.get('fakeid')}")
            print(f"   别名: {account.get('alias', '')}")
            print(f"   简介: {account.get('signature', '')}")
        
        if save and accounts:
            first_account = accounts[0]
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
        print(f"查询失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
        print("\n提示: 此接口需要 auth-key 鉴权，请访问 https://down.mptext.top 获取")


def main_fetch_articles():
    """获取文章列表功能的主函数"""
    import sys
    
    auth_key = None
    fakeid = None
    begin = 0
    size = 5
    
    if len(sys.argv) > 2:
        fakeid = sys.argv[2]
        if len(sys.argv) > 3:
            if sys.argv[3] in ['--auth-key', '-k'] and len(sys.argv) > 5:
                auth_key = sys.argv[4]
                begin = int(sys.argv[5]) if len(sys.argv) > 5 else 0
                size = int(sys.argv[6]) if len(sys.argv) > 6 else 5
            else:
                begin = int(sys.argv[3]) if len(sys.argv) > 3 else 0
                size = int(sys.argv[4]) if len(sys.argv) > 4 else 5
                if len(sys.argv) > 5 and sys.argv[5] in ['--auth-key', '-k'] and len(sys.argv) > 6:
                    auth_key = sys.argv[6]
    
    if not fakeid:
        print("使用方法:")
        print("  python3 main.py fetch-articles <fakeid> [begin] [size] [--auth-key <auth-key>]")
        print("\n示例:")
        print("  python3 main.py fetch-articles MzA3NzAyMzMyMA==")
        print("  python3 main.py fetch-articles MzA3NzAyMzMyMA== 0 10 --auth-key <auth-key>")
        print("\n说明: fakeid 可通过 search 命令获取")
        return
    
    print(f"获取文章列表: fakeid={fakeid}, begin={begin}, size={size}")
    if auth_key:
        print("使用提供的 auth-key 进行鉴权")
    
    result = fetch_wechat_articles(fakeid, begin, size, auth_key)
    
    if result.get('base_resp', {}).get('ret') == 0:
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
        print(f"\n获取失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
        print("\n提示: 此接口需要 auth-key 鉴权，请访问 https://down.mptext.top 获取")


def main_download_article():
    """下载文章功能的主函数"""
    import sys
    
    url = None
    format = 'html'
    save = False
    
    if len(sys.argv) > 2:
        url = sys.argv[2]
        if len(sys.argv) > 3:
            if sys.argv[3] == '--save':
                save = True
                if len(sys.argv) > 4:
                    format = sys.argv[4]
            elif sys.argv[3] != '--save':
                format = sys.argv[3]
                if len(sys.argv) > 4 and sys.argv[4] == '--save':
                    save = True
    
    if not url:
        print("使用方法:")
        print("  python3 main.py download-article <url> [format] [--save]")
        print("\n格式选项: html, markdown, text, json (默认: html)")
        print("\n示例:")
        print("  python3 main.py download-article https://mp.weixin.qq.com/s/xxx")
        print("  python3 main.py download-article https://mp.weixin.qq.com/s/xxx markdown")
        print("  python3 main.py download-article https://mp.weixin.qq.com/s/xxx html --save")
        print("\n说明: 此接口不需要 auth-key")
        return
    
    print(f"下载文章: {url}")
    print(f"格式: {format}")
    
    if save:
        filepath = save_article_to_file(url, format)
        if filepath:
            print(f"\n下载成功! 已保存到: {filepath}")
        else:
            print(f"\n下载失败!")
    else:
        result = download_wechat_article(url, format)
        if result.get('base_resp', {}).get('ret') == 0:
            print(f"\n下载成功!")
            if 'content' in result:
                print(f"\n内容预览 (前500字符):\n{result['content'][:500]}...")
            else:
                import json
                print(f"\n完整内容:\n{json.dumps(result, ensure_ascii=False, indent=2)}")
        else:
            print(f"\n下载失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")


def main_fetch_all_articles():
    """批量获取所有文章并保存的主函数"""
    import sys
    
    auth_key = None
    author_name = None
    batch_size = 5
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
    
    if not author_name:
        print("使用方法:")
        print("  python3 main.py fetch-all-articles <公众号名称> [选项]")
        print("\n选项:")
        print("  --use-accounts        使用 accounts.json 中的 fakeid")
        print("  --auth-key, -k <key>  鉴权密钥")
        print("  --batch, -b <num>     每次获取文章数 (默认: 10)")
        print("  --interval, -i <sec>  调用间隔秒数 (默认: 3.0)")
        print("\n示例:")
        print("  python3 main.py fetch-all-articles 晚点LatePost --use-accounts")
        print("  python3 main.py fetch-all-articles 晚点LatePost --use-accounts --batch 10 --interval 3")
        print("\n说明:")
        print("  - 如果不使用 --use-accounts，需要先通过 search 命令获取 fakeid")
        print("  - 或者先将公众号信息添加到 accounts.json")
        return
    
    fakeid = None
    if use_accounts:
        fakeid = get_fakeid(author_name)
        if not fakeid:
            print(f"错误: 在 accounts.json 中找不到 '{author_name}' 的 fakeid")
            print("请先使用 search 命令查询并添加到 accounts.json")
            return
        print(f"从 accounts.json 获取 fakeid: {fakeid}")
    else:
        print("请提供 fakeid 或使用 --use-accounts")
        return
    
    print()
    fetch_and_save_all_wechat_articles(
        fakeid=fakeid,
        author_name=author_name,
        batch_size=batch_size,
        interval=interval,
        auth_key=auth_key
    )


def main():
    """主函数 - 根据参数选择功能"""
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == 'download' and len(sys.argv) > 2:
            url = sys.argv[2]
            download_html(url)
        elif sys.argv[1] == 'convert':
            main_convert()
        elif sys.argv[1] == 'search':
            main_search_account()
        elif sys.argv[1] == 'fetch-articles':
            main_fetch_articles()
        elif sys.argv[1] == 'fetch-all-articles':
            main_fetch_all_articles()
        elif sys.argv[1] == 'download-article':
            main_download_article()
        elif sys.argv[1].startswith(('http://', 'https://')):
            url = sys.argv[1]
            download_html(url)
        else:
            main_convert()
    else:
        print("使用方法:")
        print("  python3 main.py download <URL>                                    - 下载HTML文件")
        print("  python3 main.py convert                                          - 转换HTML为Markdown")
        print("  python3 main.py search <公众号名称> [--save]                     - 搜索公众号")
        print("  python3 main.py search --auth-key <auth-key> <公众号名称> --save")
        print("  python3 main.py fetch-articles <fakeid> [begin] [size] [--auth-key <auth-key>]")
        print("  python3 main.py fetch-all-articles <公众号> --use-accounts [选项] - 批量获取所有文章")
        print("  python3 main.py download-article <url> [format] [--save]       - 下载文章内容")
        print("\n说明: auth-key 需要从 https://down.mptext.top 获取")


if __name__ == '__main__':
    main()
