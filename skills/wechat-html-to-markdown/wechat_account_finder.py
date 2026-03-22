import urllib.request
import urllib.parse
import json
from typing import List, Dict, Optional
from config import DEFAULT_AUTH_KEY, BASE_URL_ACCOUNT


class WeChatAccountFinder:
    """微信公众号查询器 - 通过公众号名称查询公众号ID"""
    
    BASE_URL = BASE_URL_ACCOUNT
    
    def __init__(self, auth_key: Optional[str] = None):
        """
        初始化查询器
        
        Args:
            auth_key: 鉴权密钥（需要从 down.mptext.top 获取），如果不传则使用默认 key
        """
        self.auth_key = auth_key if auth_key else DEFAULT_AUTH_KEY
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        if self.auth_key:
            self.headers['X-Auth-Key'] = self.auth_key
    
    def search_account(
        self, 
        keyword: str, 
        begin: int = 0, 
        size: int = 5
    ) -> Dict:
        """
        根据关键字搜索公众号
        
        Args:
            keyword: 公众号名称或关键字
            begin: 起始索引（从0开始）
            size: 返回条数（最大20）
        
        Returns:
            查询结果字典
        """
        params = {
            'keyword': keyword,
            'begin': begin,
            'size': min(size, 20)  # 确保不超过最大限制
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
    
    def get_account_list(
        self, 
        keyword: str, 
        begin: int = 0, 
        size: int = 5
    ) -> List[Dict]:
        """
        获取公众号列表（简化版，只返回公众号列表）
        
        Args:
            keyword: 公众号名称或关键字
            begin: 起始索引（从0开始）
            size: 返回条数（最大20）
        
        Returns:
            公众号列表
        """
        result = self.search_account(keyword, begin, size)
        
        if result.get('base_resp', {}).get('ret') == 0:
            return result.get('list', [])
        else:
            print(f"查询失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
            return []
    
    def find_account_by_name(self, name: str) -> Optional[Dict]:
        """
        根据公众号名称精确查找公众号
        
        Args:
            name: 公众号名称
        
        Returns:
            找到的公众号信息，未找到返回None
        """
        accounts = self.get_account_list(name, size=20)
        
        for account in accounts:
            if account.get('nickname') == name:
                return account
        
        if accounts:
            return accounts[0]
        
        return None
    
    def get_fakeid(self, name: str) -> Optional[str]:
        """
        获取公众号的fakeid
        
        Args:
            name: 公众号名称
        
        Returns:
            fakeid，未找到返回None
        """
        account = self.find_account_by_name(name)
        return account.get('fakeid') if account else None


def search_wechat_account(
    keyword: str, 
    begin: int = 0, 
    size: int = 5,
    auth_key: Optional[str] = None
) -> Dict:
    """
    便捷函数：搜索公众号
    
    Args:
        keyword: 公众号名称或关键字
        begin: 起始索引
        size: 返回条数
        auth_key: 鉴权密钥（可选，从 down.mptext.top 获取）
    
    Returns:
        查询结果
    """
    finder = WeChatAccountFinder(auth_key)
    return finder.search_account(keyword, begin, size)


def get_wechat_account_fakeid(
    name: str,
    auth_key: Optional[str] = None
) -> Optional[str]:
    """
    便捷函数：获取公众号fakeid
    
    Args:
        name: 公众号名称
        auth_key: 鉴权密钥（可选，从 down.mptext.top 获取）
    
    Returns:
        fakeid
    """
    finder = WeChatAccountFinder(auth_key)
    return finder.get_fakeid(name)


if __name__ == '__main__':
    import sys
    
    auth_key = None
    keyword = None
    
    if len(sys.argv) > 1:
        if sys.argv[1] == '--auth-key' and len(sys.argv) > 3:
            auth_key = sys.argv[2]
            keyword = sys.argv[3]
        elif sys.argv[1] == '-k' and len(sys.argv) > 3:
            auth_key = sys.argv[2]
            keyword = sys.argv[3]
        else:
            keyword = sys.argv[1]
    
    if keyword:
        print(f"搜索公众号: {keyword}")
        if auth_key:
            print("使用提供的 auth-key 进行鉴权")
        
        result = search_wechat_account(keyword, auth_key=auth_key)
        
        if result.get('base_resp', {}).get('ret') == 0:
            print(f"找到 {result.get('total', 0)} 个公众号:")
            for i, account in enumerate(result.get('list', []), 1):
                print(f"\n{i}. {account.get('nickname')}")
                print(f"   fakeid: {account.get('fakeid')}")
                print(f"   别名: {account.get('alias', '')}")
                print(f"   简介: {account.get('signature', '')}")
        else:
            print(f"查询失败: {result.get('base_resp', {}).get('err_msg', '未知错误')}")
            print("\n提示: 此接口需要 auth-key 鉴权，请访问 https://down.mptext.top 获取")
    else:
        print("使用方法:")
        print("  python3 wechat_account_finder.py <公众号名称>")
        print("  python3 wechat_account_finder.py --auth-key <auth-key> <公众号名称>")
        print("  python3 wechat_account_finder.py -k <auth-key> <公众号名称>")
        print("\n说明: auth-key 需要从 https://down.mptext.top 获取")
