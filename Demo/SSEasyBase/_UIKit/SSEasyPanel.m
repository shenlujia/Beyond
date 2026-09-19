//
//  SSEasyPanel.m — stub
//

#import "SSEasyPanel.h"

@implementation SSDEBUGPanelItem {
    UIButton *_button;
}
- (instancetype)init {
    if ((self = [super init])) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    return self;
}
@end

@implementation SSEasyPanel

- (void)showInView:(UIView *)view { }
- (void)showInView:(UIView *)view center:(CGPoint)center { }
- (void)dismiss { }
- (void)test:(SSEasyPanelConfigBlock)config action:(SSEasyPanelActionBlock)action
{
    SSDEBUGPanelItem *item = [[SSDEBUGPanelItem alloc] init];
    if (config) config(item);
}

@end
