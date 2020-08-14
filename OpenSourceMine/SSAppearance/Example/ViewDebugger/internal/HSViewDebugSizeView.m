//
//  HSViewDebugSizeView.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import "HSViewDebugSizeView.h"
#import "HSViewDebugUtility.h"

@implementation HSViewDebugSizeView

- (instancetype)initWithHostView:(UIView *)view
{
    self = [super init];
    
    if (![HSViewDebugUtility isViewValid:view]) {
        return nil;
    }
    
    const CGSize size = view.bounds.size;
    if (size.width < kViewDebugSizeMinValue || size.height < kViewDebugSizeMinValue) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = UIColor.whiteColor;
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
    self.font = [UIFont systemFontOfSize:8];
    
    self.text = [HSViewDebugUtility stringWithSize:size];
    [self sizeToFit];
    
    return self;
}

@end
