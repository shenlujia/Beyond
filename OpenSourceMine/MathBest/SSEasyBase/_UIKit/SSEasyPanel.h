//
//  Created by ZZZ on 2021/11/16.
//

#import <UIKit/UIKit.h>

#define SSDEBUGPanel SSEasyPanel
#define SSDEBUGPanelItem SSEasyPanelItem

@class SSDEBUGPanel;

@interface SSDEBUGPanelItem : NSObject

@property (nonatomic, weak, readonly) SSDEBUGPanel *panel;
@property (nonatomic, strong, readonly) UIButton *button;

@property (nonatomic, assign) BOOL fixed;

@end

@interface SSDEBUGPanel : NSObject

+ (CGSize)itemSize;

- (void)showInView:(UIView *)view;

- (void)showInView:(UIView *)view center:(CGPoint)center;

- (void)dismiss;

- (void)test:(void (^)(SSDEBUGPanelItem *item))setup action:(void (^)(SSDEBUGPanelItem *item))action;

@end
