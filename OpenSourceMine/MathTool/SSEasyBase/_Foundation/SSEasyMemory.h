//
//  Created by ZZZ on 2020/10/30.
//

#import <Foundation/Foundation.h>

// `object`引用的所有对象
FOUNDATION_EXTERN NSArray * ss_memory_retainedObjects(id object);

// `object`循环引用
FOUNDATION_EXTERN NSArray * ss_memory_findRetainCycles(id object, NSInteger maxCycleLength);

// 找引用了`object`的对象 支持`NSString *`、`Class`、`NSObject *`
FOUNDATION_EXTERN id ss_memory_anyOwnerOf(id object);

// 返回引用了`object`的所有对象
FOUNDATION_EXTERN NSArray * ss_memory_ownersOf(id object);
