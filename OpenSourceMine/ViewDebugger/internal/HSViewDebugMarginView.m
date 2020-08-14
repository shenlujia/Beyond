//
//  HSViewDebugMarginView.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import "HSViewDebugMarginView.h"
#import "HSViewDebugUtility.h"
#import "HSViewDebugViewPosition.h"
#import "HSViewDebugDashLineView.h"

@interface HSViewDebugMarginView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) UIRectEdge edge;
@property (nonatomic, strong) HSViewDebugDashLineView *dash0;
@property (nonatomic, strong) HSViewDebugDashLineView *dash1;

@end

@implementation HSViewDebugMarginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = NO;
    
    self.label = ({
        UILabel *view = [[UILabel alloc] init];
        view.textAlignment = NSTextAlignmentCenter;
        view.textColor = UIColor.redColor;
        view.font = [UIFont systemFontOfSize:8];
        [view sizeToFit];
        view;
    });
    [self addSubview:self.label];
    
    self.dash0 = [[HSViewDebugDashLineView alloc] init];
    [self addSubview:self.dash0];
    
    self.dash1 = [[HSViewDebugDashLineView alloc] init];
    [self addSubview:self.dash1];
    
    return self;
}

- (void)updateWithValue:(CGFloat)value
                   edge:(UIRectEdge)edge
                   view:(UIView *)view
              otherView:(UIView *)otherView
{
    self.edge = edge;
    
    self.label.text = [HSViewDebugUtility stringWithFloat:fabs(value)];
    [self.label sizeToFit];
    
    const BOOL horizontal = (edge == UIRectEdgeLeft || edge == UIRectEdgeRight);
    self.dash0.horizontal = horizontal;
    self.dash0.lineColor = self.label.textColor;
    self.dash1.horizontal = horizontal;
    self.dash1.lineColor = self.label.textColor;
    
    const CGSize textSize = self.label.bounds.size;
    const CGSize superviewSize = view.superview.bounds.size;
    const CGFloat centerX = CGRectGetMidX(view.frame);
    const CGFloat centerY = CGRectGetMidY(view.frame);
    switch (edge) {
        case UIRectEdgeLeft: {
            
            CGRect frame = CGRectMake(0, 0, fabs(value), textSize.height);
            frame.origin.y = centerY - frame.size.height / 2;
            if (value < 0) {
                NSParameterAssert(view.superview == otherView);
                frame.origin.x = value;
            } else {
                frame.origin.x = CGRectGetMinX(view.frame) - value;
            }
            self.frame = frame;
            
            break;
        }
        case UIRectEdgeRight: {
            
            CGRect frame = CGRectMake(0, 0, fabs(value), textSize.height);
            frame.origin.y = centerY - frame.size.height / 2;
            if (value < 0) {
                NSParameterAssert(view.superview == otherView);
                frame.origin.x = superviewSize.width + fabs(value);
            } else {
                frame.origin.x = CGRectGetMaxX(view.frame);
            }
            self.frame = frame;
            
            break;
        }
        case UIRectEdgeTop: {
            
            CGRect frame = CGRectMake(0, 0, textSize.width, fabs(value));
            frame.origin.x = centerX - frame.size.width / 2;
            if (value < 0) {
                NSParameterAssert(view.superview == otherView);
                frame.origin.y = value;
            } else {
                frame.origin.y = CGRectGetMinY(view.frame) - value;
            }
            self.frame = frame;
            
            break;
        }
        case UIRectEdgeBottom: {
            
            CGRect frame = CGRectMake(0, 0, textSize.width, fabs(value));
            frame.origin.x = centerX - frame.size.width / 2;
            if (value < 0) {
                NSParameterAssert(view.superview == otherView);
                frame.origin.y = superviewSize.height + fabs(value);
            } else {
                frame.origin.y = CGRectGetMaxY(view.frame);
            }
            self.frame = frame;
            
            break;
        }
        default: {
            break;
        }
    }
    
    NSString *key = nil;
    if (edge == UIRectEdgeLeft || edge == UIRectEdgeRight) {
        key = [NSString stringWithFormat:@"%.2f,%.2f", self.frame.origin.x, self.frame.size.width];
    } else {
        key = [NSString stringWithFormat:@"%.2f,%.2f", self.frame.origin.y, self.frame.size.height];
    }
    _identifier = [NSString stringWithFormat:@"(%@)(%@)", key, @(edge)];
}

+ (NSArray *)marginViewsWithPosition:(HSViewDebugViewPosition *)position
{
    NSMutableArray *array = [NSMutableArray array];
    
    // left
    if (fabs(position.left) > kViewDebugSizeMinValue) {
        HSViewDebugMarginView *marginView = [[HSViewDebugMarginView alloc] init];
        [marginView updateWithValue:position.left
                               edge:UIRectEdgeLeft
                               view:position.view
                          otherView:position.leftView];
        [array addObject:marginView];
    }
    // right
    if (fabs(position.right) > kViewDebugSizeMinValue) {
        HSViewDebugMarginView *marginView = [[HSViewDebugMarginView alloc] init];
        [marginView updateWithValue:position.right
                               edge:UIRectEdgeRight
                               view:position.view
                          otherView:position.rightView];
        [array addObject:marginView];
    }
    // top
    if (fabs(position.top) > kViewDebugSizeMinValue) {
        HSViewDebugMarginView *marginView = [[HSViewDebugMarginView alloc] init];
        [marginView updateWithValue:position.top
                               edge:UIRectEdgeTop
                               view:position.view
                          otherView:position.topView];
        [array addObject:marginView];
    }
    // bottom
    if (fabs(position.bottom) > kViewDebugSizeMinValue) {
        HSViewDebugMarginView *marginView = [[HSViewDebugMarginView alloc] init];
        [marginView updateWithValue:position.bottom
                               edge:UIRectEdgeBottom
                               view:position.view
                          otherView:position.bottomView];
        [array addObject:marginView];
    }
    
    return array;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGSize size = self.bounds.size;
    const CGSize textSize = self.label.bounds.size;
    
    CGRect frame = CGRectMake(0, 0, textSize.width, textSize.height);
    frame.origin.x = (size.width - textSize.width) / 2;
    frame.origin.y = (size.height - textSize.height) / 2;
    self.label.frame = frame;
    
    if (self.edge == UIRectEdgeLeft || self.edge == UIRectEdgeRight) {
        
        frame = CGRectMake(0, size.height / 2, 0, 1 / UIScreen.mainScreen.scale);
        frame.size.width = CGRectGetMinX(self.label.frame);
        self.dash0.frame = frame;
        
        frame.origin.x = CGRectGetMaxX(self.label.frame);
        frame.size.width = size.width - frame.origin.x;
        self.dash1.frame = frame;
        
    } else {
        
        frame = CGRectMake(size.width / 2, 0, 1 / UIScreen.mainScreen.scale, 0);
        frame.size.height = CGRectGetMinY(self.label.frame);
        self.dash0.frame = frame;
        
        frame.origin.y = CGRectGetMaxY(self.label.frame);
        frame.size.height = size.height - frame.origin.y;
        self.dash1.frame = frame;
    }
    
    void (^hideViewIfNeeded)(id) = ^(HSViewDebugDashLineView *view) {
        const CGSize size = view.bounds.size;
        if (view.horizontal) {
            view.hidden = (size.width < kViewDebugSizeMinValue);
        } else {
            view.hidden = (size.height < kViewDebugSizeMinValue);
        }
    };
    hideViewIfNeeded(self.dash0);
    hideViewIfNeeded(self.dash1);
}

@end
