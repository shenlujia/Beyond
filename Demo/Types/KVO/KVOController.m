//
//  KVOController.m
//  Demo
//
//  Created by SLJ on 2020/4/20.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "KVOController.h"

@interface KVOTestObj : NSObject
{
  @public
    NSString *nake_a;
    NSString *_nake_b;
}

@property (nonatomic, copy) NSString *prop_s;

@end

@implementation KVOTestObj

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"undefinedKey = %@, value = %@", key, value);
}

@end

@interface KVOController ()

@property (nonatomic, strong) KVOTestObj *obj;

@end

@implementation KVOController

- (void)dealloc
{
    [self.obj removeObserver:self forKeyPath:@"prop_s"];
    [self.obj removeObserver:self forKeyPath:@"nake_a"];
    [self.obj removeObserver:self forKeyPath:@"nake_b"];
    //    [self.obj removeObserver:self forKeyPath:@"_nake_b"];
//    [self.obj removeObserver:self forKeyPath:@"not_exist"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.obj = [[KVOTestObj alloc] init];

    [self.obj addObserver:self forKeyPath:@"prop_s" options:NSKeyValueObservingOptionNew context:nil];
    [self.obj addObserver:self forKeyPath:@"nake_a" options:NSKeyValueObservingOptionNew context:nil];
    [self.obj addObserver:self forKeyPath:@"nake_b" options:NSKeyValueObservingOptionNew context:nil];
    //    [self.obj addObserver:self forKeyPath:@"_nake_b" options:NSKeyValueObservingOptionNew context:nil]; // 打开就崩溃
    //    [self.obj addObserver:self forKeyPath:@"not_exist" options:NSKeyValueObservingOptionNew context:nil]; // 注释了就不会崩溃

    NSLog(@"====== set ======");
    self.obj.prop_s = @"set1";
    self.obj->nake_a = @"set2";
    self.obj->_nake_b = @"set3";

    NSLog(@"====== KVC ======");
    [self.obj setValue:@"kvc1" forKey:@"prop_s"];
    [self.obj setValue:@"kvc2" forKey:@"nake_a"];
    [self.obj setValue:@"kvc3" forKey:@"nake_b"];
    [self.obj setValue:@"kvc4" forKey:@"_nake_b"];
    [self.obj setValue:@"kvc5" forKey:@"not_exist"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    NSLog(@"KVO %@ = %@", keyPath, change[NSKeyValueChangeNewKey]);
}

@end
