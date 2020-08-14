//
//  TFPopTask.m
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "TFPopTask.h"

@implementation TFPopTask

- (instancetype)initWithView:(UIView *)view
               configuration:(TFPopConfiguration *)configuration
{
    self = [self init];
    if (self) {
        _view = view;
        _configuration = configuration;
    }
    return self;
}

- (CGRect)viewBeginFrame
{
    TFPopConfiguration *configuration = self.configuration;
    const CGSize size = self.view.superview.bounds.size;
    const CGSize viewSize = [self.view sizeThatFits:size];
    
    const TFPopOptions options = configuration.beginOptions;
    CGRect frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    
    if (options & TFPopLeft) {
        frame.origin.x = -size.width;
    } else if (options & TFPopRight) {
        frame.origin.x = size.width;
    } else if (options & TFPopMiddle) {
        frame.origin.x = (size.width - frame.size.width) / 2;
    }
    
    if (options & TFPopTop) {
        frame.origin.y = -size.height;
    } else if (options & TFPopBottom) {
        frame.origin.y = size.height;
    } else if (options & TFPopMiddle) {
        frame.origin.y = (size.height - frame.size.height) / 2;
    }
    
    return frame;
}

- (void)getShowFrame:(CGRect *)viewFrame backgroundViewFrame:(CGRect *)backgroundViewFrame
{
    TFPopConfiguration *configuration = self.configuration;
    const CGSize size = self.view.superview.bounds.size;
    const CGSize viewSize = [self.view sizeThatFits:size];
    
    const UIEdgeInsets safeAreaInsets = ({
        UIEdgeInsets ret = UIEdgeInsetsZero;
        if (configuration.automaticallyAdjustsSafeAreaInsets) {
            if (@available(iOS 11.0, *)) {
                UIWindow *window = UIApplication.sharedApplication.delegate.window;
                ret = window.safeAreaInsets;
            }
        }
        
        UIView *superview = self.view.superview;
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        CGRect rect = [superview convertRect:CGRectMake(0, 0, size.width, size.height)
                                    toView:window];
        if (rect.origin.x != 0) {
            ret.left = 0;
        }
        if (rect.origin.y != 0) {
            ret.top = 0;
        }
        if (rect.origin.x + rect.size.width != window.bounds.size.width) {
            ret.top = 0;
        }
        if (rect.origin.y + rect.size.height != window.bounds.size.height) {
            ret.bottom = 0;
        }
        
        ret;
    });
    
    const TFPopOptions options = configuration.showOptions;
    CGRect frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGRect backgroundFrame = frame;
    
    if (options & TFPopLeft) {
        frame.origin.x = safeAreaInsets.left;
        backgroundFrame.origin.x = 0;
        backgroundFrame.size.width += safeAreaInsets.left;
    } else if (options & TFPopRight) {
        frame.origin.x = size.width - frame.size.width - safeAreaInsets.right;
        backgroundFrame.origin.x = size.width - frame.size.width;
        backgroundFrame.size.width += safeAreaInsets.right;
    } else if (options & TFPopMiddle) {
        frame.origin.x = (size.width - frame.size.width) / 2;
        backgroundFrame.origin.x = (size.width - frame.size.width) / 2;
    }
    
    if (options & TFPopTop) {
        frame.origin.y = safeAreaInsets.top;
        backgroundFrame.origin.y = 0;
        backgroundFrame.size.height += safeAreaInsets.top;
    } else if (options & TFPopBottom) {
        frame.origin.y = size.height - frame.size.height - safeAreaInsets.bottom;
        backgroundFrame.origin.y = size.height - frame.size.height;
        backgroundFrame.size.height += safeAreaInsets.bottom;
    } else if (options & TFPopMiddle) {
        frame.origin.y = (size.height - frame.size.height) / 2;
        backgroundFrame.origin.y = (size.height - frame.size.height) / 2;
    }
    
    if (viewFrame) {
        *viewFrame = frame;
    }
    if (backgroundViewFrame) {
        *backgroundViewFrame = backgroundFrame;
    }
}

- (CGRect)viewEndFrame
{
    TFPopConfiguration *configuration = self.configuration;
    const CGSize size = self.view.superview.bounds.size;
    const CGSize viewSize = [self.view sizeThatFits:size];
    
    const TFPopOptions options = configuration.endOptions;
    CGRect frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    
    if (options & TFPopLeft) {
        frame.origin.x = -size.width;
    } else if (options & TFPopRight) {
        frame.origin.x = size.width;
    } else if (options & TFPopMiddle) {
        frame.origin.x = (size.width - frame.size.width) / 2;
    }
    
    if (options & TFPopTop) {
        frame.origin.y = -size.height;
    } else if (options & TFPopBottom) {
        frame.origin.y = size.height;
    } else if (options & TFPopMiddle) {
        frame.origin.y = (size.height - frame.size.height) / 2;
    }
    
    return frame;
}

- (CGFloat)viewBeginAlpha
{
    const TFPopOptions options = self.configuration.beginOptions;
    if (options & TFPopAlpha) {
        return 0;
    }
    return 1;
}

- (CGFloat)viewShowAlpha
{
    return 1;
}

- (CGFloat)viewEndAlpha
{
    const TFPopOptions options = self.configuration.endOptions;
    if (options & TFPopAlpha) {
        return 0;
    }
    return 1;
}

@end
