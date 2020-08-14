

#import "HsPickerBuilder.h"

@implementation HsPickerBuilder

- (instancetype)init
{
    self = [super init];
    
    self.barTitleColor = [UIColor blackColor];
    self.barTitleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    self.leftBarButtonTitles = @[@"取消"];
    self.rightBarButtonTitles = @[@"确定"];
    
    self.backgroundColor = [UIColor whiteColor];
    self.pickerType = HsPickerTypeNormal;
    self.pickerPosition = HsPickerPositionBottom;
    self.maskColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.animationDuration = 0.25;
    self.dismissWhenMaskClicked = YES;
    self.pickerWidth = 0;
    
    return self;
}

@end
