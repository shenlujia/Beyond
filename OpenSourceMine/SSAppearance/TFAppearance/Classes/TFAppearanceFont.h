//
//  TFAppearanceFont.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceObject.h"
#import "TFAppearanceProtocol.h"

@interface TFAppearanceFont : TFAppearanceObject <TFAppearance>

@property (nonatomic, strong, readonly) TFAppearanceFont * (^name)(NSString *name);
@property (nonatomic, strong, readonly) TFAppearanceFont * (^size)(CGFloat size);
@property (nonatomic, strong, readonly) TFAppearanceFont * (^bold)(BOOL bold);
@property (nonatomic, strong, readonly) TFAppearanceFont * (^adaptive)(BOOL adaptive);

- (UIFont *)font;

@end

@interface TFAppearanceFontGroup : TFAppearanceObject

// 以下所有字体都是系统字体、未加粗、字体大小自适应屏幕，这里的size默认适配iPhone6
// name = nil
// bold = NO
// adaptive = YES
// 换字体方法 -> font.font16.name(@"FontName")
// 加粗方法 -> font.font16.bold(YES)
// 自适应方法 -> font.font16.adaptive(YES)
@property (nonatomic, strong, readonly) TFAppearanceFont *size8;
@property (nonatomic, strong, readonly) TFAppearanceFont *size10;
@property (nonatomic, strong, readonly) TFAppearanceFont *size12;
@property (nonatomic, strong, readonly) TFAppearanceFont *size14;
@property (nonatomic, strong, readonly) TFAppearanceFont *size16;
@property (nonatomic, strong, readonly) TFAppearanceFont *size17;
@property (nonatomic, strong, readonly) TFAppearanceFont *size18;
@property (nonatomic, strong, readonly) TFAppearanceFont *size20;
@property (nonatomic, strong, readonly) TFAppearanceFont *size22;
@property (nonatomic, strong, readonly) TFAppearanceFont *size24;

@property (nonatomic, strong, readonly) TFAppearanceFont * (^size)(CGFloat size);

@end
