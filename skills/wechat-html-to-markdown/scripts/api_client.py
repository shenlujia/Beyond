#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
统一 API 客户端模块
整合公众号查询、文章列表获取、文章下载等 API 功能
"""

import json
import urllib.request
import urllib.parse
from typing import Optional, Dict, Any, List
from config import DEFAULT_AUTH_KEY, BASE_URL_ACCOUNT, BASE_URL_ARTICLE, BASE_URL_DOWNLOAD


class APIClient:
    """
    统一 API 客户端
    """
    
    def __init__(self, auth_key: Optional[str] = None):
        """
        初始化 API 客户端
        
        Args:
            auth_key: 鉴权密钥，从 https://down.mptext.top 获取
        """
        self.auth_key = auth_key if auth_key else DEFAULT_AUTH_KEY
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        if self.auth_key:
            self.headers['X-Auth-Key'] = self.auth_key
    
    def _make_request(self, url: str, params: Optional[Dict] = None, timeout: int = 30) -> Dict[str, Any]:
        """
        发送 HTTP 请求
        
        Args:
            url: 请求 URL
            params: 查询参数
            timeout: 超时时间（秒）
            
        Returns:
            响应数据
        """
        try:
            if params:
                url = f"{url}?{urllib.parse.urlencode(params)}"
            
            req = urllib.request.Request(url, headers=self.headers)
            
            with urllib.request.urlopen(req, timeout=timeout) as response:
                data = response.read().decode('utf-8')
                result = json.loads(data)
                
                base_resp = result.get('base_resp', {})
                ret = base_resp.get('ret', 0)
                err_msg = base_resp.get('err_msg', '')
                
                if ret != 0:
                    if '认证' in err_msg or 'auth' in err_msg.lower() or 'token' in err_msg.lower():
                        result['base_resp']['is_auth_error'] = True
                
                return result
        except Exception as e:
            return {
                'base_resp': {
                    'ret': -1,
                    'err_msg': f'请求失败: {str(e)}'
                }
            }
    
    def search_account(
        self,
        keyword: str,
        begin: int = 0,
        size: int = 5
    ) -> Dict[str, Any]:
        """
        搜索公众号
        
        Args:
            keyword: 公众号名称或关键字
            begin: 起始索引（从0开始）
            size: 返回条数（最大20）
            
        Returns:
            查询结果
        """
        params = {
            'keyword': keyword,
            'begin': begin,
            'size': min(size, 20)
        }
        return self._make_request(BASE_URL_ACCOUNT, params)
    
    def fetch_articles(
        self,
        fakeid: str,
        begin: int = 0,
        size: int = 5
    ) -> Dict[str, Any]:
        """
        获取公众号文章列表
        
        Args:
            fakeid: 公众号ID
            begin: 起始索引
            size: 返回条数
            
        Returns:
            文章列表
        """
        params = {
            'fakeid': fakeid,
            'begin': begin,
            'size': min(size, 20)
        }
        return self._make_request(BASE_URL_ARTICLE, params)
    
    def get_all_articles(
        self,
        fakeid: str,
        max_count: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        获取所有文章（分页获取）
        
        Args:
            fakeid: 公众号ID
            max_count: 最大获取数量
            
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
    
    def download_article(
        self,
        url: str,
        format: str = 'html'
    ) -> Dict[str, Any]:
        """
        下载文章内容
        
        Args:
            url: 微信公众号文章链接
            format: 输出格式（html/markdown/text/json）
            
        Returns:
            文章内容
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
            url_encoded = f"{BASE_URL_DOWNLOAD}?{urllib.parse.urlencode(params)}"
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


def create_client(auth_key: Optional[str] = None) -> APIClient:
    """
    创建 API 客户端实例
    
    Args:
        auth_key: 鉴权密钥
        
    Returns:
        APIClient 实例
    """
    return APIClient(auth_key)
