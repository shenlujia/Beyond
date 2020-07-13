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

@property (nonatomic, weak) id block;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *text;

@end

@implementation BlockNotCallChecker

- (void)dealloc
{
    if (_name.length) {
        NSLog(@"%@ not called !!!  %@", _name, _text);
    }
}

+ (instancetype)checkerWithName:(NSString *)name block:(id)block
{
    return [[self alloc] initWithName:name block:block];
}

- (instancetype)initWithName:(NSString *)name block:(id)block
{
    self = [self init];
    if (self) {
        _block = block;
        _name = name;
        _text = [NSString stringWithFormat:@"%@", _block];
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (_block) {
        const void *key = @selector(p_blockNotCallCheckerKey);
        objc_setAssociatedObject(_block, key, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cleanup
{
    if (_block) {
        const void *key = @selector(p_blockNotCallCheckerKey);
        objc_setAssociatedObject(_block, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _block = nil;
    _name = nil;
    _text = nil;
}

- (void)p_blockNotCallCheckerKey
{
    
}

@end
