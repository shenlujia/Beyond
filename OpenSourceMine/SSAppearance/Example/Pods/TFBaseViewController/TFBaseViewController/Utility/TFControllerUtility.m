//
//  TFControllerUtility.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/28.
//

#import "TFControllerUtility.h"
#import <EHDComponent/EHDComponent.h>
#import <TFWindow/TFWindow.h>

@interface TFControllerUtility () <EHDComponentRoutable>

@end

@implementation TFControllerUtility

EHD_EXPORT_COMPONENT

+ (instancetype)instance
{
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

+ (void)broadcast:(NSString *)name data:(id)data
{
    TransitionBlock block = ^(UIViewController *this, UIViewController *next, id x) {
    };
    
    TFControllerUtility *util = [TFControllerUtility instance];
    [util.uiBus openURL:name
        transitionBlock:block
              extraData:data
             completion:^(id result) {
                 
             }];
}

+ (void)push:(NSString *)name data:(id)data
{
    TransitionBlock block = ^(UIViewController *this, UIViewController *next, id x) {
        UIViewController *context = [TFWindow topViewController];
        if (context && [next isKindOfClass:[UIViewController class]]) {
            [context.navigationController pushViewController:next animated:YES];
        }
    };
    
    TFControllerUtility *util = [TFControllerUtility instance];
    [util.uiBus open:name
     transitionBlock:block
           extraData:data
          completion:^(id result) {
              
          }];
}

@end
