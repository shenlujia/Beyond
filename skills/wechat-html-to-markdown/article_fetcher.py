#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
微信公众号文章列表获取模块
基于原工程 wechat-article-exporter 的逻辑实现
"""

import json
import urllib.request
import urllib.parse
from typing import Optional, List, Dict, Any
from config import DEFAULT_AUTH_KEY, BASE_URL_ARTICLE


class ArticleFetcher:
    """
    微信公众号文章列表获取器
    """
    
    BASE_URL = BASE_URL_ARTICLE
    
    def __init__(self, auth_key: Optional[str] = None):
        """
        初始化文章获取器
        
        Args:
            auth_key: 鉴权密钥，从 https://down.mptext.top 获取，如果不传则使用默认 key
        """
        self.auth_key = auth_key if auth_key else DEFAULT_AUTH_KEY
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        if self.auth_key:
            self.headers['X-Auth-Key'] = self.auth_key
    
    def fetch_articles(
        self, 
        fakeid: str, 
        begin: int = 0, 
        size: int = 5
    ) -> Dict[str, Any]:
        """
        获取公众号文章列表
        
        Args:
            fakeid: 公众号ID，通过 search-account 功能获取
            begin: 起始索引，从0开始
            size: 返回条数，最大不超过20
            
        Returns:
            包含文章列表的字典
        """
        params = {
            'fakeid': fakeid,
            'begin': begin,
            'size': min(size, 20)
        }
        
        try:
            url = f"{self.BASE_URL}?{urllib.parse.urlencode(params)}"
            req = urllib.request.Request(url, headers=self.headers)
            with urllib.request.urlopen(req, timeout=30) as response:
                data = response.read().decode('utf-8')
                return json.loads(data)
        except Exception as e:
            return {
                'base_resp': {
                    'ret': -1, 
                    'err_msg': f'请求失败: {str(e)}'
                }
            }
    
    def get_all_articles(
        self, 
        fakeid: str, 
        max_count: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        获取所有文章（支持分页获取）
        
        Args:
            fakeid: 公众号ID
            max_count: 最大获取数量，None表示获取所有
            
        Returns:
            文章列表
        """
        all_articles = []
        begin = 0
        size = 20
        
        while True:
            result = self.fetch_articles(fakeid, begin, size)
            
            if result.get('base_resp', {}).get('ret') != 0:
                break
            
            articles = result.get('articles', [])
            if not articles:
                break
            
            all_articles.extend(articles)
            
            if max_count and len(all_articles) >= max_count:
                all_articles = all_articles[:max_count]
                break
            
            begin += size
        
        return all_articles


def fetch_wechat_articles(
    fakeid: str, 
    begin: int = 0, 
    size: int = 5, 
    auth_key: Optional[str] = None
) -> Dict[str, Any]:
    """
    便捷函数：获取公众号文章列表
    
    Args:
        fakeid: 公众号ID
        begin: 起始索引
        size: 返回条数
        auth_key: 鉴权密钥
        
    Returns:
        包含文章列表的字典
    """
    fetcher = ArticleFetcher(auth_key)
    return fetcher.fetch_articles(fakeid, begin, size)


def get_all_wechat_articles(
    fakeid: str, 
    max_count: Optional[int] = None, 
    auth_key: Optional[str] = None
) -> List[Dict[str, Any]]:
    """
    便捷函数：获取所有文章
    
    Args:
        fakeid: 公众号ID
        max_count: 最大获取数量
        auth_key: 鉴权密钥
        
    Returns:
        文章列表
    """
    fetcher = ArticleFetcher(auth_key)
    return fetcher.get_all_articles(fakeid, max_count)


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python3 article_fetcher.py <fakeid> [begin] [size] [auth-key]")
        print("\n示例:")
        print("  python3 article_fetcher.py MzA3NzAyMzMyMA==")
        print("  python3 article_fetcher.py MzA3NzAyMzMyMA== 0 10 <auth-key>")
        sys.exit(1)
    
    fakeid = sys.argv[1]
    begin = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    size = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    auth_key = sys.argv[4] if len(sys.argv) > 4 else None
    
    result = fetch_wechat_articles(fakeid, begin, size, auth_key)
    
    if result.get('base_resp', {}).get('ret') == 0:
        articles = result.get('articles', [])
        print(f"找到 {len(articles)} 篇文章:\n")
        for i, article in enumerate(articles, 1):
            print(f"{i}. {article.get('title')}")
            print(f"   链接: {article.get('link')}")
            print(f"   时间: {article.get('create_time')}")
            print()
    else:
        print(f"查询失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
