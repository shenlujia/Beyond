

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HsPickerView.h"
#import "HsPickerBuilder.h"

typedef NS_ENUM(NSInteger, HsPickerDismissType) {
    HsPickerDismissTypeCancel = 0,
    HsPickerDismissTypeConfirm,
    HsPickerDismissTypeOther
};

@class HsPickerHandler;
@protocol HsPickerHandlerDelegate <NSObject>
@optional
- (void)pickerHandler:(HsPickerHandler *)pickerHandler willDismissWithType:(HsPickerDismissType)dismissType;
- (void)pickerHandler:(HsPickerHandler *)pickerHandler didDismissWithType:(HsPickerDismissType)dismissType;
@end

@interface HsPickerHandler : NSObject

// 类型为 HsPickerTypeNormal 时有效
@property (nonatomic, strong, readonly) HsPickerView *normalPicker;

// 类型为 HsPickerTypeDate 时有效
@property (nonatomic, strong, readonly) UIDatePicker *datePicker;

// 方便设置圆角、边界线等
@property (nonatomic, strong, readonly) UIView *backgroundView;

// 代理
@property (nonatomic, weak) id<HsPickerHandlerDelegate> pickerHandlerDelegate;

// 自定义toolbar，默认创建一个包含 |取消| 和 |确定| 两个按钮的toolbar
@property (nonatomic, strong) UIToolbar *toolbar;

// headerView && footerView
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

- (instancetype)initWithMaker:(void (^)(HsPickerBuilder *maker))block;
+ (instancetype)pickerHandlerWithBuilder:(void (^)(HsPickerBuilder *builder))block;

- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismiss;
+ (void)dismissAll;

@end
