#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
微信公众号文章下载模块
基于原工程 wechat-article-exporter 的逻辑实现
支持 HTML、Markdown、Text、JSON 格式
"""

import json
import urllib.request
import urllib.parse
from typing import Optional, Dict, Any
from config import BASE_URL_DOWNLOAD


class ArticleDownloader:
    """
    微信公众号文章下载器
    """
    
    BASE_URL = BASE_URL_DOWNLOAD
    
    def __init__(self):
        """
        初始化文章下载器
        注意：此接口不需要 auth-key
        """
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
    
    def download(
        self, 
        url: str, 
        format: str = 'html'
    ) -> Dict[str, Any]:
        """
        下载文章内容
        
        Args:
            url: 微信公众号文章链接
            format: 输出格式，支持 html/markdown/text/json
            
        Returns:
            包含文章内容的字典
        """
        format = format.lower()
        if format not in ['html', 'markdown', 'text', 'json']:
            return {
                'base_resp': {
                    'ret': -1,
                    'err_msg': '不支持的格式，支持 html/markdown/text/json'
                }
            }
        
        params = {
            'url': url,
            'format': format
        }
        
        try:
            url_encoded = f"{self.BASE_URL}?{urllib.parse.urlencode(params)}"
            req = urllib.request.Request(url_encoded, headers=self.headers)
            
            with urllib.request.urlopen(req, timeout=30) as response:
                content_type = response.getheader('Content-Type', '')
                
                if 'application/json' in content_type or format == 'json':
                    data = response.read().decode('utf-8')
                    return json.loads(data)
                else:
                    data = response.read().decode('utf-8')
                    return {
                        'base_resp': {'ret': 0, 'err_msg': 'ok'},
                        'format': format,
                        'content': data
                    }
        except Exception as e:
            return {
                'base_resp': {
                    'ret': -1, 
                    'err_msg': f'下载失败: {str(e)}'
                }
            }
    
    def download_html(self, url: str) -> Dict[str, Any]:
        """下载 HTML 格式"""
        return self.download(url, 'html')
    
    def download_markdown(self, url: str) -> Dict[str, Any]:
        """下载 Markdown 格式"""
        return self.download(url, 'markdown')
    
    def download_text(self, url: str) -> Dict[str, Any]:
        """下载纯文本格式"""
        return self.download(url, 'text')
    
    def download_json(self, url: str) -> Dict[str, Any]:
        """下载 JSON 格式（包含 cgiDataNew 数据）"""
        return self.download(url, 'json')


def download_wechat_article(
    url: str, 
    format: str = 'html'
) -> Dict[str, Any]:
    """
    便捷函数：下载微信公众号文章
    
    Args:
        url: 文章链接
        format: 输出格式
        
    Returns:
        文章内容
    """
    downloader = ArticleDownloader()
    return downloader.download(url, format)


def save_article_to_file(
    url: str, 
    format: str = 'html', 
    output_dir: str = 'tmp_gen'
) -> Optional[str]:
    """
    下载文章并保存到文件
    
    Args:
        url: 文章链接
        format: 输出格式
        output_dir: 输出目录
        
    Returns:
        保存的文件路径，失败返回 None
    """
    import os
    
    result = download_wechat_article(url, format)
    
    if result.get('base_resp', {}).get('ret') != 0:
        return None
    
    os.makedirs(output_dir, exist_ok=True)
    
    content = result.get('content', '')
    if not content and format == 'json':
        content = json.dumps(result, ensure_ascii=False, indent=2)
    
    filename = f"article_{hash(url) % 10000}.{format}"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filepath


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python3 article_downloader.py <url> [format]")
        print("\n格式选项: html, markdown, text, json (默认: html)")
        print("\n示例:")
        print("  python3 article_downloader.py https://mp.weixin.qq.com/s/xxx")
        print("  python3 article_downloader.py https://mp.weixin.qq.com/s/xxx markdown")
        sys.exit(1)
    
    url = sys.argv[1]
    format = sys.argv[2] if len(sys.argv) > 2 else 'html'
    
    result = download_wechat_article(url, format)
    
    if result.get('base_resp', {}).get('ret') == 0:
        print(f"下载成功! 格式: {format}")
        if 'content' in result:
            print(f"\n内容预览 (前500字符):\n{result['content'][:500]}...")
        else:
            print(f"\n完整内容:\n{json.dumps(result, ensure_ascii=False, indent=2)}")
    else:
        print(f"下载失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
