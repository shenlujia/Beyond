//
//  HSViewDebugDecorateManager.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import "HSViewDebugDecorateManager.h"
#import "HSViewDebugUtility.h"
#import "HSViewDebugDecorator.h"
#import "HSViewDebugSizeView.h"
#import "HSViewDebugMarginView.h"

@interface HSViewDebugDecorateManager ()

@property (nonatomic, strong) NSMapTable *table;

@end

@implementation HSViewDebugDecorateManager

- (instancetype)init
{
    self = [super init];
    self.table = [NSMapTable weakToStrongObjectsMapTable];
    return self;
}

- (void)decorate:(UIView *)view
{
    if (![HSViewDebugUtility isViewValid:view]) {
        return;
    }
    if ([view isKindOfClass:[HSViewDebugSizeView class]] ||
        [view isKindOfClass:[HSViewDebugMarginView class]] ||
        [view isKindOfClass:[UIVisualEffectView class]]) {
        return;
    }
    
    [self clean:view];
    
    HSViewDebugDecorator *info = [[HSViewDebugDecorator alloc] initWithView:view];
    [self.table setObject:info forKey:view];
    
    for (UIView *subview in view.subviews) {
        [self decorate:subview];
    }
}

- (void)clean:(UIView *)view
{
    HSViewDebugDecorator *info = [self.table objectForKey:view];
    if (info) {
        [self.table removeObjectForKey:view];
        for (UIView *subview in view.subviews) {
            [self clean:subview];
        }
    }
}

- (void)cleanAll
{
    NSArray *views = self.table.keyEnumerator.allObjects;
    for (UIView *view in views) {
        [self clean:view];
    }
}

@end
