//
//  SSProgressHUDStyle.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDStyle.h"
#import <objc/runtime.h>
#import "SSProgressHUDContentView.h"

const CGFloat kSSProgressHUDDefaultDuration = 100000000;

@implementation SSProgressHUDStyle

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    
    self.text = nil;
    self.attributedText = nil;
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = [UIColor whiteColor];
    self.image = nil;
    self.indicatorStyle = UIActivityIndicatorViewStyleWhite;
    
    self.ignoreInteractionEvents = YES;
    
    self.duration = kSSProgressHUDDefaultDuration;
    self.superview = nil;
    
    self.contentPadding = UIEdgeInsetsMake(12, 12, 12, 12);
    self.contentMargin = UIEdgeInsetsMake(15, 15, 15, 15);
    self.offset = CGPointZero;
    
    self.verticalSpace = 5;
    self.horizontalSpace = 5;
    
    self.layout = @[@(SSProgressHUDItemText),
                    @(SSProgressHUDItemImage),
                    @(SSProgressHUDItemIndicator)];
    
    [self resetViewsWithStyle:nil];

    return self;
}

- (void)resetViewsWithStyle:(SSProgressHUDStyle *)style
{
    _backgroundView = [[UIView alloc] init];
    if (style) {
        self.backgroundView.backgroundColor = style.backgroundView.backgroundColor;
        self.backgroundView.layer.borderWidth = style.backgroundView.layer.borderWidth;
        self.backgroundView.layer.borderColor = style.backgroundView.layer.borderColor;
        self.backgroundView.layer.cornerRadius = style.backgroundView.layer.cornerRadius;
        self.backgroundView.layer.masksToBounds = style.backgroundView.layer.masksToBounds;
    } else {
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
    }
    
    _contentView = [[SSProgressHUDContentView alloc] init];
    if (style) {
        self.contentView.backgroundColor = style.contentView.backgroundColor;
        self.contentView.layer.borderWidth = style.contentView.layer.borderWidth;
        self.contentView.layer.borderColor = style.contentView.layer.borderColor;
        self.contentView.layer.cornerRadius = style.contentView.layer.cornerRadius;
        self.contentView.layer.masksToBounds = style.contentView.layer.masksToBounds;
    } else {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.contentView.layer.cornerRadius = 14;
        self.contentView.layer.masksToBounds = YES;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    SSProgressHUDStyle *style = [[SSProgressHUDStyle alloc] init];
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(SSProgressHUDStyle.class, &count);
    
    for (NSInteger idx = 0; idx < count; ++idx) {
        objc_property_t property = properties[idx];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        id value = [self valueForKey:key];
        [style setValue:value forKey:key];
    }
    
    free(properties);
    
    [style resetViewsWithStyle:self];
    
    return style;
}

+ (SSProgressHUDStyle *)defaultStyleForState:(SSProgressHUDState)state
{
    NSMutableDictionary *styles = [self defaultStyles];
    SSProgressHUDStyle *style = [styles[@(state)] copy];
    if (!style) {
        style = [[SSProgressHUDStyle alloc] init];
    }
    return style;
}

+ (void)setDefaultStyle:(SSProgressHUDStyle *)style forState:(SSProgressHUDState)state
{
    NSMutableDictionary *styles = [self defaultStyles];
    styles[@(state)] = [style copy];
}

+ (NSMutableDictionary *)defaultStyles
{
    static NSMutableDictionary *defaultStyles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *styles = [NSMutableDictionary dictionary];
        NSNumber *textItem = @(SSProgressHUDItemText);
        NSNumber *indicatorItem = @(SSProgressHUDItemIndicator);
        
        styles[@(SSProgressHUDStateLoading)] = ({
            SSProgressHUDStyle *style = [[SSProgressHUDStyle alloc] init];
            style.indicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
            style.contentPadding = UIEdgeInsetsMake(30, 30, 30, 30);
            style.ignoreInteractionEvents = YES;
            style.layout = @[indicatorItem, textItem];
            style;
        });
        styles[@(SSProgressHUDStateInfo)] = ({
            SSProgressHUDStyle *style = [[SSProgressHUDStyle alloc] init];
            style.ignoreInteractionEvents = NO;
            style.backgroundView.backgroundColor = nil;
            style.layout = @[textItem];
            style;
        });
        styles[@(SSProgressHUDStateSuccess)] = ({
            SSProgressHUDStyle *style = [[SSProgressHUDStyle alloc] init];
            style.ignoreInteractionEvents = NO;
            style.backgroundView.backgroundColor = nil;
            style.layout = @[textItem];
            style;
        });
        styles[@(SSProgressHUDStateError)] = ({
            SSProgressHUDStyle *style = [[SSProgressHUDStyle alloc] init];
            style.ignoreInteractionEvents = NO;
            style.backgroundView.backgroundColor = nil;
            style.layout = @[textItem];
            style;
        });
        
        defaultStyles = [styles mutableCopy];
    });
    return defaultStyles;
}

@end
