//
//  LC0622.m
//  DSPro
//
//  Created by SLJ on 2020/1/17.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0622_MyCircularQueue.h"
#import <vector>

/*
 设计循环队列
 设计你的循环队列实现。 循环队列是一种线性数据结构，其操作表现基于 FIFO（先进先出）原则并且队尾被连接在队首之后以形成一个循环。它也被称为“环形缓冲器”。

 循环队列的一个好处是我们可以利用这个队列之前用过的空间。在一个普通队列里，一旦一个队列满了，我们就不能插入下一个元素，即使在队列前面仍有空间。但是使用循环队列，我们能使用这些空间去存储新的值。

 你的实现应该支持如下操作：

 MyCircularQueue(k): 构造器，设置队列长度为 k 。
 Front: 从队首获取元素。如果队列为空，返回 -1 。
 Rear: 获取队尾元素。如果队列为空，返回 -1 。
 enQueue(value): 向循环队列插入一个元素。如果成功插入则返回真。
 deQueue(): 从循环队列中删除一个元素。如果成功删除则返回真。
 isEmpty(): 检查循环队列是否为空。
 isFull(): 检查循环队列是否已满。
  

 示例：
 MyCircularQueue circularQueue = new MycircularQueue(3); // 设置长度为 3
 circularQueue.enQueue(1);  // 返回 true
 circularQueue.enQueue(2);  // 返回 true
 circularQueue.enQueue(3);  // 返回 true
 circularQueue.enQueue(4);  // 返回 false，队列已满
 circularQueue.Rear();  // 返回 3
 circularQueue.isFull();  // 返回 true
 circularQueue.deQueue();  // 返回 true
 circularQueue.enQueue(4);  // 返回 true
 circularQueue.Rear();  // 返回 4
  
 提示：
 所有的值都在 0 至 1000 的范围内；
 操作数将在 1 至 1000 的范围内；
 请不要使用内置的队列库。
*/

using namespace std;

class MyCircularQueue
{
  public:
    int m_max;
    int m_head;
    int m_tail;
    bool m_full;
    vector<int> m_data;
    /** Initialize your data structure here. Set the size of the queue to be k. */
    MyCircularQueue(int k)
    {
        m_max = k;
        m_head = 0;
        m_tail = 0;
        m_full = false;
        m_data = vector<int>(m_max);
    }

    /** Insert an element into the circular queue. Return true if the operation is successful. */
    bool enQueue(int value)
    {
        if (isFull()) {
            return false;
        }
        m_data[m_tail] = value;
        m_tail = (m_tail + 1) % m_max;
        m_full = m_head == m_tail;
        return true;
    }

    /** Delete an element from the circular queue. Return true if the operation is successful. */
    bool deQueue()
    {
        if (isEmpty()) {
            return false;
        }
        m_head = (m_head + 1) % m_max;
        m_full = false;
        return true;
    }

    /** Get the front item from the queue. */
    int Front()
    {
        if (isEmpty()) {
            return -1;
        }
        return m_data[m_head];
    }

    /** Get the last item from the queue. */
    int Rear()
    {
        if (isEmpty()) {
            return -1;
        }
        return m_data[(m_tail - 1 + m_max) % m_max];
    }

    /** Checks whether the circular queue is empty or not. */
    bool isEmpty()
    {
        return m_full == false && m_head == m_tail;
    }

    /** Checks whether the circular queue is full or not. */
    bool isFull()
    {
        return m_full;
    }
};

@implementation LC0622

+ (void)run
{
    {
        MyCircularQueue circularQueue = MyCircularQueue(3);   // 设置长度为 3
        NSParameterAssert(circularQueue.enQueue(1));          // 返回 true
        NSParameterAssert(circularQueue.enQueue(2));          // 返回 true
        NSParameterAssert(circularQueue.enQueue(3));          // 返回 true
        NSParameterAssert(circularQueue.enQueue(4) == false); // 返回 false，队列已满
        NSParameterAssert(circularQueue.Rear() == 3);         // 返回 3
        NSParameterAssert(circularQueue.isFull());            // 返回 true
        NSParameterAssert(circularQueue.deQueue());           // 返回 true
        NSParameterAssert(circularQueue.enQueue(4));          // 返回 true
        NSParameterAssert(circularQueue.Rear() == 4);         // 返回 4
    }
    {
        MyCircularQueue circularQueue = MyCircularQueue(6);
        NSParameterAssert(circularQueue.enQueue(6));
        NSParameterAssert(circularQueue.Rear() == 6);

        NSParameterAssert(circularQueue.Rear() == 6);
        NSParameterAssert(circularQueue.deQueue() == true);
        NSParameterAssert(circularQueue.enQueue(5) == true);

        NSParameterAssert(circularQueue.Rear() == 5);
        NSParameterAssert(circularQueue.deQueue());
        NSParameterAssert(circularQueue.Front() == -1);

        NSParameterAssert(circularQueue.deQueue() == false);
        NSParameterAssert(circularQueue.deQueue() == false);
        NSParameterAssert(circularQueue.deQueue() == false);
    }
}

@end
