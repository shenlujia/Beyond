//
//  SSDictionaryDiffUtil.h
//  Beyond
//
//  Created by ZZZ on 2024/8/23.
//  Copyright © 2024 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDictionaryDiffUtil : NSObject

+ (void)test;

+ (NSArray *)diff_keys:(NSDictionary *)original other:(NSDictionary *)other;

@end
