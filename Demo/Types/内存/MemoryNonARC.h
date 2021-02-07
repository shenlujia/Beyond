//
//  MemoryNonARC.h
//  Beyond
//
//  Created by ZZZ on 2021/2/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryNonARC : NSObject

+ (void)releaseObject:(NSObject *)obj;

@end
