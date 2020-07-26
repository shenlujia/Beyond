//
//  TestRichTextViewController.m
//  RichText
//
//  Created by SLJ on 2020/7/24.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TestRichTextViewController.h"
#import "RichTextView.h"
#import <YYText/YYText.h>
#import <YYText/NSAttributedString+YYText.h>

@interface TestRichTextViewController ()

@end

@implementation TestRichTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof (self) weak_s = self;
    
    [self test:@"两行" tap:^(UIButton *button) {
        RichTextView *view = [weak_s createTextView];
        [view reloadData];
        [view sizeToFit];
        [weak_s.view addSubview:view];
    }];
    
    [self test:@"d" tap:^(UIButton *button) {
        YYLabel *contentL = [[YYLabel alloc] init];
        contentL.frame =  CGRectMake(80, 80, 200, 300);
        contentL.font = [UIFont systemFontOfSize:24];
        contentL.backgroundColor= UIColor.lightGrayColor;
        contentL.textVerticalAlignment = YYTextVerticalAlignmentTop;
        [self.view addSubview:contentL];
        
        //设置多行
        contentL.numberOfLines = 0;

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 60;
        style.maximumLineHeight = 60;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSParagraphStyleAttributeName] = style;
        attributes[NSFontAttributeName] = contentL.font;
        
         NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:@"当初么我们家佛Id的上档次D忘记哦的邪恶我们的111心" attributes:attributes];
        

        UIImageView *imageView1= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_1"]];
        imageView1.frame = CGRectMake(0, 0, 16, 16);

        UIImageView *imageView2= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_1"]];
        imageView2.frame = CGRectMake(0, 0, 16, 16);
        // attchmentSize 修改，可以处理内边距
        NSMutableAttributedString *attachText1= [NSMutableAttributedString yy_attachmentStringWithContent:imageView1 contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(imageView2.frame.size.width, style.maximumLineHeight) alignToFont:contentL.font alignment:YYTextVerticalAlignmentCenter];

        NSMutableAttributedString *attachText2= [NSMutableAttributedString yy_attachmentStringWithContent:imageView2 contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(imageView2.frame.size.width, style.maximumLineHeight) alignToFont:contentL.font alignment:YYTextVerticalAlignmentCenter];

         //插入到开头
        [attri insertAttributedString:attachText1 atIndex:0];

        {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            v.backgroundColor = UIColor.redColor;
            NSMutableAttributedString *a= [NSMutableAttributedString yy_attachmentStringWithContent:v contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(imageView2.frame.size.width, style.maximumLineHeight) alignToFont:[UIFont systemFontOfSize:24] alignment:YYTextVerticalAlignmentCenter];
            [attri appendAttributedString:a];
        }
        
         //插入到结尾
        [attri appendAttributedString:attachText2];

        contentL.attributedText = attri;
        [contentL sizeToFit];

    }];
}

- (RichTextView *)createTextView
{
    RichTextView *view = [[RichTextView alloc] initWithFrame:CGRectMake(20, 80, 200, 80)];
    view.backgroundColor = UIColor.lightGrayColor;
    view.space = 5;
    return view;
}

@end
