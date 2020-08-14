//
//  TFAppearanceControlState.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceColor.h"

@interface TFAppearanceControlState : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceColor *textColor;
@property (nonatomic, strong, readonly) TFAppearanceColor *backgroundColor;
@property (nonatomic, strong, readonly) TFAppearanceColor *borderColor;
@property (nonatomic, strong, readonly) TFAppearanceColor *shadowColor;

@end
