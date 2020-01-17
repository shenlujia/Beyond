//
//  LC0641.m
//  DSPro
//
//  Created by SLJ on 2020/1/17.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0641_MyCircularDeque.h"
#import <vector>

/*
 设计实现双端队列。
 你的实现需要支持以下操作：

 MyCircularDeque(k)：构造函数,双端队列的大小为k。
 insertFront()：将一个元素添加到双端队列头部。 如果操作成功返回 true。
 insertLast()：将一个元素添加到双端队列尾部。如果操作成功返回 true。
 deleteFront()：从双端队列头部删除一个元素。 如果操作成功返回 true。
 deleteLast()：从双端队列尾部删除一个元素。如果操作成功返回 true。
 getFront()：从双端队列头部获得一个元素。如果双端队列为空，返回 -1。
 getRear()：获得双端队列的最后一个元素。 如果双端队列为空，返回 -1。
 isEmpty()：检查双端队列是否为空。
 isFull()：检查双端队列是否满了。
 示例：

 MyCircularDeque circularDeque = new MycircularDeque(3); // 设置容量大小为3
 circularDeque.insertLast(1);                    // 返回 true
 circularDeque.insertLast(2);                    // 返回 true
 circularDeque.insertFront(3);                    // 返回 true
 circularDeque.insertFront(4);                    // 已经满了，返回 false
 circularDeque.getRear();                  // 返回 2
 circularDeque.isFull();                        // 返回 true
 circularDeque.deleteLast();                    // 返回 true
 circularDeque.insertFront(4);                    // 返回 true
 circularDeque.getFront();                // 返回 4
  
 提示：
 所有值的范围为 [1, 1000]
 操作次数的范围为 [1, 1000]
 请不要使用内置的双端队列库。
*/

using namespace std;

class MyCircularDeque
{
  public:
    int m_max;
    int m_head;
    int m_tail;
    bool m_full;
    vector<int> m_data;

    MyCircularDeque(int k)
    {
        m_max = k;
        m_head = 0;
        m_tail = 0;
        m_full = false;
        m_data = vector<int>(m_max);
    }

    /** Adds an item at the front of Deque. Return true if the operation is successful. */
    bool insertFront(int value)
    {
        if (isFull()) {
            return false;
        }
        m_head = (m_head - 1 + m_max) % m_max;
        m_data[m_head] = value;
        m_full = m_head == m_tail;
        return true;
    }

    /** Adds an item at the rear of Deque. Return true if the operation is successful. */
    bool insertLast(int value)
    {
        if (isFull()) {
            return false;
        }
        m_data[m_tail] = value;
        m_tail = (m_tail + 1) % m_max;
        m_full = m_head == m_tail;
        return true;
    }

    /** Deletes an item from the front of Deque. Return true if the operation is successful. */
    bool deleteFront()
    {
        if (isEmpty()) {
            return false;
        }
        m_head = (m_head + 1) % m_max;
        m_full = false;
        return true;
    }

    /** Deletes an item from the rear of Deque. Return true if the operation is successful. */
    bool deleteLast()
    {
        if (isEmpty()) {
            return false;
        }
        m_tail = (m_tail - 1 + m_max) % m_max;
        m_full = false;
        return true;
    }

    /** Get the front item from the deque. */
    int getFront()
    {
        if (isEmpty()) {
            return -1;
        }
        return m_data[m_head];
    }

    /** Get the last item from the deque. */
    int getRear()
    {
        if (isEmpty()) {
            return -1;
        }
        return m_data[(m_tail - 1 + m_max) % m_max];
    }

    /** Checks whether the circular deque is empty or not. */
    bool isEmpty()
    {
        return m_full == false && m_head == m_tail;
    }

    /** Checks whether the circular deque is full or not. */
    bool isFull()
    {
        return m_full;
    }
};

@implementation LC0641

+ (void)run
{
    {
        MyCircularDeque circularDeque = MyCircularDeque(3);       // 设置容量大小为3
        NSParameterAssert(circularDeque.insertLast(1));           // 返回 true
        NSParameterAssert(circularDeque.insertLast(2));           // 返回 true
        NSParameterAssert(circularDeque.insertFront(3));          // 返回 true
        NSParameterAssert(circularDeque.insertFront(4) == false); // 已经满了，返回 false
        NSParameterAssert(circularDeque.getRear() == 2);          // 返回 2
        NSParameterAssert(circularDeque.isFull());                // 返回 true
        NSParameterAssert(circularDeque.deleteLast());            // 返回 true
        NSParameterAssert(circularDeque.insertFront(4));          // 返回 true
        NSParameterAssert(circularDeque.getFront() == 4);         // 返回 4
    }
}

@end
