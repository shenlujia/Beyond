//
//  TFAppearanceCell.h
//  EHDComponent
//
//  Created by TF020283 on 2018/9/11.
//

#import "TFAppearanceColor.h"

/// 不支持`decorate`
@interface TFAppearanceCell : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceColor *backgroundColor;
@property (nonatomic, strong, readonly) TFAppearanceColor *highlightedBackgroundColor;
@property (nonatomic, strong, readonly) TFAppearanceColor *selectedBackgroundColor;

@end

@interface TFAppearanceCellGroup : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceCell *normal; // 正常样式

@end
