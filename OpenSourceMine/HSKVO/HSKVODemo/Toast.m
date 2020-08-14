//
//  Toast.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "Toast.h"
#import <SVProgressHUD.h>

@interface Toast ()

@property (nonatomic, strong) NSMutableString *text;

@end

@implementation Toast

- (void)dealloc
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:12]];
    UIImage *image = nil;
    [SVProgressHUD setInfoImage:image];
    [SVProgressHUD showInfoWithStatus:self.text];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _text = [NSMutableString string];
    }
    return self;
}

- (void)insert:(NSString *)line
{
    if (!line) {
        return;
    }
    if (_text.length) {
        [_text appendString:@"\n"];
    }
    [_text appendString:line];
}

@end
