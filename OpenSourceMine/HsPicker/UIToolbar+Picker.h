

#import <UIKit/UIKit.h>

@protocol HsPickerToolbarDelegate <NSObject>
@required
- (void)toolbar:(UIToolbar *)toolbar clickedItemAtIndex:(NSInteger)buttonIndex;
@end

@interface UIToolbar (Picker)

@property (nonatomic, weak) id<HsPickerToolbarDelegate> pickerToolbarDelegate;

- (instancetype)initWithLeftTitles:(NSArray *)leftTitles
                       rightTitles:(NSArray *)rightTitles
                         leftColor:(UIColor *)leftColor
                        rightColor:(UIColor *)rightColor;

- (instancetype)initWithLeftTitles:(NSArray *)leftTitles
                       rightTitles:(NSArray *)rightTitles;

@end
