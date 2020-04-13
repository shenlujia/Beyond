//
//  LC0460.m
//  DSPro
//
//  Created by SLJ on 2020/1/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0460_LFUCache.h"
#import <list>
#import <unordered_map>

/*
LFU缓存

设计并实现最不经常使用（LFU）缓存的数据结构。它应该支持以下操作：get 和 put。

get(key) - 如果键存在于缓存中，则获取键的值（总是正数），否则返回 -1。
put(key, value) -
如果键不存在，请设置或插入值。当缓存达到其容量时，它应该在插入新项目之前，使最不经常使用的项目无效。在此问题中，当存在平局（即两个或更多个键具有相同使用频率）时，最近最少使用的键将被去除。

进阶：
你是否可以在 O(1) 时间复杂度内执行两项操作？

示例：

LFUCache cache = new LFUCache( 2 );

cache.put(1, 1);
cache.put(2, 2);
cache.get(1);       // 返回 1
cache.put(3, 3);    // 去除 key 2
cache.get(2);       // 返回 -1 (未找到key 2)
cache.get(3);       // 返回 3
cache.put(4, 4);    // 去除 key 1
cache.get(1);       // 返回 -1 (未找到 key 1)
cache.get(3);       // 返回 3
cache.get(4);       // 返回 4
*/

using namespace std;

class LFUCache
{
  public:
    int capacity;
    int size;
    // 最小的 freq，删除元素时需要知道该删除哪个链表
    int minFreq;
    // 保存 value和freq
    unordered_map<int, pair<int, int>> valueFreqMap;
    // 保存 key 在链表中的位置
    unordered_map<int, list<int>::iterator> iterMap;
    // freq 对应的链表
    unordered_map<int, list<int>> freqListMap;

    LFUCache(int capacity)
    {
        this->capacity = capacity;
        this->size = 0;
        this->minFreq = 0;
    }

    int get(int key)
    {
        if (valueFreqMap.count(key) == 0) {
            return -1;
        }
        pair<int, int> &pre_pair = valueFreqMap[key];
        list<int> &pre_list = freqListMap[pre_pair.second];
        pre_list.erase(iterMap[key]);
        ++pre_pair.second;

        list<int> &cur_list = freqListMap[pre_pair.second];
        cur_list.emplace_back(key);
        iterMap[key] = --cur_list.end();
        if (freqListMap[minFreq].size() == 0) {
            ++minFreq;
        }
        return pre_pair.first;
    }
    void put(int key, int value)
    {
        if (capacity <= 0) {
            return;
        }
        int storedValue = get(key);
        if (storedValue != -1) {
            valueFreqMap[key].first = value;
            return;
        }
        std::pair<int, int> p(value, 1);
        if (this->size == this->capacity) {
            list<int> &min_list = freqListMap[minFreq];
            int old = min_list.front();
            valueFreqMap.erase(old);
            iterMap.erase(old);
            min_list.pop_front();
        } else {
            ++this->size;
        }
        minFreq = p.second;
        valueFreqMap[key] = p;
        freqListMap[p.second].push_back(key);
        iterMap[key] = --freqListMap[p.second].end();
    }
};

@implementation LC0460

+ (void)run
{
    {
        LFUCache cache = LFUCache(2);
        cache.put(1, 1);
        cache.put(2, 2);

        NSParameterAssert(cache.get(1) == 1);  // 返回 1
        cache.put(3, 3);                       // 去除 key 2
        NSParameterAssert(cache.get(2) == -1); // 返回 -1 (未找到key 2);
        NSParameterAssert(cache.get(3) == 3);  // 返回 3
        cache.put(4, 4);                       // 去除 key 1
        NSParameterAssert(cache.get(1) == -1); // 返回 -1 (未找到 key 1);
        NSParameterAssert(cache.get(3) == 3);  // 返回 3
        NSParameterAssert(cache.get(4) == 4);  // 返回 4
    }
}

@end
