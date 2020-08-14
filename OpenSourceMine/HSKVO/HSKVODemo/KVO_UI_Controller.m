//
//  KVO_UI_Controller.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "KVO_UI_Controller.h"
#import "Person.h"
#import "Toast.h"

typedef NS_ENUM(NSInteger, KVO_UI_Type) {
    KVO_UI_Type_Key = 0,
    KVO_UI_Type_KeyPath,
    KVO_UI_Type_Array
};

@interface KVO_UI_Controller ()

@end

@implementation KVO_UI_Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[@"observe key",
                  @"observe keyPath",
                  @"observe array"];
}

- (void)didSelectIndex:(NSInteger)index
{
    switch (index) {
        case KVO_UI_Type_Key: {
            
            Person *person = [[Person alloc] init];
            Toast *toast = [[Toast alloc] init];
            
            [person addObserver:self
                     forKeyPath:@"name"
                        options:NSKeyValueObservingOptionNew
                        context:(__bridge void *)(toast)];
            
            person.name = @"SLJ";
            
            [person removeObserver:self forKeyPath:@"name"];
            
            break;
        }
        case KVO_UI_Type_KeyPath: {
            
            Person *person = [[Person alloc] init];
            Toast *toast = [[Toast alloc] init];
            
            [person addObserver:self
                     forKeyPath:@"car.engine.power"
                        options:NSKeyValueObservingOptionNew
                        context:(__bridge void *)(toast)];
            
            person.car.engine.power = @"1800马力";
            
            [person removeObserver:self forKeyPath:@"car.engine.power"];
            
            break;
        }
        case KVO_UI_Type_Array: {
            
            Person *person = [[Person alloc] init];
            Toast *toast = [[Toast alloc] init];
            
            [person addObserver:self
                     forKeyPath:@"userInfo"
                        options:NSKeyValueObservingOptionNew
                        context:(__bridge void *)(toast)];
            
            [[person mutableArrayValueForKey:@"userInfo"] addObject:@"1"];
            [[person mutableArrayValueForKey:@"userInfo"] addObject:@"2"];
            [[person mutableArrayValueForKey:@"userInfo"] addObject:@"3"];
            
            [person removeObserver:self forKeyPath:@"userInfo"];
            
            break;
        }
        default: {
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    Toast *toast = (__bridge Toast *)(context);
    id value = change[NSKeyValueChangeNewKey];
    NSString *desc = [NSString stringWithFormat:@"new %@ = %@", keyPath, value];
    [toast insert:desc];
    
    if ([keyPath isEqualToString:@"name"]) {
        
    } else if ([keyPath isEqualToString:@"car.engine.power"]) {
        
    } else if ([keyPath isEqualToString:@"userInfo"]) {
        
    } else if ([keyPath isEqualToString:@"car"]) {
        
    }
}

@end
