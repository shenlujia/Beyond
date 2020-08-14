//
//  TFAppearanceObject.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import <UIKit/UIKit.h>

@protocol TFAppearance <NSObject>
@required
- (void)decorate:(__kindof UIView *)view;
@property (nonatomic, strong, readonly) void (^decorate)(UIView *view);
@end
