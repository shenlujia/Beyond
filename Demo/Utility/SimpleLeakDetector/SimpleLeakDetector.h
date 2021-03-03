//
//  SimpleLeakDetector.h
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSLeakDetectorRecord.h"

@interface SimpleLeakDetector : NSObject

+ (void)start;

+ (SSLeakDetectorRecord *)allLiveObjects;

+ (NSArray *)retainedObjectsWithObject:(id)object;

+ (NSArray *)ownersOfObject:(id)object;
+ (NSArray *)ownersOfClass:(Class)c;
+ (id)anyOwnerOfClass:(Class)c;



@end
