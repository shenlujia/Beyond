//
//  TFAppearanceManager.h
//  TFAppearance
//
//  Created by shenlujia on 2018/6/8.
//

#import <Foundation/Foundation.h>

@class TFAppearance;
@protocol TFAppearance;

@interface TFAppearanceManager : NSObject

@property (class, strong, readonly) TFAppearanceManager *manager;

////////////////////////////////////////////////////////////
#pragma mark - appearance

@property (nonatomic, strong, readonly) TFAppearance *appearance;

- (void)decorate:(__kindof UIView *)view appearance:(id <TFAppearance>)appearance;
- (void)installAppearance:(TFAppearance *)appearance;

////////////////////////////////////////////////////////////
#pragma mark - scale

@property (nonatomic, assign, readonly) CGFloat designScale;
@property (nonatomic, assign, readonly) CGFloat fontScale;

- (CGFloat)roundValue:(CGFloat)value;
- (CGFloat)scaleDesignValue:(CGFloat)value;
- (CGFloat)scaleFontValue:(CGFloat)value;

@end
