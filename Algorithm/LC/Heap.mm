//
//  Heap.m
//  LeetCode
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Heap.h"

/*
public class Heap {
    private int[] arr;       // 堆是完全二叉树，底层用数组存储
    private int capacity;    // 堆中能存储的最大元素数量
    private int n;          // 当前堆中元素数量

    public Heap(int count) {
        capacity = count;
        arr = new int[capacity+1];
        n = 0;
    }

    public void insert(int value) {
        if (n >= capacity) {
            // 超过堆大小了，不能再插入元素
            return;
        }
        n++;
        // 先将元素插入到队尾中
        arr[n] = value;

        int i = n;
        // 由于我们构建的是一个大顶堆，所以需要不断调整以让其满足大顶堆的条件
        while (i/2 > 0 && arr[i] > arr[i/2]) {
            swap(arr, i, i/2);
            i = i / 2;
        }
    }
}

public void removeTopElement() {
    if (n == 0) {
        // 堆中如果没有元素，也就是不存在移除堆顶元素的情况了
        return;
    }
    int count = n;
    arr[1] = arr[count];
    --count;
    heapify(1, count);
}

public void heapify(int index, int n) {

    while (true) {
        int maxValueIndex = index;
        if (2 * index <= n && arr[index] < arr[2 * index]) {
            // 左节点比其父节点大
            maxValueIndex = 2 * index;
        }

        if (2 * index + 1 <= n && arr[maxValueIndex] < arr[2 * index + 1]) {
            // 右节点比左节点或父节点大
            maxValueIndex = 2 * index + 1;
        }

        if (maxValueIndex == index) {
            // 说明当前节点值为最大值，无需再往下迭代了
            break;
        }
        swap(arr, index, maxValueIndex);
        index = maxValueIndex;
    }
}

*/
