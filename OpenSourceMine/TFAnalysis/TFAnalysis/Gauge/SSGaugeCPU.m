//
//  SSGaugeCPU.m
//  Pods-Demo
//
//  Created by TF020283 on 2018/9/27.
//

#import "SSGaugeCPU.h"
#import <mach/mach_init.h>
#import <mach/vm_map.h>
#import <mach/task.h>
#import <mach/thread_act.h>

@implementation SSGaugeCPU

- (CGFloat)gauge
{
    kern_return_t kern_ret;
    thread_array_t threadList;
    mach_msg_type_number_t threadCount;
    kern_ret = task_threads(mach_task_self(), &threadList, &threadCount);
    if (kern_ret != KERN_SUCCESS) {
        return -1;
    }
    
    double total = 0;
    thread_info_data_t threadInfo;
    thread_basic_info_t threadBasicInfo;
    for (int idx = 0; idx < threadCount; ++idx) {
        thread_inspect_t thread = threadList[idx];
        mach_msg_type_number_t count;
        kern_ret = thread_info(thread, THREAD_BASIC_INFO, (thread_info_t)threadInfo, &count);
        if (kern_ret != KERN_SUCCESS) {
            total = -1;
            break;
        }
        
        threadBasicInfo = (thread_basic_info_t)threadInfo;
        if (!(threadBasicInfo->flags & TH_FLAGS_IDLE)) {
            total += threadBasicInfo->cpu_usage;
        }
    }
    
    // 回收内存 防止内存泄漏
    vm_deallocate(mach_task_self(), (vm_offset_t)threadList, threadCount * sizeof(thread_t));
    
    if (total < 0) {
        return -1;
    }
    
    return total / (double)TH_USAGE_SCALE * 100.0;
}

@end
