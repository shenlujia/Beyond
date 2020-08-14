//
//  TFShadowDecorator.m
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import "TFShadowDecorator.h"

@implementation TFShadowDecorator

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _shadowColor = nil;
        _shadowOpacity = 0;
        _shadowOffset = CGSizeMake(0, -3);
        _shadowRadius = 3;
        _shadowPath = nil;
    }
    
    return self;
}

- (void)decorate:(CALayer *)layer
{
    layer.shadowColor = self.shadowColor.CGColor;
    layer.shadowOpacity = self.shadowOpacity;
    layer.shadowOffset = self.shadowOffset;
    layer.shadowRadius = self.shadowRadius;
    layer.shadowPath = self.shadowPath.CGPath;
}

@end
