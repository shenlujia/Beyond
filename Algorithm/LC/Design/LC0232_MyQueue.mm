//
//  LC0232_MyQueue.m
//  DSPro
//
//  Created by SLJ on 2020/3/3.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0232_MyQueue.h"
#import <stack>

using namespace std;

/*
 使用栈实现队列的下列操作：

 push(x) -- 将一个元素放入队列的尾部。
 pop() -- 从队列首部移除元素。
 peek() -- 返回队列首部的元素。
 empty() -- 返回队列是否为空。
 示例:

 MyQueue queue = new MyQueue();

 queue.push(1);
 queue.push(2);
 queue.peek();  // 返回 1
 queue.pop();   // 返回 1
 queue.empty(); // 返回 false
 说明:

 你只能使用标准的栈操作 -- 也就是只有 push to top, peek/pop from top, size, 和 is empty 操作是合法的。
 你所使用的语言也许不支持栈。你可以使用 list 或者 deque（双端队列）来模拟一个栈，只要是标准的栈操作即可。
 假设所有操作都是有效的 （例如，一个空的队列不会调用 pop 或者 peek 操作）。
*/
class MyQueue
{
  public:
    stack<int> in_stack;
    stack<int> out_stack;

    MyQueue()
    {
    }

    void transferIfEmpty()
    {
        if (out_stack.empty()) {
            while (!in_stack.empty()) {
                out_stack.push(in_stack.top());
                in_stack.pop();
            }
        }
    }

    /** Push element x to the back of queue. */
    void push(int x)
    {
        in_stack.push(x);
    }

    /** Removes the element from in front of queue and returns that element. */
    int pop()
    {
        transferIfEmpty();
        int ret = out_stack.top();
        out_stack.pop();
        return ret;
    }

    /** Get the front element. */
    int peek()
    {
        transferIfEmpty();
        return out_stack.top();
    }

    /** Returns whether the queue is empty. */
    bool empty()
    {
        return in_stack.empty() && out_stack.empty();
    }
};

@implementation LC0232

+ (void)run
{
    {
        MyQueue queue;
        queue.push(1);
        queue.push(2);
        NSParameterAssert(queue.peek() == 1);      // 返回 1
        NSParameterAssert(queue.pop() == 1);       // 返回 1
        NSParameterAssert(queue.empty() == false); // 返回 false
    }
}

@end
