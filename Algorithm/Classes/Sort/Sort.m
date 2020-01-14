//
//  Sort.m
//  DSPro
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Sort.h"
#import <objc/runtime.h>

@implementation Sort

+ (void)run
{
    __block NSInteger index = 0;
    void (^go)(SEL selector, NSArray *) = ^(SEL selector, NSArray *array) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *result = [self performSelector:selector withObject:[array mutableCopy]];
#pragma clang diagnostic pop
        NSArray *target = [array sortedArrayUsingComparator:^NSComparisonResult(NSNumber *o1, NSNumber *o2) {
            return [o1 compare:o2];
        }];
        NSParameterAssert([result isEqualToArray:target]);

        NSString *title = NSStringFromSelector(selector);
        title = [title stringByReplacingOccurrencesOfString:@":" withString:@""];
        printf("====== %02ld %s ======\n", ++index, title.UTF8String);
        printf(" in: [%s]\n", [array componentsJoinedByString:@", "].UTF8String);
        printf("out: [%s]\n\n", [result componentsJoinedByString:@", "].UTF8String);
    };

    NSArray *array = @[@(2), @(3), @(5), @(1), @(4), @(9), @(6), @(8), @(7)];

    go(@selector(bubbleSort:), array);
    go(@selector(insertionSort:), array);
    go(@selector(selectSort:), array);
    go(@selector(shellSort:), array);

    go(@selector(quickSort:), array);
    go(@selector(mergeSort:), array);
    go(@selector(heapSort:), array);

    go(@selector(countingSort:), array);
    go(@selector(bucketSort:), array);
    go(@selector(radixSort:), array);
}

/*
 冒泡排序是通过比较两个相邻元素的大小实现排序，如果前一个元素大于后一个元素，就交换这两个元素。这样就会让每一趟冒泡都能找到最大一个元素并放到最后。

 稳定性：它是指对同样的数据进行排序，不会改变它的相对位置。比如 [ 1, 3, 2, 4, 2 ]
 经过排序后，两个相同的元素位置不会被交换。冒泡排序是比较相邻两个元素的大小，显然不会破坏稳定性。

 空间复杂度：由于整个排序过程是在原数据上进行操作，故为 O(1);

 时间复杂度：由于嵌套了 2 层循环，故为 O(n*n);

 冒泡排序在排序的过程中设置一个 Flag
 标记是否已经有序，会减少冒泡排序的趟数。它更适合基本有序的数据，只有几个无序，最好的情况时间复杂度为
 O(n)。它的基本操是每次找出最大的元素放到最后。
 */
+ (NSArray *)bubbleSort:(NSArray *)unsortDatas
{
    NSMutableArray *unSortArray = [unsortDatas mutableCopy];
    for (int i = 0; i < unSortArray.count - 1; i++) {
        BOOL isChange = NO;
        for (int j = 0; j < unSortArray.count - 1 - i; j++) {
            // 比较相邻两个元素的大小，后一个大于前一个就交换
            if ([unSortArray[j] integerValue] > [unSortArray[j + 1] integerValue]) {
                NSNumber *data = unSortArray[j + 1];
                unSortArray[j + 1] = unSortArray[j];
                unSortArray[j] = data;
                isChange = YES;
            }
        }
        if (!isChange) {
            // 如果某次未发生数据交换，说明数据已排序
            break;
        }
    }
    return [unSortArray copy];
}

/*
 在整个排序过程如图所示，以 arr = [ 8, 1, 4, 6, 2, 3, 5, 7] 为例，它会把 arr 分成两组 A = [ 8 ] 和 B = [ 1, 4, 6, 2, 3,
 5, 7] ，逐步遍历 B 中元素插入到 A 中，最终构成一个有序序列：

 稳定性：它是从后往前遍历已排序好的序列，相同元素不会改变位置，故为稳定排序；
 空间复杂度：它是在原序列进行排序，故为 O(1);
 时间复杂度：排序的过程中，首先要遍历所有的元素，然后在已排序序列中找到合适的位置并插入。共需要 2 层循环，故为 O(n*n);

 插入排序的特点是把一个序列分成 2
 组，开始的时候把第1个元素作为一组（有序），剩余元素作为另一组（无序）。这种方式如同打扑克，每次抓取一张牌插入到手里已经排序好的牌中。这种排序方式更适合某个序列本身已经有序或基本有序，插入几个元素。想优化这种排序可以在查找插入位置的时候选择一种更高效的算法，比如折半查找。
 */
