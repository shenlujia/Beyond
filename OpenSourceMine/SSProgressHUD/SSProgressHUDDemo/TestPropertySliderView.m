//
//  TestPropertySliderView.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestPropertySliderView.h"

@interface TestPropertySliderView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation TestPropertySliderView

@dynamic minimumValue;
@dynamic maximumValue;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.textLabel = ({
        UILabel *view = [[UILabel alloc] init];
        view.textColor = [UIColor blackColor];
        view.font = [UIFont systemFontOfSize:14];
        view.textAlignment = NSTextAlignmentLeft;
        view.adjustsFontSizeToFitWidth = YES;
        view.numberOfLines = 0;
        [self addSubview:view];
        view;
    });
    
    self.slider = ({
        UISlider *view = [[UISlider alloc] init];
        [view addTarget:self
                 action:@selector(sliderDidChange)
       forControlEvents:UIControlEventValueChanged];
        [self addSubview:view];
        view;
    });
    
    self.valueLabel = ({
        UILabel *view = [[UILabel alloc] init];
        view.textColor = [UIColor blackColor];
        view.font = [UIFont systemFontOfSize:14];
        view.textAlignment = NSTextAlignmentLeft;
        view.adjustsFontSizeToFitWidth = YES;
        view.numberOfLines = 0;
        [self addSubview:view];
        view;
    });
    
    self.lineView = ({
        UIView *view = [[UIView alloc] init];
        CGFloat r = (16 * 13 + 13) / 256.0;
        view.backgroundColor = [UIColor colorWithRed:r green:r blue:r alpha:1];
        [self addSubview:view];
        view;
    });
    
    return self;
}

- (void)layoutSubviews
{
    const CGSize size = self.bounds.size;
    const CGFloat margin = 10;
    const CGFloat titleWidth = 120;
    const CGFloat valueWidth = 64;
    
    CGRect frame = CGRectMake(margin, 0, titleWidth, size.height);
    self.textLabel.frame = frame;
    
    frame.origin.x += frame.size.width + margin;
    frame.size.width = size.width - frame.origin.x;
    frame.size.width -= valueWidth + margin * 2;
    self.slider.frame = frame;
    
    frame.origin.x += frame.size.width + margin;
    frame.size.width = valueWidth;
    self.valueLabel.frame = frame;
    
    frame = CGRectMake(0, 0, size.width, 1 / [[UIScreen mainScreen] scale]);
    frame.origin.y = size.height - frame.size.height;
    self.lineView.frame = frame;
    
    [super layoutSubviews];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.slider;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    self.textLabel.text = text;
}

- (void)setValue:(CGFloat)value
{
    self.slider.value = value;
    [self sliderDidChange];
}

- (CGFloat)value
{
    return self.slider.value;
}

- (void)sliderDidChange
{
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.slider.value];
    if (self.valueBlock) {
        self.valueBlock(self.slider.value);
    }
}

@end
