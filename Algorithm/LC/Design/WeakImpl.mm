//
//  WeakImpl.m
//  DSPro
//
//  Created by SLJ on 2020/4/6.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "WeakImpl.h"
#import <list>
#import <unordered_map>
#import <vector>

using namespace std;

class WeakTable
{
  private:
    unordered_map<void *, vector<void **>> m_map;

  public:
    void store(void *obj, void **address)
    {
        if (obj == NULL || address == NULL) {
            return;
        }
        vector<void **> &addr = m_map[obj];
        addr.push_back(address);
    }

    void clean(void *obj, void **address)
    {
        if (m_map.find(obj) != m_map.end()) {
            vector<void **> &addr = m_map[obj];
            for (int i = 0; i < addr.size(); ++i) {
                if (addr[i] == address) {
                    addr[i] = NULL;
                }
            }
        }
    }

    void clean(void *obj)
    {
        if (m_map.find(obj) != m_map.end()) {
            vector<void **> &addr = m_map[obj];
            for (auto it : addr) {
                if (it) {
                    *it = NULL;
                }
            }
            m_map.erase(obj);
        }
    }
};

WeakTable m_weakTable;

class TestWeakObj
{
  public:
    ~TestWeakObj()
    {
        m_weakTable.clean(this);
    }
};

@implementation WeakImpl

+ (void)run
{
    m_weakTable.clean(NULL);

    TestWeakObj *obj = new TestWeakObj();

    {
        TestWeakObj *weak1 = obj;
        m_weakTable.store(weak1, (void **)&weak1);
        // 本地域退出时 清理当前域指针
        m_weakTable.clean(weak1, (void **)&weak1);
    }

    TestWeakObj *weak1 = obj;
    m_weakTable.store(weak1, (void **)&weak1);
    TestWeakObj *weak2 = obj;
    m_weakTable.store(weak2, (void **)&weak2);

    {
        TestWeakObj obj2;
        // 指向修改 先清理
        m_weakTable.clean(weak2, (void **)&weak2);
        weak2 = &obj2;
        m_weakTable.store(weak2, (void **)&weak2);
    }

    delete obj;

    NSParameterAssert(weak1 == NULL && weak2 == NULL);
}

@end