+ (NSArray *)insertionSort:(NSArray *)unsortDatas
{
    NSMutableArray *unSortArray = [unsortDatas mutableCopy];
    int preindx = 0;
    NSNumber *current;
    for (int i = 1; i < unSortArray.count; i++) {
        preindx = i - 1;
        // 必须记录这个元素，不然会被覆盖掉
        current = unSortArray[i];
        // 逆序遍历已经排序好的数组

        // 当前元素小于排序好的元素，就移动到下一个位置
        while (preindx >= 0 && [current integerValue] < [unSortArray[preindx] integerValue]) {
            // 元素向后移动
            unSortArray[preindx + 1] = unSortArray[preindx];
            preindx -= 1;
        }
        // 找到合适的位置，把当前的元素插入
        unSortArray[preindx + 1] = current;
    }
    return [unSortArray copy];
}

/*
 选择排序的思想是，依次从「无序列表」中找到一个最小的元素放到「有序列表」的最后面。以 arr = [ 8, 1, 4, 6, 2, 3, 5, 4 ]
 为例，排序开始时把 arr 分为有序列表 A = [ ], 无序列表 B = [ 8, 1, 4, 6, 2, 3, 5, 4 ]，依次从 B 中找出最小的元素放到 A
 的最后面。这种排序也是逻辑上的分组，实际上不会创建 A 和 B，只是用下标来标记 A 和 B。

 选择排序

 以 arr = [ 8, 1, 4, 6, 2, 3, 5, 4 ] 为例，第一次找到最小元素 1 与 8 进行交换，这时有列表 A = [1], 无序列表 B = [8, 4,
 6, 2, 3, 5, 4]；第二次从 B 中找到最小元素 2，与 B 中的第一个元素进行交换，交换后 A = [1，2]，B = [4, 6, 8, 3, 5,
 4]；就这样不断缩短 B，扩大 A，最终达到有序。

 稳定性：排序过程中元素是按顺序进行遍历，相同元素相对位置不会发生变化，故稳定。

 空间复杂度：在原序列进行操作，故为 O( 1 );

   时间复杂度：需要 2 次循环遍历，故为 O( n * n );

 感想

 选择排序与冒泡排序，插入排序都属于同一思想排序，这种排序算法思想简单，往往会用于其它复杂排序算法的子序列排序。
 */
+ (NSArray *)selectSort:(NSArray *)unsortDatas
{
    NSMutableArray *unSortArray = [unsortDatas mutableCopy];
    for (int i = 0; i < unSortArray.count; i++) {
        int mindex = i;
        for (int j = i; j < unSortArray.count; j++) {
            // 找到最小元素的index
            if ([unSortArray[j] integerValue] < [unSortArray[mindex] integerValue]) {
                mindex = j;
            }
        }
        // 交换位置
        NSNumber *data = unSortArray[i];
        unSortArray[i] = unSortArray[mindex];
        unSortArray[mindex] = data;
    }
    return [unSortArray copy];
}

/*
 希尔排序，它是由 D.L.Shell 于1959 年提出而得名。根据它的名字很难想象算法的核心思想。[
 所以只能死记硬背了，面试官问：希尔排序的思想是什么？]。它的核心思想是把一个序列分组，对分组后的内容进行插入排序，这里的分组只是逻辑上的分组，不会重新开辟存储空间。它其实是插入排序的优化版，插入排序对基本有序的序列性能好，希尔排序利用这一特性把原序列分组，对每个分组进行排序，逐步完成排序。

 希尔排序

 以 arr = [ 8, 1, 4, 6, 2, 3, 5, 7 ] 为例，通过 floor(8/2) 来分为 4 组，8
 表示数组中元素的个数。分完组后，对组内元素进行插入排序。

 稳定性：它可能会把相同元素分到不同的组中，那么两个相同的元素就有可能调换相对位置，故不稳定。

 空间复杂度：由于整个排序过程是在原数据上进行操作，故为 O(1);

 时间复杂度：
 希尔排序的时间复杂度与增量序列的选取有关，例如希尔增量时间复杂度为O(n²)，而Hibbard增量的希尔排序的时间复杂度为O(log
 n的3/2)，希尔排序时间复杂度的下界是n*log2n
 百度百科
 感想

 希尔排序在整个过程中，分组方式为：group = length/2,  group/2 ......
 1，直到只能分一组，在整个分组过程中使元素逐渐变得有序，这样使用插入排序的时候就不需要移动大量元素，比如一个逆序序列 arr
 = [6, 5, 4, 4, 2,
 1]，采用插入排序每次需要移动大量元素，如果换成希尔排序移动次数就会减少。希尔排序一个有意思的点是采用不同方式进行分组（上面提到的是采用的希尔增量分组），时间复杂度会有所不同，有兴趣的读者可以了解下其它分组方式。
 */
