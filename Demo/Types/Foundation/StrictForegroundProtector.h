//
//  StrictForegroundProtector.h
//  Beyond
//
//  Created by ZZZ on 2022/7/7.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrictForegroundProtector : NSObject

+ (void)handleAction:(void (^)(void))action;

@end
