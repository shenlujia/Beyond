//
//  TFAppearanceButtonStyle.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceControlState.h"

@interface TFAppearanceButtonStyle : TFAppearanceObject <TFAppearance>

@property (nonatomic, strong, readonly) TFAppearanceControlState *normal;
@property (nonatomic, strong, readonly) TFAppearanceControlState *highlighted;
@property (nonatomic, strong, readonly) TFAppearanceControlState *disabled;

@end

@interface TFAppearanceButtonStyleGroup : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceButtonStyle *normalStyle; // 普通
@property (nonatomic, strong, readonly) TFAppearanceButtonStyle *lightStyle; // 浅色
@property (nonatomic, strong, readonly) TFAppearanceButtonStyle *hollowStyle; // 中空

@end