+ (NSArray *)shellSort:(NSArray *)unsortDatas
{
    NSMutableArray *unSortArray = [unsortDatas mutableCopy];
    // len = 9
    int len = (int)unSortArray.count;
    // floor 向下取整，所以 gap的值为：4，2，1
    for (int gap = floor(len / 2); gap > 0; gap = floor(gap / 2)) {
        // i=4;i<9;i++ (4,5,6,7,8)
        for (int i = gap; i < len; i++) {
            // j=0,1,2,3,4
            // [0]-[4] [1]-[5] [2]-[6] [3]-[7] [4]-[8]
            for (int j = i - gap; j >= 0 && [unSortArray[j] integerValue] > [unSortArray[j + gap] integerValue]; j -= gap) {
                // 交换位置
                NSNumber *temp = unSortArray[j];
                unSortArray[j] = unSortArray[gap + j];
                unSortArray[gap + j] = temp;
            }
        }
    }
    return [unSortArray copy];
}

/*
 快速排序，人称最快的排序（其实我不太赞同，只能说它整体上效率比较高，有些排序算法在特定的数据序列中远比快速排序效率高）。掌握快速排序，需要对递归有深入的了解，如果只是了解递归的用法「不知道为什么这样写」，却不知道递归原理和执行顺序，建议深入学习下递归思想（PS：公众号列表中已经躺了一篇关于递归的文章，只是没太想好如何能够通俗易懂把递归讲明白，后面我画一些图来聊一聊递归）。

 快速排序的核心思想是对待排序序列通过一个「支点」（支点就是序列中的一个元素，别把它想的太高大上）进行拆分，使得左边的数据小于支点，右边的数据大于支点。然后把左边和右边再做一次递归，直到递归结束。支点的选择也是一门大学问，我们以
 （左边index + 右边index）/ 2 来选择支点。一图胜千言，看图吧。

 快速排序

 以 arr = [ 8, 1, 4, 6, 2, 3, 5, 7 ] 为例，选择一个支点, index=  (L+R)/2 = (0+7)/2=3, 支点的值 pivot = arr[index] =
 arr[3] = 6，接下来需要把 arr 中小于 6 的移到左边，大于 6
 的移到右边。快速排序使用一个高效的方法做数据拆分。用一个指向左边的游标 i，和指向右边的游标
 j，逐渐移动这两个游标，直到找到 arr[i] > 6 和 arr[j] < 6, 停止移动游标，交换 arr[i] 和 arr[j]，交换完后
 i++，j--（对下一个元素进行比较），直到 i>=j，停止移动。图中的 L，R
 是指快速排序开始时序列的起始和结束索引，在一趟快速排序中，它们的值不会发生改变，直到下一趟排序时才会改变。文字描述的有点长，我怕你看不懂图就啰嗦了一下。

 稳定性：在元素分组的时候，相同元素相对位置可能会发生变化，故不稳定。

 空间复杂度：不同实现空间复杂度不太一样;

 时间复杂度：它与选取的支点值有关系，如果支点值为最大或最小，导致只有一边进行快速排序，时间复杂度为 O(n*n) ,
 如果选择中间的值为 O(nlogn);

 快速排序理解起来确实比其它排序抽象一点，它的关键点是选择支点值，选最大或者最小，导致快速排序一边倒，性能会大打折扣。回顾一下前面提到的
 3种排序。冒泡排序，需要每次找到最大元素放到最后；插入排序，需要把待排序序列分组，把未排序序列插入到已排序序列；希尔排序，分多组让待排序序列逐渐变得有序，从而达到优化插入排序的目的。快速排序也是把待排序序列分组，不过它需要找到一个合适的支点。
 */
