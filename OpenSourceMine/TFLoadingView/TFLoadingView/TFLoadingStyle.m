//
//  TFLoadingStyle.m
//  Pods
//
//  Created by shenlujia on 16/10/14.
//
//

#import "TFLoadingStyle.h"

@implementation TFLoadingStyle

- (instancetype)init
{
    self = [super init];
    [self p_reset];
    return self;
}

- (void)p_reset
{
    _verticalAlignment = UIControlContentVerticalAlignmentCenter;
    _contentEdgeInsets = UIEdgeInsetsZero;
    _itemHorizontalMargin = 25;
    _itemVerticalMargin = 15;
    
    _image = nil;
    
    _text = nil;
    _attributedText = nil;
    _textAlignment = NSTextAlignmentLeft;
    _lineSpacing = 5;
    
    _buttonSize = CGSizeZero;
    _buttonStyle = nil;
    _buttonCornerRadius = 3;
    _buttonNormalTitle = nil;
    _buttonHighlightedTitle = nil;
}

@end
