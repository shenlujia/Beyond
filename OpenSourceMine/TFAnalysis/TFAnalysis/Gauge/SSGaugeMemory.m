//
//  SSGaugeMemory.m
//  Pods-Demo
//
//  Created by TF020283 on 2018/9/27.
//

#import "SSGaugeMemory.h"
#import <mach/mach.h>

@implementation SSGaugeMemory

- (CGFloat)gauge
{
    task_vm_info_data_t info;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    if (task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&info, &count) != KERN_SUCCESS) {
        return -1;
    }
    return (double)info.phys_footprint / (1024 * 1024);
}

@end
