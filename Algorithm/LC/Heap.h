//
//  Heap.h
//  LeetCode
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <vector>

using namespace std;

class MaxHeap
{
    // 向量，保存堆的数据
    vector<int> data;

  public:
    // 构造函数
    MaxHeap();
    // 堆的大小
    int size()
    {
        return (int)data.size();
    }
    // 堆是否为空
    bool isEmpty()
    {
        return data.empty();
    }
    // 堆的父节点
    int parent(int index)
    {
        if (index == 0) {
            // No parent
            return -1;
        }
        return (index - 1) / 2;
    }
    // 堆的左孩子
    int leftChlid(int index)
    {
        return 2 * index + 1;
    }
    // 堆的右孩子
    int rightChlid(int index)
    {
        return 2 * index + 2;
    }

    MaxHeap(int arr[], int n)
    {
        // 看成是一颗完全二叉树
        vector<int> v(arr, arr + n);
        data = v;
        // 从倒数第一个非叶子节点进行 shift_down 操作
        for (int i = parent(n - 1); i >= 0; i--) {
            shift_down(i);
        }
    }

    void shift_up(int index)
    {
        // 不为根节点且父节点比根节点的值要小
        while (index > 0 && data[parent(index)] < data[index]) {
            int temp = data[parent(index)];
            data[parent(index)] = data[index];
            data[index] = temp;
            // 依次堆当前节点的父节点进行上浮操作
            index = parent(index);
        }
    }

    void add(int value)
    {
        // 先加入向量中，然后对最后一个元素做上浮操作
        data.push_back(value);
        shift_up(size() - 1);
    }

    int pop_max()
    {
        if (size() == 0) {
            return -1;
        }
        // 只有一个元素直接 pop
        if (size() == 1) {
            int value = data[0];
            data.pop_back();
            return value;
        }
        int max = data[0];
        // 交换第一个和最后一个元素
        int temp = data[size() - 1];
        data[size() - 1] = data[0];
        data[0] = temp;

        // 删除最后一个元素
        data.pop_back();
        shift_down(0);
        return max;
    }

    void shift_down(int index)
    {
        // 左孩子小于 data 的长度，说明没到头
        while (leftChlid(index) < size()) {
            int lIndex = leftChlid(index);
            int rIndex = rightChlid(index);
            // 找到左右孩子最大的元素
            int max = data[lIndex];
            if (rIndex < size() && data[rIndex] > max) {
                max = data[rIndex];
            }
            if (max > data[index]) {
                // 左孩子与父节点元素交换
                if (max == data[lIndex]) {
                    swap(lIndex, index);
                    index = lIndex;
                } else {
                    // 右孩子与父节点元素交换
                    swap(rIndex, index);
                    index = rIndex;
                }
            } else {
                break;
            }
        }
    }
};
