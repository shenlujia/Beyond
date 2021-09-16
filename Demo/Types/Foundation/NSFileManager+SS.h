//
//  NSFileManager+SS.h
//  Beyond
//
//  Created by ZZZ on 2021/9/14.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (SS)

- (NSArray *)acc_contentsAtPath:(NSString *)path error:(NSError **)error;

@end
