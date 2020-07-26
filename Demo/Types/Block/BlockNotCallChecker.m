//
//  BlockNotCallChecker.m
//  Demo
//
//  Created by SLJ on 2020/7/13.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BlockNotCallChecker.h"
#import <objc/runtime.h>

@interface BlockNotCallChecker ()

@property (nonatomic, copy) NSString *name;

@end

@implementation BlockNotCallChecker

- (void)dealloc
{
    if (_name.length) {
        NSLog(@"%@ not called !!!", _name);
        if (_callback) {
            _callback();
        }
    }
}

- (instancetype)initWithName:(NSString *)name
{
    self = [self init];
    if (self) {
        _name = [name copy];
    }
    return self;
}

- (void)didCall
{
    _name = nil;
}

@end