+ (NSArray *)quickSort:(NSMutableArray *)unSortArray
{
    return [self _quickSort:unSortArray leftIndex:0 rightIndex:unSortArray.count - 1];
}

+ (NSArray *)_quickSort:(NSMutableArray *)unSortArray leftIndex:(NSInteger)lindex rightIndex:(NSInteger)rIndex
{
    NSInteger i = lindex;
    NSInteger j = rIndex;
    // 取中间的值作为一个支点
    NSNumber *pivot = unSortArray[(lindex + rIndex) / 2];
    while (i <= j) {
        // 向左移动，直到找打大于支点的元素
        while ([unSortArray[i] integerValue] < [pivot integerValue]) {
            i++;
        }
        // 向右移动，直到找到小于支点的元素
        while ([unSortArray[j] integerValue] > [pivot integerValue]) {
            j--;
        }
        // 交换两个元素，让左边的大于支点，右边的小于支点
        if (i <= j) {
            // 如果 i == j，交换个啥？
            if (i != j) {
                NSNumber *temp = unSortArray[i];
                unSortArray[i] = unSortArray[j];
                unSortArray[j] = temp;
            }
            i++;
            j--;
        }
    }
    // 递归左边，进行快速排序
    if (lindex < j) {
        [self _quickSort:unSortArray leftIndex:lindex rightIndex:j];
    }
    // 递归右边，进行快速排序
    if (i < rIndex) {
        [self _quickSort:unSortArray leftIndex:i rightIndex:rIndex];
    }
    return [unSortArray copy];
}

/*
 归并排序，采用分治思想，先把待排序序列拆分成一个个子序列，直到子序列只有一个元素，停止拆分，然后对每个子序列进行边排序边合并。其实，从名字「归并」可以看出一丝「拆、合」的意思（妄加猜测）。

 归并排序

 以 arr = [ 8, 1, 4, 6, 2, 3, 5, 7 ] 为例，排序需要分两步：
  a、「拆」，以 length/2 拆分为 A = [ 8, 1, 4, 6 ] ，B = [ 2, 3, 5, 7 ]，继续对 A 和 B 进行拆分，A1 = [ 8, 1 ] 、A2 = [
 4, 6 ]、B1 = [ 2, 3 ]、B2 = [ 5, 7 ]，继续拆分，直到只有一个元素，A11 = [ 8 ] , A12= [ 1 ] 、A21 = [ 4 ]、A22 = [ 6
 ]、B11 = [ 2 ]、B12 = [ 3 ]、B21 = [ 5 ]、B22 = [ 7 ]。
 b、「合」，对单个元素的序列进行合并，A11和A12合并为[ 1, 8 ], A21 和 A22 合并为 [ 4, 6
 ]，等等。在合并的过程中也需要排序。「一图胜千言」。

 稳定性：在元素拆分的时候，虽然相同元素可能被分到不同的组中，但是合并的时候相同元素相对位置不会发生变化，故稳定。

 空间复杂度：需要用到一个数组保存排序结果，也就是合并的时候，需要开辟空间来存储排序结果，故为 O ( n );

 时间复杂度：最好最坏都为 O(nlogn);


 感想

 归并排序，需要额外申请存储空间用来存储排序结果，也就是给合并的时候使用，不过它的时间复杂度均为
 O(nlogn)。整体思想比较简单，同样使用到了递归思想。
 */
+ (NSArray *)mergeSort:(NSArray *)unSortArray
{
    NSInteger len = unSortArray.count;
    // 递归终止条件
    if (len <= 1) {
        return unSortArray;
    }
    NSInteger mid = len / 2;
    // 对左半部分进行拆分
    NSArray *lList = [self mergeSort:[unSortArray subarrayWithRange:NSMakeRange(0, mid)]];
    // 对右半部分进行拆分
    NSArray *rList = [self mergeSort:[unSortArray subarrayWithRange:NSMakeRange(mid, len - mid)]];
    // 递归结束后执行下面的语句
    NSInteger lIndex = 0;
    NSInteger rIndex = 0;
    // 进行合并
    NSMutableArray *results = [NSMutableArray array];
    while (lIndex < lList.count && rIndex < rList.count) {
        if ([lList[lIndex] integerValue] < [rList[rIndex] integerValue]) {
            [results addObject:lList[lIndex]];
            lIndex += 1;
        } else {
            [results addObject:rList[rIndex]];
            rIndex += 1;
        }
    }
    // 把左边剩余元素加到排序结果中
    if (lIndex < lList.count) {
        [results addObjectsFromArray:[lList subarrayWithRange:NSMakeRange(lIndex, lList.count - lIndex)]];
    }
    // 把右边剩余元素加到排序结果中
    if (rIndex < rList.count) {
        [results addObjectsFromArray:[rList subarrayWithRange:NSMakeRange(rIndex, rList.count - rIndex)]];
    }
    return results;
}

