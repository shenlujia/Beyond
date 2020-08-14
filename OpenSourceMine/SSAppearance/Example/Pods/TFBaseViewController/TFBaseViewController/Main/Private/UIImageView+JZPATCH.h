//
//  UIImageView+JZPATCH.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/3.
//

#import <UIKit/UIKit.h>

@interface UIImageView (JZPATCH)

@property (nonatomic, assign) BOOL jz_JZPATCH_enabled;

- (void)set_JZPATCH_Alpha:(CGFloat)alpha;
- (void)set_JZPATCH_AlphaReal:(CGFloat)alpha;

@end
