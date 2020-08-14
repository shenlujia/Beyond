//
//  TFBaseViewController_PATCH.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/31.
//

#import "JZNavigationExtension_PATCH.h"
#import <objc/runtime.h>
#import <JZNavigationExtension/JZNavigationExtension.h>
#import <JZNavigationExtension/_JZ-objc-internal.h>
#import "UIImageView+JZPATCH.h"
#import "UIViewController+BarShadowView.h"

#pragma mark - UINavigationController (JZPATCH)

@implementation UINavigationController (JZPATCH)

- (instancetype)init_JZPATCH_WithCoder:(NSCoder *)aDecoder
{
    self = [self init_JZPATCH_WithCoder:aDecoder];
    // 必须调用一次
    __unused UIView *view = self.view;
    return self;
}

- (instancetype)init_JZPATCH_WithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self init_JZPATCH_WithNibName:nibNameOrNil bundle:nibBundleOrNil];
    // 必须调用一次
    __unused UIView *view = self.view;
    return self;
}

- (void)JZPATCH_awakeFromNib
{
    [self JZPATCH_awakeFromNib];
}

- (void)setJz_JZPATCH_navigationBarBackgroundAlphaReal:(CGFloat)jz_navigationBarBackgroundAlpha
{
    [[self.navigationBar jz_backgroundView] setAlpha:jz_navigationBarBackgroundAlpha];
    
    const CGFloat shadowViewAlpha = ({
        NSNumber *ret = self.topViewController.tf_barShadowViewAlpha;
        if (!ret) {
            ret = self.tf_barShadowViewAlpha;
        }
        if (!ret) {
            ret = @(1);
        }
        ret.doubleValue;
    });
    
    UIImageView *shadowView = [self.navigationBar jz_JZPATCH_shadowView];
    if (@available(iOS 10, *)) {
        // 11.x系统自动调用alpha=1，将`setAlpha:`接口屏蔽
        shadowView.jz_JZPATCH_enabled = YES;
        [shadowView set_JZPATCH_AlphaReal:jz_navigationBarBackgroundAlpha * shadowViewAlpha];
    } else {
        // 8.x和9.x的线在jz_backgroundView上面，不用设置jz_backgroundView的alpha
        [shadowView set_JZPATCH_AlphaReal:shadowViewAlpha];
    }
}

@end

#pragma mark - UIViewController (JZPATCH)

@implementation UIViewController (JZPATCH)

- (void)setJz_PATCH_navigationBarTintColor:(UIColor *)jz_navigationBarTintColor
{
    // 适配8.x和9.x
    // barTintColor不能为nil
    if (!jz_navigationBarTintColor) {
        jz_navigationBarTintColor = UIColor.whiteColor;
    }
    [self setJz_PATCH_navigationBarTintColor:jz_navigationBarTintColor];
}

@end

#pragma mark - UINavigationBar (JZPATCH)

@implementation UINavigationBar (JZPATCH)

- (UIImageView *)jz_JZPATCH_shadowView
{
    UIImageView *view = nil;
    @try {
        UIView *backgroundView = [self valueForKeyPath:@"_backgroundView"];
        for (UIView *temp in backgroundView.subviews) {
            if ([temp isKindOfClass:[UIImageView class]]) {
                view = (UIImageView *)temp;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    return view;
}

- (UIView *)jz_JZPATCH_backgroundView
{
    UIView *view = nil;
    
    @try {
        view = [self jz_JZPATCH_backgroundView];
    }
    @catch (NSException *exception) {
        
    }
    return view;
}

@end

#pragma mark - install

__attribute__((constructor)) static void JZNavigationExtension_PATCH_install(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^swizzle)(Class, SEL, SEL) = ^(Class class, SEL originalSel, SEL swizzledSel) {
            Method originalMethod = class_getInstanceMethod(class, originalSel);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSel);
            
            IMP swizzledImpl = method_getImplementation(swizzledMethod);
            const char *swizzledEncoding = method_getTypeEncoding(swizzledMethod);
            if (class_addMethod(class, originalSel, swizzledImpl, swizzledEncoding)) {
                IMP originalImpl = method_getImplementation(originalMethod);
                const char *originalEncoding = method_getTypeEncoding(originalMethod);
                class_replaceMethod(class, swizzledSel, originalImpl, originalEncoding);
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        };
        
        swizzle([UINavigationController class],
                @selector(initWithNibName:bundle:),
                @selector(init_JZPATCH_WithNibName:bundle:));
        swizzle([UINavigationController class],
                @selector(setJz_navigationBarBackgroundAlphaReal:),
                @selector(setJz_JZPATCH_navigationBarBackgroundAlphaReal:));
//        swizzle([UINavigationController class],
//                @selector(initWithCoder:),
//                @selector(init_JZPATCH_WithCoder:));
//        swizzle([UINavigationController class],
//                @selector(awakeFromNib),
//                @selector(JZPATCH_awakeFromNib));
        
        swizzle([UIViewController class],
                @selector(setJz_navigationBarTintColor:),
                @selector(setJz_PATCH_navigationBarTintColor:));
        
        swizzle([UINavigationBar class],
                @selector(jz_backgroundView),
                @selector(jz_JZPATCH_backgroundView));
        
        swizzle([UIImageView class],
                @selector(setAlpha:),
                @selector(set_JZPATCH_Alpha:));
    });
}
