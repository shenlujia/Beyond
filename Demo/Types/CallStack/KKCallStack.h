//
//  KKCallStack.h
//  KKMagicHook
//
//  Created by 吴凯凯 on 2020/4/10.
//  Copyright © 2020 吴凯凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach/mach.h>


typedef NS_ENUM(NSUInteger, KKCallStackType) {
    KKCallStackTypeAll,     //全部线程
    KKCallStackTypeMain,    //主线程
    KKCallStackTypeCurrent  //当前线程
};

@interface KKCallStack : NSObject

+ (NSString *)callStackWithType:(KKCallStackType)type;

@end
