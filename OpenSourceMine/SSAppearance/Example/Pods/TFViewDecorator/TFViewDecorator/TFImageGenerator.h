//
//  TFImageGenerator.h
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import <UIKit/UIKit.h>

@interface TFImageGenerator : NSObject

@property (nonatomic, assign) CGSize size;

@property (nonatomic, copy) UIColor *color; // Defaults to nil.
@property (nonatomic, copy) UIImage *image; // Defaults to nil.

@property (nonatomic, assign) CGFloat cornerRadius; // Defaults to 0.
@property (nonatomic, assign) UIRectCorner roundingCorners; // Defaults to UIRectCornerAllCorners.

@property (nonatomic, assign) CGFloat borderWidth; // Defaults to 0.
@property (nonatomic, copy) UIColor *borderColor; // Defaults to blackColor.

- (UIImage *)generate;

@end
