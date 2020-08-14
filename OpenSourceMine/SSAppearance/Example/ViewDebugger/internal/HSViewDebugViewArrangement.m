//
//  HSViewDebugViewArrangement.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import "HSViewDebugViewArrangement.h"
#import "HSViewDebugUtility.h"
#import "HSViewDebugViewPosition.h"

@interface HSViewDebugViewArrangement ()

@end

@implementation HSViewDebugViewArrangement

- (instancetype)initWithView:(UIView *)view
{
    self = [self init];
    if (self) {
        _view = view;
        [self reset];
    }
    return self;
}

- (void)reset
{
    NSMutableArray *positions = [NSMutableArray array];
    for (UIView *view in self.view.subviews) {
        if ([HSViewDebugUtility isViewValid:view]) {
            const CGSize viewSize = view.bounds.size;
            if (viewSize.width > kViewDebugSizeMinValue &&
                viewSize.height > kViewDebugSizeMinValue) {
                HSViewDebugViewPosition *position = ({
                    [[HSViewDebugViewPosition alloc] initWithView:view];
                });
                if (position) {
                    [positions addObject:position];
                }
            }
        }
    }
    const NSInteger count = positions.count;
    for (NSInteger x = 0; x < count; ++x) {
        for (NSInteger y = x + 1; y < count; ++y) {
            HSViewDebugViewPosition *p1 = positions[x];
            HSViewDebugViewPosition *p2 = positions[y];
            [p1 updateWithSiblingView:p2.view];
            [p2 updateWithSiblingView:p1.view];
        }
    }
    _subviewPositions = [positions copy];
}

@end
