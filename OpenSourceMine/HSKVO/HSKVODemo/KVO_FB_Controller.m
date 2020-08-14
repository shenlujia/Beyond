//
//  KVO_FB_Controller.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "KVO_FB_Controller.h"
#import <KVOController/KVOController.h>
#import "Person.h"
#import "Toast.h"

typedef NS_ENUM(NSInteger, KVO_FB_Type) {
    KVO_FB_Type_multi_observe = 0,
    KVO_FB_Type_self_KVOControllerNonRetaining,
    KVO_FB_Type_object_KVOControllerNonRetaining
};

@interface KVO_FB_Controller ()

@end

@implementation KVO_FB_Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[@"多次 observe，只回调一次",
                  @"self.KVOControllerNonRetaining observe object -> crash",
                  @"object.KVOControllerNonRetaining observe object -> crash"];
}

- (void)didSelectIndex:(NSInteger)index
{
    switch (index) {
        case KVO_FB_Type_multi_observe: {
            
            __block NSInteger count = 0;
            
            NSLog(@"应该打印两次 这里只打印一次");
            id block1 = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
                ++count;
            };
            id block2 = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
                ++count;
            };
            
            Person *person = [[Person alloc] init];
            
            [self.KVOController observe:person
                                keyPath:@"name"
                                options:NSKeyValueObservingOptionNew
                                  block:block1];
            [self.KVOController observe:person
                                keyPath:@"name"
                                options:NSKeyValueObservingOptionNew
                                  block:block2];
            [self.KVOController observe:person
                                keyPath:@"name"
                                options:NSKeyValueObservingOptionNew
                                 action:@selector(callbackAction:)];
            [self.KVOController observe:person
                                keyPath:@"name"
                                options:NSKeyValueObservingOptionNew
                                 action:@selector(callbackAction:)];
           
            person.name = @"YEAH";
            
//            NSParameterAssert(count == 2);
            
            break;
        }
        case KVO_FB_Type_self_KVOControllerNonRetaining: {
            
            id block = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
            };
            
            Person *person = [[Person alloc] init];
            
            [self.KVOControllerNonRetaining observe:person
                                            keyPath:@"name"
                                            options:NSKeyValueObservingOptionNew
                                              block:block];
            person.name = @"YEAH";
            
            break;
        }
        case KVO_FB_Type_object_KVOControllerNonRetaining: {
            
            id block = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
            };
            
            Person *person = [[Person alloc] init];
            
            [person.KVOControllerNonRetaining observe:person
                                              keyPath:@"name"
                                              options:NSKeyValueObservingOptionNew
                                                block:block];
            person.name = @"YEAH";
            
            break;
        }
        default: {
            break;
        }
    }
}

- (void)callbackAction:(id)o
{
    NSLog(@"callbackAction");
}

@end
