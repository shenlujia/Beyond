//
//  LC0146.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0146_LRUCache.h"
#import <list>
#import <unordered_map>

using namespace std;

/*
LRU缓存机制

运用你所掌握的数据结构，设计和实现一个  LRU (最近最少使用) 缓存机制。它应该支持以下操作： 获取数据 get 和 写入数据 put 。

获取数据 get(key) - 如果密钥 (key) 存在于缓存中，则获取密钥的值（总是正数），否则返回 -1。
写入数据 put(key, value) - 如果密钥不存在，则写入其数据值。当缓存容量达到上限时，它应该在写入新数据之前删除最近最少使用的数据值，从而为新的数据值留出空间。

进阶:

你是否可以在 O(1) 时间复杂度内完成这两种操作？

示例:

LRUCache cache = new LRUCache( 2 缓存容量  );

cache.put(1, 1);
cache.put(2, 2);
cache.get(1);       // 返回  1
cache.put(3, 3);    // 该操作会使得密钥 2 作废
cache.get(2);       // 返回 -1 (未找到)
cache.put(4, 4);    // 该操作会使得密钥 1 作废
cache.get(1);       // 返回 -1 (未找到)
cache.get(3);       // 返回  3
cache.get(4);       // 返回  4
*/

class LRUCache
{
  public:
    list<pair<int, int>> m_list;
    unordered_map<int, list<pair<int, int>>::iterator> m_map;
    int capacity;
    int size;

    LRUCache(int capacity)
    {
        this->capacity = capacity;
        this->size = 0;
    }

    int get(int key)
    {
        if (m_map.find(key) == m_map.end()) {
            return -1;
        }
        auto it = m_map[key];
        pair<int, int> p = *it;

        m_list.erase(it);
        m_list.insert(m_list.begin(), p);
        m_map[key] = m_list.begin();

        return p.second;
    }

    void put(int key, int value)
    {
        pair<int, int> p(key, value);
        if (m_map.find(key) == m_map.end()) {
            if (this->size == this->capacity) {
                auto old = m_list.back();
                m_list.pop_back();
                m_map.erase(old.first);
            } else {
                ++this->size;
            }
        } else {
            auto it = m_map[key];
            m_list.erase(it);
        }

        m_list.insert(m_list.begin(), p);
        m_map[key] = m_list.begin();
    }
};

@implementation LC0146

+ (void)run
{
    {
        LRUCache cache = LRUCache(2);
        cache.put(1, 1);
        cache.put(2, 2);

        NSParameterAssert(cache.get(1) == 1);
        cache.put(3, 3);                       // 该操作会使得密钥 2 作废
        NSParameterAssert(cache.get(2) == -1); // 返回 -1 (未找到);
        cache.put(4, 4);                       // 该操作会使得密钥 1 作废
        NSParameterAssert(cache.get(1) == -1); // 返回 -1 (未找到);
        NSParameterAssert(cache.get(3) == 3);  // 返回  3
        NSParameterAssert(cache.get(4) == 4);  // 返回  4
        NSParameterAssert(cache.m_list.size() == 2 && cache.m_map.size() == 2);
    }
    {
        LRUCache cache = LRUCache(1);
        cache.put(2, 1);

        NSParameterAssert(cache.get(2) == 1);
        cache.put(3, 2);
        NSParameterAssert(cache.get(2) == -1);
        NSParameterAssert(cache.get(3) == 2);
        NSParameterAssert(cache.m_list.size() == 1 && cache.m_map.size() == 1);
    }
}

@end
