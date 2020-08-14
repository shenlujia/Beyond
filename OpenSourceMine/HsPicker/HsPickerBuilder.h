

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HsPickerType) {
    HsPickerTypeNormal = 0,
    HsPickerTypeDate
};

typedef NS_ENUM(NSInteger, HsPickerPosition) {
    HsPickerPositionBottom = 0,
    HsPickerPositionCenter
};

@interface HsPickerBuilder : NSObject

@property (nonatomic, copy) NSString *barTitle;
@property (nonatomic, strong) UIFont *barTitleFont;
@property (nonatomic, strong) UIColor *barTitleColor;

@property (nonatomic, copy) NSArray *leftBarButtonTitles; // @[@"取消"]
@property (nonatomic, copy) NSArray *rightBarButtonTitles; // @["确定"]
@property (nonatomic, strong) UIColor *leftBarButtonColor;
@property (nonatomic, strong) UIColor *rightBarButtonColor;

@property (nonatomic, strong) UIColor *backgroundColor; // default whiteColor
@property (nonatomic, assign) HsPickerType pickerType; // default HsPickerTypeNormal
@property (nonatomic, assign) HsPickerPosition pickerPosition; // default HsPickerPositionBottom
@property (nonatomic, strong) UIColor *maskColor; // default 0.2 Black
@property (nonatomic, assign) BOOL dismissWhenMaskClicked; // default YES
@property (nonatomic, assign) CGFloat animationDuration; // default 0.25
@property (nonatomic, assign) CGFloat pickerWidth; // default 0, 为0时picker宽度即为父view宽度

@end
