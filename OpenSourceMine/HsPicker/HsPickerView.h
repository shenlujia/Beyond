

#import <UIKit/UIKit.h>
#import "HsPickerItem.h"

@class HsPickerView;
@protocol HsPickerViewDelegate <NSObject>
@optional
- (void)pickerView:(HsPickerView *)pickerView didSelectItem:(HsPickerItem *)item inComponent:(NSInteger)component;
- (UIView *)pickerView:(HsPickerView *)pickerView viewForItem:(HsPickerItem *)item;
- (CGFloat)pickerView:(HsPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
@end

@interface HsPickerView : UIView

@property (nonatomic, weak) id<HsPickerViewDelegate> pickerViewDelegate;

@property (nonatomic, strong) UIColor *pickerTextColor; // default blackColor

@property (nonatomic, strong) UIFont *pickerTextFont; // default [UIFont systemFontOfSize:16]

@property (nonatomic, assign, readonly) CGFloat pickerViewHeight;

@property (nonatomic, assign) BOOL adjustTitleSizeToFitWidth; // default NO

/**
 *  元素类型为 HsPickerItem
 *  data只包含数组时，picker各列不关联：@[@[item, item], @[item, item], @[item, item]]，此时忽略subItems
 *  data只包含HsPickerItem时，picker各列相关联：@[item, item, item]，此时subItems决定了到底有几层
 *  也支持混合类型：@[@[item, item], item]
 */
- (void)reloadWithData:(NSArray *)data;

- (void)selectItem:(HsPickerItem *)item inComponent:(NSInteger)component animated:(BOOL)animated;

- (NSInteger)numberOfComponents;
- (HsPickerItem *)selectedItemInComponent:(NSInteger)component;

@end
