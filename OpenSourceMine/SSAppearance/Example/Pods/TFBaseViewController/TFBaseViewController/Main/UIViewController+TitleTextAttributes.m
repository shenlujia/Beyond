//
//  UIViewController+TitleTextAttributes.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/5.
//

#import "UIViewController+TitleTextAttributes.h"
#import <objc/runtime.h>

@implementation TFTitleAttributes

- (NSDictionary *)titleAttributes
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    ret[NSForegroundColorAttributeName] = self.textColor;
    ret[NSFontAttributeName] = self.font;
    
    if (self.shadowColor) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = self.shadowColor;
        shadow.shadowOffset = self.shadowOffset;
        ret[NSShadowAttributeName] = shadow;
    }
    
    return  [ret copy];
}

@end

@implementation UIViewController (TitleTextAttributes)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        SEL originalSel = @selector(viewWillAppear:);
//        SEL swizzledSel = @selector(tf_titleTextAttributes_viewWillAppear:);
//        Method originalMethod = class_getInstanceMethod(self, originalSel);
//        Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);
//        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)tf_titleTextAttributes_viewWillAppear:(BOOL)animated
{
    [self tf_titleTextAttributes_viewWillAppear:animated];
    
    NSDictionary *universalAttributes = ({
        TFTitleAttributes *object = self.navigationController.tf_titleAttributes;
        [object titleAttributes];
    });
    NSDictionary *thisAttributes = ({
        TFTitleAttributes *object = self.tf_titleAttributes;
        [object titleAttributes];
    });
    
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    if (universalAttributes) {
        [titleTextAttributes addEntriesFromDictionary:universalAttributes];
    }
    if (thisAttributes) {
        [titleTextAttributes addEntriesFromDictionary:thisAttributes];
    }
    
    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
}

- (TFTitleAttributes *)tf_titleAttributes
{
    const void * key = @selector(tf_titleAttributes);
    TFTitleAttributes *ret = objc_getAssociatedObject(self, key);
    if (!ret) {
        ret = [[TFTitleAttributes alloc] init];
        objc_setAssociatedObject(self, key, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}

@end
