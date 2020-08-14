//
//  TFShadowDecorator.h
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import <Foundation/Foundation.h>

@interface TFShadowDecorator : NSObject

@property (nonatomic, copy) UIColor *shadowColor; // Defaults to nil.
@property (nonatomic, assign) CGFloat shadowOpacity; // Defaults to 0.
@property (nonatomic, assign) CGSize shadowOffset; // Defaults to (0, -3).
@property (nonatomic, assign) CGFloat shadowRadius; // Defaults to 3.
@property (nonatomic, copy) UIBezierPath *shadowPath; // Defaults to nil.

- (void)decorate:(CALayer *)layer;

@end
