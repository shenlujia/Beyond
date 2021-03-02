//
//  SimpleLeakDetectorInternal.h
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <set>

using namespace std;

@interface SimpleLeakDetectorInternal : NSObject

+ (NSArray *)retainedObjectsWithObject:(id)object;

@end