/*
 堆排序需要借助于一种数据结构「堆」，注意下文说的都是 「大根堆」。排序的过程中需要不断进行重组堆（heapify
 阶段）。关于堆这种数据结构在上一篇文章已经讲过了。堆需要满足 2 个条件：

 「a」、是一颗完全二叉树（完全二叉树是由满二叉树衍生出来的，满二叉树是指除最后一层无任何子节点外其它节点都有2个子节点，当二叉树的每个节点的编号都与其对应的满二叉树节点的编号对应，则这棵树为完全二叉树）；

 「 b 」、父节点的值大于等于子节点。

 从上面的两个特点可以推出：堆的第一个元素最大。堆排序正是利用了这个特点来对数据进行排序，整个排序过程分为 2 个阶段：

 1、根节点与最后一个节点交换位置；

 2、对根节点进行重组堆（heapify）；


 整个排序过程中每次可以获得一个最大的元素放到最后，这样下来就可以得到一个有序序列。

 理解堆排序需要掌握一个重要的特点，堆可以用数组表示，数组的索引正是堆的下标。「一图胜前言，看图吧」。

 稳定性：在堆不断重组的过程中，相同元素的相对位置可能会发生变化，故不稳定。

 空间复杂度：在原序列堆元素进行操作，故为 O ( 1 );

 时间复杂度：最好最坏都为 O(nlogn);

 堆排序利用了堆数据结构，堆本身是一棵二叉树，根据一个节点可以计算出它的父节点，左子节点和右子节点的下标。父节点=(i-1)/2，左子节点=2*i
 + 1，右子节点=2*i + 2。「 i表示第几个节点
 」。整个思想就是不断进行堆重组，交换根节点与最后节点的位置，再对除最后一个节点外的其它元素进重组、交换。
 */
/**
 堆排序的思想就是堆的根肯定是最大的
 1.把最大的与最后一个元素交换
 2.除最后一个元素外,对根节点进行一次堆重组(heapify)
 3.重复1和2
 */
+ (NSArray *)heapSort:(NSArray *)datas
{
    NSMutableArray *array = [datas mutableCopy];
    [self _heapSort:array len:array.count];
    return array;
}

+ (void)_heapSort:(NSMutableArray *)heapList len:(NSInteger)len
{
    //建立堆，从最底层的父节点开始
    for (NSInteger i = (heapList.count / 2 - 1); i >= 0; i--) {
        [self _adjustHeap:heapList location:i len:heapList.count];
    }

    for (NSInteger i = heapList.count - 1; i >= 0; i--) {
        // R[N] move EndLocation
        NSNumber *maxEle = heapList[0];
        heapList[0] = heapList[i];
        heapList[i] = maxEle;

        [self _adjustHeap:heapList location:0 len:i];
    }
}

+ (void)_adjustHeap:(NSMutableArray *)heapList location:(NSInteger)p len:(NSInteger)len
{
    NSNumber *curParent = heapList[p];
    NSInteger child = 2 * p + 1;
    while (child < len) {
        // left < right
        if (child + 1 < len && [heapList[child] integerValue] < [heapList[child + 1] integerValue]) {
            child++;
        }
        if (curParent.integerValue < [heapList[child] integerValue]) {
            heapList[p] = heapList[child];
            p = child;
            child = 2 * p + 1;
        } else {
            break;
        }
    }
    heapList[p] = curParent;
}

