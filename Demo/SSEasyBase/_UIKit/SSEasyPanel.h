//
//  SSEasyPanel.h — stub
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSDEBUGPanelItem : NSObject
@property (nonatomic, strong) UIButton *button;
@end

typedef void (^SSEasyPanelConfigBlock)(SSDEBUGPanelItem *item);
typedef void (^SSEasyPanelActionBlock)(SSDEBUGPanelItem *item);

@interface SSEasyPanel : NSObject
- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view center:(CGPoint)center;
- (void)dismiss;
- (void)test:(SSEasyPanelConfigBlock)config action:(SSEasyPanelActionBlock)action;
@end

NS_ASSUME_NONNULL_END
