//
//  TFViewDecorator.h
//  AFNetworking
//
//  Created by admin on 2018/6/12.
//

#import <UIKit/UIKit.h>
#import "TFColorGenerator.h"
#import "TFImageGenerator.h"
#import "TFShadowDecorator.h"

@protocol TFViewDecorator <NSObject>

@optional

////////////////////////////////////////////////////////////
#pragma mark - background

@property (nonatomic, copy) UIColor *color; // Defaults to nil.
@property (nonatomic, copy) UIImage *image; // Defaults to nil.

@property (nonatomic, assign) CGFloat cornerRadius; // Defaults to 0.
@property (nonatomic, assign) UIRectCorner roundingCorners; // Defaults to UIRectCornerAllCorners.

@property (nonatomic, assign) CGFloat borderWidth; // Defaults to 0.
@property (nonatomic, copy) UIColor *borderColor; // Defaults to blackColor.

////////////////////////////////////////////////////////////
#pragma mark - shadow

@property (nonatomic, copy) UIColor *shadowColor; // Defaults to nil.
@property (nonatomic, assign) CGFloat shadowOpacity; // Defaults to 0.
@property (nonatomic, assign) CGSize shadowOffset; // Defaults to (0, -3).
@property (nonatomic, assign) CGFloat shadowRadius; // Defaults to 3.
@property (nonatomic, copy) UIBezierPath *shadowPath; // Defaults to nil.

@end

@interface UIView (TFViewDecorator)

@property (nonatomic, strong, readonly) id <TFViewDecorator> tf_decorator;

@end
