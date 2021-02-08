//
//  MainThreadSetterChecker.h
//  Beyond
//
//  Created by ZZZ on 2021/2/8.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

// 检测对象在非主线程修改属性 打印堆栈

#ifdef __cplusplus
extern "C" {
#endif

void main_thread_setter_checker_on_class(Class c);

void main_thread_setter_checker_set_callback(void (^callback)(NSDictionary *userInfo));

NSDictionary * main_thread_setter_checker_all_records(void);

#ifdef __cplusplus
}
#endif
