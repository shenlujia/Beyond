//
//  HSViewDebugDecorator.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import "HSViewDebugDecorator.h"
#import "HSViewDebugSizeView.h"
#import "HSViewDebugMarginView.h"
#import "HSViewDebugViewPosition.h"
#import "HSViewDebugViewArrangement.h"

@interface HSViewDebugDecorator ()

@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, assign, readonly) CGFloat borderWidth;
@property (nonatomic, assign, readonly) CGColorRef borderColor;

@property (nonatomic, strong) HSViewDebugSizeView *sizeLabel;

@property (nonatomic, copy) NSDictionary *marginViews;

@end

@implementation HSViewDebugDecorator

- (void)dealloc
{
    [self cleanup];
}

- (instancetype)initWithView:(UIView *)view
{
    self = [self init];
    [self reloadWithView:view];
    return self;
}

- (void)reloadWithView:(UIView *)view
{
    [self cleanup];
    
    _view = view;
    
    // border
    {
        _borderWidth = view.layer.borderWidth;
        _borderColor = view.layer.borderColor;
        CGColorRetain(self.borderColor);
        
        const CGFloat red = (arc4random() % 256) / 256.0;
        const CGFloat green = (arc4random() % 256) / 256.0;
        const CGFloat blue = (arc4random() % 256) / 256.0;
        view.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
        view.layer.borderColor = [[UIColor colorWithRed:red green:green blue:blue alpha:1] CGColor];
    }
    
    // sizeLabel
    {
        self.sizeLabel = [[HSViewDebugSizeView alloc] initWithHostView:view];
        [view addSubview:self.sizeLabel];
    }
    
    // marginView
    {
        NSMutableDictionary *marginViews = [NSMutableDictionary dictionary];
        HSViewDebugViewArrangement *arrangement = ({
            [[HSViewDebugViewArrangement alloc] initWithView:view];
        });
        for (HSViewDebugViewPosition *position in arrangement.subviewPositions) {
            NSArray *array = [HSViewDebugMarginView marginViewsWithPosition:position];
            for (HSViewDebugMarginView *marginView in array) {
                if (marginView.identifier) {
                    if (!marginViews[marginView.identifier]) {
                        marginViews[marginView.identifier] = marginView;
                        [view addSubview:marginView];
                    }
                }
            }
        }
        
        HSViewDebugViewArrangement *superviewArrangement = ({
            [[HSViewDebugViewArrangement alloc] initWithView:view.superview];
        });
        for (HSViewDebugViewPosition *position in superviewArrangement.subviewPositions) {
            if (position.view == view) {
                NSArray *array = [HSViewDebugMarginView marginViewsWithPosition:position];
                for (HSViewDebugMarginView *marginView in array) {
                    if (marginView.identifier) {
                        marginViews[marginView.identifier] = marginView;
                        [view.superview addSubview:marginView];
                    }
                }
            }
        }
        
        _marginViews = [marginViews copy];
    }
}

- (void)cleanup
{
    self.view.layer.borderWidth = self.borderWidth;
    self.view.layer.borderColor = self.borderColor;
    
    _borderWidth = 0;
    CGColorRelease(self.borderColor);
    _borderColor = nil;
    
    [self.sizeLabel removeFromSuperview];
    self.sizeLabel = nil;
    
    for (UIView *view in self.marginViews.allValues) {
        [view removeFromSuperview];
    }
    self.marginViews = nil;
    
    _view = nil;
}

@end