/*
 前面所讲的
 6种排序都是基于「比较」的思想，总是在比较两个元素的大小，然后交换位置。今天换个“口味”，来看看计数排序。计数排序的核心思想是把一个无序序列
 A 转换成另一个有序序列 B，从
 B中逐个“取出”所有元素，取出的元素即为有序序列「没看明白，不急，后面来张图就搞明白了」。这种算法比快速排序还要快「特定条件下」，它适用于待排序序列中元素的取值范围比较小。比如对某大型公司员工按年龄排序，年龄的取值范围很小，大约在（10-100）之间。

 计数排序

 对数组 arr = [ 8, 1, 4, 6, 2, 3, 5, 4 ] 进行排序，使用计数排序需要找到与其对应的一个有序序列，可以使用数组的下标与 arr
 做一个映射「数组的下标恰好是有序的」。遍历 arr，把 arr 中的元素放到 counArr 中，counArr 的大小是由 arr
 中最大元素和最小元素决定的。「 一图胜千言 」

 图中有个技巧，为了让 countArr 尽可能地小，countArr 的长度使用了 arr 中的最大值 max - arr 中的最小值 min + 1 （max - min
 + 1），arr[i] - min 恰好是 countArr 的下标。countArr 中记录了某个值出现的次数，比如 8 出现过 1 次，则在 countArr
 中的值为 1；4 出现过 2 次，则在 countArr 中的值为 2。

 稳定性：在元素往 countArr 中记录时按顺序遍历，从 countArr
 中取出元素也是按顺序取出，相同元素相对位置不会发生变化，故稳定。

 空间复杂度：需要额外申请空间，复杂度为“桶”的个数，故为 O ( k )， k 为“桶”的个数，也就是 countArr 的长度;

 时间复杂度：最好最坏都为 O(n+k)， k 为“桶”的个数，也就是 countArr 的长度;

 感想

 这种排序不同于其它的「比较」排序，它巧妙地把待排序序列与某个有序序列建立关系，从有序列中通过这种关系再把元素计算出来，就达到了排序的目的。这种对于数据量大，但是数据取值范围比较小的序列非常适用。这种排序思想其实是一种“桶排序”的思想，下一篇会介绍。
 */
+ (NSArray *)countingSort:(NSArray *)datas
{
    // 1.找出数组中最大数和最小数
    NSNumber *max = [datas firstObject];
    NSNumber *min = [datas firstObject];
    for (int i = 0; i < datas.count; i++) {
        NSNumber *item = datas[i];
        if ([item integerValue] > [max integerValue]) {
            max = item;
        }
        if ([item integerValue] < [min integerValue]) {
            min = item;
        }
    }
    // 2.创建一个数组 countArr 来保存 datas 中元素出现的个数
    NSInteger sub = [max integerValue] - [min integerValue] + 1;
    NSMutableArray *countArr = [NSMutableArray arrayWithCapacity:sub];
    for (int i = 0; i < sub; i++) {
        [countArr addObject:@(0)];
    }
    // 3.把 datas 转换成 countArr，使用 datas[i] 与 countArr 的下标对应起来
    for (int i = 0; i < datas.count; i++) {
        NSNumber *aData = datas[i];
        NSInteger index = [aData integerValue] - [min integerValue];
        countArr[index] = @([countArr[index] integerValue] + 1);
    }
    // 4.从countArr中输出结果
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:datas.count];
    for (int i = 0; i < countArr.count; i++) {
        NSInteger count = [countArr[i] integerValue];
        while (count > 0) {
            [resultArr addObject:@(i + [min integerValue])];
            count -= 1;
        }
    }
    return [resultArr copy];
}

/*
 上一篇计数排序也是一种桶排序。桶排序的核心思想是把数据分到若干个“桶”中，对“桶”中的元素进行排序，最终把“桶”中已排序好的数据合并为一个有序序列。

 桶排序

 以 arr = [ 8, 1, 4, 6, 2, 3, 5, 7 ] 为例，排序前需要确定桶的个数，和确定桶中元素的取值范围：

 稳定性：在元素拆分的时候，相同元素会被分到同一组中，合并的时候也是按顺序合并，故稳定。

 空间复杂度：桶的个数加元素的个数，为 O ( n + k );

   时间复杂度：最好为 O( n + k )，最坏为 O（n * n）;

 感想

 计数排序和桶排序的思想都是把数据进行拆分，然后把数据放到不同的桶中，对桶中的元素进行排序，最终合并桶。
 */
