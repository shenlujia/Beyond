//
//  HSViewDebugDashLineView.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import <UIKit/UIKit.h>

@interface HSViewDebugDashLineView : UIView

@property (nonatomic, assign) CGFloat dash;
@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, copy) UIColor *lineColor;
@property (nonatomic, assign) BOOL horizontal;

@end
