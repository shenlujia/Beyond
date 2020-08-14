//
//  KVO_HS_Controller.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "KVO_HS_Controller.h"
#import "NSObject+HSKVO.h"
#import "Person.h"
#import "Toast.h"

typedef NS_ENUM(NSInteger, KVO_HS_Type) {
    KVO_HS_Type_self_KVOControllerNonRetaining = 0,
    KVO_HS_Type_object_KVOControllerNonRetaining
};

@interface KVO_HS_Controller ()

@end

@implementation KVO_HS_Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[@"self.KVOControllerNonRetaining 观察object crash",
                  @"object.KVOControllerNonRetaining 观察object crash"];
}

- (void)didSelectIndex:(NSInteger)index
{
    switch (index) {
        case KVO_HS_Type_self_KVOControllerNonRetaining: {
            
            id block = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
            };
            
            Person *person = [[Person alloc] init];
            
            [self.HSKVO observe:person
                        keyPath:@"name"
                        options:NSKeyValueObservingOptionNew
                          block:block];
            person.name = @"SSS";
            
            break;
        }
        case KVO_HS_Type_object_KVOControllerNonRetaining: {
            
            id block = ^(id observer, id object, NSDictionary *change) {
                NSLog(@"value = %@", change[NSKeyValueChangeNewKey]);
            };
            
            Person *person = [[Person alloc] init];
            
            [person.HSKVO observe:person
                          keyPath:@"name"
                          options:NSKeyValueObservingOptionNew
                            block:block];
            person.name = @"hehe";
            
            break;
        }
        default: {
            break;
        }
    }
}

@end
