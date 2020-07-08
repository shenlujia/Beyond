//
//  GCDTimer.h
//  Demo
//
//  Created by SLJ on 2020/7/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

+ (GCDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(BOOL (^)(void))block;

- (void)invalidate;

@end
