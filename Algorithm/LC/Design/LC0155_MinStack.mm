//
//  LC0155.m
//  DSPro
//
//  Created by SLJ on 2020/1/17.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0155_MinStack.h"
#import <stack>

/*
最小栈

设计一个支持 push，pop，top 操作，并能在常数时间内检索到最小元素的栈。

push(x) -- 将元素 x 推入栈中。
pop() -- 删除栈顶的元素。
top() -- 获取栈顶元素。
getMin() -- 检索栈中的最小元素。
示例:

MinStack minStack = new MinStack();
minStack.push(-2);
minStack.push(0);
minStack.push(-3);
minStack.getMin();   --> 返回 -3.
minStack.pop();
minStack.top();      --> 返回 0.
minStack.getMin();   --> 返回 -2.
*/

using namespace std;

class MinStack
{
  public:
    stack<int> main_stack;
    stack<int> min_stack;

    MinStack()
    {
    }

    void push(int x)
    {
        main_stack.push(x);
        if (min_stack.empty() || x <= min_stack.top()) {
            min_stack.push(x);
        }
    }

    void pop()
    {
        if (min_stack.top() == main_stack.top()) {
            min_stack.pop();
        }
        main_stack.pop();
    }

    int top()
    {
        return main_stack.top();
    }

    int getMin()
    {
        return min_stack.top();
    }
};

@implementation LC0155

+ (void)run
{
    {
        MinStack minStack = MinStack();

        minStack.push(-2);
        minStack.push(0);
        minStack.push(-3);
        NSParameterAssert(minStack.getMin() == -3); // --> 返回 -3.
        minStack.pop();
        NSParameterAssert(minStack.top() == 0);     // --> 返回 0.
        NSParameterAssert(minStack.getMin() == -2); // --> 返回 -2.
    }
    {
        MinStack minStack = MinStack();

        minStack.push(0);
        minStack.push(1);
        minStack.push(0);
        NSParameterAssert(minStack.getMin() == 0);
        minStack.pop();
        NSParameterAssert(minStack.getMin() == 0);
    }
}

@end
