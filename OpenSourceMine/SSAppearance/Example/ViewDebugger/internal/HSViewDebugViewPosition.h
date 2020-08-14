//
//  HSViewDebugViewPosition.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import <UIKit/UIKit.h>

@interface HSViewDebugViewPosition : NSObject

@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, assign, readonly) CGFloat right;
@property (nonatomic, assign, readonly) CGFloat top;
@property (nonatomic, assign, readonly) CGFloat bottom;

@property (nonatomic, weak, readonly) UIView *leftView;
@property (nonatomic, weak, readonly) UIView *rightView;
@property (nonatomic, weak, readonly) UIView *topView;
@property (nonatomic, weak, readonly) UIView *bottomView;

- (instancetype)initWithView:(UIView *)view;

- (void)updateWithSiblingView:(UIView *)siblingView;

@end
