//
//  MonotonicQueue.h
//  DSPro
//
//  Created by SLJ on 2020/3/31.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <deque>

using namespace std;

#ifndef MonotonicQueue_h
#define MonotonicQueue_h

class MonotonicQueue
{
  private:
    deque<int> q;

  public:
    void push(int v)
    {
        while (!q.empty() && q.back() < v) {
            q.pop_back();
        }
        q.push_back(v);
    }

    int max()
    {
        return q.empty() ? -1 : q.front();
    }

    void pop(int v)
    {
        if (!q.empty() && q.front() == v) {
            q.pop_front();
        }
    }
};

#endif
