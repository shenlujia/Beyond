//
//  LC0706.m
//  DSPro
//
//  Created by SLJ on 2020/1/17.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0706_MyHashMap.h"
#import <list>
#import <vector>

using namespace std;

/*
 设计哈希映射
 不使用任何内建的哈希表库设计一个哈希映射

 具体地说，你的设计应该包含以下的功能

 put(key, value)：向哈希映射中插入(键,值)的数值对。如果键对应的值已经存在，更新这个值。
 get(key)：返回给定的键所对应的值，如果映射中不包含这个键，返回-1。
 remove(key)：如果映射中存在这个键，删除这个数值对。

 示例：

 MyHashMap hashMap = new MyHashMap();
 hashMap.put(1, 1);
 hashMap.put(2, 2);
 hashMap.get(1);            // 返回 1
 hashMap.get(3);            // 返回 -1 (未找到)
 hashMap.put(2, 1);         // 更新已有的值
 hashMap.get(2);            // 返回 1
 hashMap.remove(2);         // 删除键为2的数据
 hashMap.get(2);            // 返回 -1 (未找到)

 注意：
 所有的值都在 [1, 1000000]的范围内。
 操作的总数目在[1, 10000]范围内。
 不要使用内建的哈希库。
*/
class MyHashMap
{
  public:
    int m_size;
    vector<list<pair<int, int>>> m_data;

    MyHashMap()
    {
        m_size = 10000;
        m_data = vector<list<pair<int, int>>>(m_size);
    }

    int hash(int key)
    {
        return key % m_size;
    }

    void put(int key, int value)
    {
        auto &l = m_data[hash(key)];
        for (auto &p : l) {
            if (p.first == key) {
                p.second = value;
                return;
            }
        }

        l.emplace_back(pair<int, int>(key, value));
    }

    /** Returns the value to which the specified key is mapped, or -1 if this map contains no mapping for the key */
    int get(int key)
    {
        auto &l = m_data[hash(key)];
        for (auto &p : l) {
            if (p.first == key) {
                return p.second;
            }
        }
        return -1;
    }

    /** Removes the mapping of the specified value key if this map contains a mapping for the key */
    void remove(int key)
    {
        auto &l = m_data[hash(key)];
        for (auto i = l.begin(); i != l.end(); ++i) {
            auto &p = *i;
            if (p.first == key) {
                l.erase(i);
                return;
            }
        }
    }
};

@implementation LC0706

+ (void)run
{
    {
        MyHashMap hashMap = MyHashMap();
        hashMap.put(1, 1);
        hashMap.put(2, 2);
        NSParameterAssert(hashMap.get(1) == 1);  // 返回 1
        NSParameterAssert(hashMap.get(3) == -1); // 返回 -1 (未找到);
        hashMap.put(2, 1);                       // 更新已有的值
        NSParameterAssert(hashMap.get(2) == 1);  // 返回 1
        hashMap.remove(2);                       // 删除键为2的数据
        NSParameterAssert(hashMap.get(2) == -1); // 返回 -1 (未找到)
    }
}

@end
