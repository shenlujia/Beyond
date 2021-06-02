//
//  KVCController.m
//  Demo
//
//  Created by SLJ on 2020/7/7.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "KVCController.h"
#import "MacroHeader.h"
#import "Logger.h"

@interface KVCTestObj : NSObject

@end

@implementation KVCTestObj

- (void)getVoidProp
{
    
}

@end

@interface KVCController ()

@end

@implementation KVCController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     对于结果，如果是引用对象，直接返回。如果是标量，使用NSNumber包装并返回。否则，使用NSValue包装并返回。
     所以，使用KVC来操作实例对象的属性和实例变量是非常容易的事。即，KVO与runtime（能够查询到实例对象的所有实例变量和属性等）结合起来，可以做到对任意属性和实例变量进行查询和修改，尽管一些属性和实例变量并未暴露出来。
     -get<Key>, -<key>, -is<Key>等getter方法，
     -countOf<Key, -objectIn<Key>AtIndex:
     _<key>, _is<Key>, <key>, is<Key>
     */
    [self test:@"valueForKey:" set:nil action:@selector(test_get)];
    
    [self test:@"setValue:forKey:" set:nil action:@selector(test_set)];
    
    /*
     NSArray
     -valueForKey:方法会遍历每个元素，执行-valueForKey:，并且结果组合成一个新的数组并返回。对于返回nil的情况，会使用NSNull来代替。
     -setValue:forKey:则会遍历每个元素，执行-setValue:forKey:方法。
     */
    
    /*
     NSSet
     -valueForKey:方法会遍历每个元素，执行-valueForKey:，并且结果组合成一个新的set并返回。
     注意，对于-valueForKey:的结果为nil的元素，不会将其结果nil存入返回的set中。这一点与NSArray不同。
     */
}

- (void)test_get
{
    KVCTestObj *obj = [[KVCTestObj alloc] init];
    __unused id void_prop1 = [obj valueForKey:@"voidProp"];
    __unused id void_prop2 = [obj valueForKey:@"VoidProp"];
    
    PRINT_BLANK_LINE
    
    @try {
        __unused id not_exist_prop = [obj valueForKey:@"abcdefg"];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    PRINT_BLANK_LINE
}

- (void)test_set
{
    CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
            NSLog(@"main queue task 4");
            CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
                NSLog(@"main queue task 5");
            });
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            NSLog(@"main queue task 6");
        });

    PRINT_BLANK_LINE
}

@end
