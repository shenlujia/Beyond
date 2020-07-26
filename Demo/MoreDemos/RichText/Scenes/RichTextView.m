//
//  RichTextView.m
//  RichText
//
//  Created by SLJ on 2020/7/24.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "RichTextView.h"

@interface RichTextView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation RichTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_label];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self.label sizeThatFits:size];
}

- (void)reloadData
{
    NSMutableAttributedString *textAttrStr = [[NSMutableAttributedString alloc] init];
    
    //第一张图
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"Image_1"];
    attach.bounds = CGRectMake(0, 0 , 30, self.label.font.pointSize);
    NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:attach];
    [textAttrStr appendAttributedString:imgStr];
    
    [self text:textAttrStr appendEmptySize:CGSizeMake(self.space, 10)];
    
    [textAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"f对的mmmmmmmSLJ"]];
    
    self.label.attributedText = textAttrStr;
}

- (void)text:(NSMutableAttributedString *)text appendEmptySize:(CGSize)size
{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *temp = [NSAttributedString attributedStringWithAttachment:attachment];
    [text appendAttributedString:temp];
}

@end
