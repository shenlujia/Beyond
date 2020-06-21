//
//  NSObject+Dealloc.h
//  Demo
//
//  Created by SLJ on 2020/6/20.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Dealloc)

@property (nonatomic, strong) void (^dealloc_callback)(void);

@end