+ (NSArray *)bucketSort:(NSArray *)datas
{
    // 1.找出数组中最大数和最小数
    NSNumber *max = [datas firstObject];
    NSNumber *min = [datas firstObject];
    for (int i = 0; i < datas.count; i++) {
        NSNumber *item = datas[i];
        if ([item integerValue] > [max integerValue]) {
            max = item;
        }
        if ([item integerValue] < [min integerValue]) {
            min = item;
        }
    }
    // 2.创建桶，桶的个数为 3
    int maxBucket = 3;
    NSMutableArray *buckets = [NSMutableArray arrayWithCapacity:maxBucket];
    for (int i = 0; i < maxBucket; i++) {
        NSMutableArray *aBucket = [NSMutableArray array];
        [buckets addObject:aBucket];
    }
    // 3.把数据分配到桶中，桶中的数据是有序的
    // a.计算桶中数据的平均值，这样分组数据的时候会把数据放到对应的桶中
    float space = ([max integerValue] - [min integerValue] + 1) / (maxBucket * 1.0);
    for (int i = 0; i < datas.count; i++) {
        // b.根据数据值计算它在桶中的位置
        int index = floor(([datas[i] integerValue] - [min integerValue]) / space);
        NSMutableArray *bucket = buckets[index];
        int maxCount = (int)bucket.count;
        NSInteger minIndex = 0;
        for (int j = maxCount - 1; j >= 0; j--) {
            if ([datas[i] integerValue] > [bucket[j] integerValue]) {
                minIndex = j + 1;
                break;
            }
        }
        [bucket insertObject:datas[i] atIndex:minIndex];
    }
    // 4.把桶中的数据重新组装起来
    NSMutableArray *results = [NSMutableArray array];
    [buckets enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [results addObjectsFromArray:obj];
    }];

    return results;
}

/*
 基数排序是从待排序序列找出可以作为排序的「关键字」，按照「关键字」进行多次排序，最终得到有序序列。比如对 100 以内的序列
 arr =  [ 3,  9,  489,  1,  5, 10, 2, 7, 6, 204 ]进行排序，排序关键字为「个位数」、「十位数」和「百位数」这 3
 个关键字，分别对这 3 个关键字进行排序，最终得到一个有序序列。

 以 arr =  [ 3,  9,  489,  1,  5, 10, 2, 7, 6, 204 ] 为例，最大为 3
 位数，分别对个、十、百位进行排序，最终得到的序列就是有序序列。可以把 arr 看成 [ 003,  009,  489,  001,  005, 010, 002,
 007, 006, 204 ]，这样理解起来比较简单。数字的取值范围为 0-9，故可以分为 10 个桶。

 稳定性：在元素拆分的时候，相同元素会被分到同一组中，合并的时候也是按顺序合并，故稳定。

 空间复杂度：O ( n + k );

   时间复杂度：最好最坏都为 O( n * k );

 感想

 基数排序与其它不同的是它需要对「 多个关键值 」进行多次桶排序。
 */
+ (NSArray *)radixSort:(NSArray *)datas
{
    NSMutableArray *tempDatas;
    NSInteger maxValue = 0;
    int maxDigit = 0;
    int level = 0;
    do {
        // 1.创建10个桶
        NSMutableArray *buckets = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            NSMutableArray *array = [NSMutableArray array];
            [buckets addObject:array];
        }
        // 2.把数保存到桶中
        for (int i = 0; i < datas.count; i++) {
            NSInteger value = [datas[i] integerValue];
            // 求一个数的多次方
            int xx = (level < 1 ? 1 : (pow(10, level)));
            // 求个位数、十位数....
            int mod = value / xx % 10;
            [buckets[mod] addObject:datas[i]];
            // 求最大数为了计算最大数
            if (maxDigit == 0) {
                if (value > maxValue) {
                    maxValue = value;
                }
            }
        }
        // 3.把桶中的数据重新合并
        tempDatas = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            NSMutableArray *aBucket = buckets[i];
            [tempDatas addObjectsFromArray:aBucket];
        }
        // 4.求出数组中最大数的位数, 只需计算一次
        if (maxDigit == 0) {
            while (maxValue > 0) {
                maxValue = maxValue / 10;
                maxDigit++;
            }
        }
        // 5.继续下一轮排序
        datas = tempDatas;
        level += 1;

    } while (level < maxDigit);

    return tempDatas;
}

@end
