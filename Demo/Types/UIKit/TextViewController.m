//
//  TextViewController.m
//  Beyond
//
//  Created by ZZZ on 2022/1/6.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import "TextViewController.h"
#import <Masonry/Masonry.h>

@interface TextViewController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *testLayers;

@end

@implementation TextViewController

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad
{
    WEAKSELF
    [super viewDidLoad];
    
    [self add_navi_right_item:@"键盘切换" tap:^(UIButton *button, NSDictionary *userInfo) {
        if (weak_s.textView.isFirstResponder) {
            [weak_s.textView resignFirstResponder];
        } else {
            [weak_s.textView becomeFirstResponder];
        }
    }];
    
    [self set_insets:UIEdgeInsetsMake(0, 0, 300, 0)];
    
    self.textView = ({
        UITextView *view = [[UITextView alloc] init];
        [self.view addSubview:view];
        view.backgroundColor = UIColor.lightGrayColor;
        view.font = [UIFont systemFontOfSize:13];
        view.textColor = UIColor.redColor;
        view.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        view.textContainerInset = UIEdgeInsetsZero; // 重要!!!
        view.textContainer.lineFragmentPadding = 0; // 重要!!!
        
        view.autocapitalizationType = UITextAutocapitalizationTypeNone;
        view.autocorrectionType = UITextAutocorrectionTypeNo;
        view.spellCheckingType = UITextSpellCheckingTypeNo;
        view.keyboardType = UIKeyboardTypeDefault;
        view.keyboardAppearance = UIKeyboardAppearanceDefault;
        view.returnKeyType = UIReturnKeyDefault;
        view.enablesReturnKeyAutomatically = YES;
        
        view.text = @"1234567890\n123\n12345678901234567890\n1234567890\n1\n\n\n\n123";
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.inset(15);
            make.height.mas_equalTo(300);
            make.bottom.inset(app_safeAreaInsets().bottom);
        }];
        view;
    });
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    attributes[NSFontAttributeName] = self.textView.font;
    attributes[NSForegroundColorAttributeName] = self.textView.textColor;
    
    void (^action)(void) = ^{
        UITextView *textView = weak_s.textView;
        [textView.textStorage setAttributes:attributes range:NSMakeRange(0, textView.text.length)];
        [weak_s p_updateTestLayers];
    };
    
    [self test:@"alignment" tap:^(UIButton *button, NSDictionary *userInfo) {
        paragraphStyle.alignment = (paragraphStyle.alignment + 1) % 3;
        action();
    }];
    
    [self test:@"font" tap:^(UIButton *button, NSDictionary *userInfo) {
        static NSInteger value = 10;
        value += 2;
        value = (value % 20);
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:value + 10];
        action();
    }];
    
    [self test:@"正确设置 lineSpace" tap:^(UIButton *button, NSDictionary *userInfo) {
        // http://pingguohe.net/2018/03/29/how-to-implement-line-height.html
        static NSInteger value = 10;
        value += 2;
        value = (value % 30);
        UIFont *font = weak_s.textView.font;
        paragraphStyle.lineSpacing = value - (font.lineHeight - font.pointSize);
        action();
    }];
    
    [self test:@"重置 lineSpace" tap:^(UIButton *button, NSDictionary *userInfo) {
        paragraphStyle.lineSpacing = 0;
        action();
    }];
    
    [self test:@"错误设置 lineHeight" tap:^(UIButton *button, NSDictionary *userInfo) {
        static NSInteger value = 10;
        value += 2;
        value = (value % 30);
        
        const CGFloat lineHeight = weak_s.textView.font.lineHeight + value;
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        
        attributes[NSBaselineOffsetAttributeName] = @(0);
        
        action();
    }];
    
    [self test:@"正确设置 lineHeight" tap:^(UIButton *button, NSDictionary *userInfo) {
        static NSInteger value = 10;
        value += 2;
        value = (value % 30);
        
        const CGFloat lineHeight = weak_s.textView.font.lineHeight + value;
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        
        // 字体默认从下往上绘制
        // 行高需要和下面的搭配食用
        CGFloat baselineOffset = (lineHeight - weak_s.textView.font.lineHeight) / 2;
        attributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
        
        action();
    }];
    
    [self test:@"重置 lineHeight" tap:^(UIButton *button, NSDictionary *userInfo) {
        paragraphStyle.minimumLineHeight = weak_s.textView.font.lineHeight;
        paragraphStyle.maximumLineHeight = weak_s.textView.font.lineHeight;
        attributes[NSBaselineOffsetAttributeName] = @(0);
        action();
    }];
    
    [self observe:UITextViewTextDidChangeNotification block:^(NSNotification *notification) {
        if (notification.object == weak_s.textView) {
            [weak_s p_updateTestLayers];
        }
    }];
    
    [self observe:UIKeyboardWillChangeFrameNotification block:^(NSNotification *notification) {
        NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        UIView *fromView = UIApplication.sharedApplication.delegate.window;
        CGRect rect = [weak_s.view convertRect:frameValue.CGRectValue fromView:fromView];
        [weak_s.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat endY = CGRectGetMinY(rect);
            CGFloat inset = weak_s.view.frame.size.height - endY;
            if (inset <= 0) {
                inset = app_safeAreaInsets().bottom;
            }
            make.bottom.inset(inset);
        }];
        
        [UIView animateWithDuration:duration.doubleValue animations:^{
            [weak_s.view layoutIfNeeded];
        }];
    }];
    
    [weak_s p_updateTestLayers];
}

- (void)p_updateTestLayers
{
    NSMutableArray<NSValue *> *rangeArray = [NSMutableArray array];
    NSMutableArray<NSValue *> *rectArray = [NSMutableArray array];
    
    NSRange range = NSMakeRange(0, 0);
    NSLayoutManager *layout = self.textView.layoutManager;
    CGRect lineRect = [layout lineFragmentUsedRectForGlyphAtIndex:0 effectiveRange:&range];
    
    if (range.length != 0) {
        [rangeArray addObject:[NSValue valueWithRange:range]];
        [rectArray addObject:[NSValue valueWithCGRect:lineRect]];
    }
    while (range.location + range.length < self.textView.text.length) {
        lineRect = [layout lineFragmentUsedRectForGlyphAtIndex:(range.location + range.length) effectiveRange:&range];
        if (range.length != 0) {
            [rangeArray addObject:[NSValue valueWithRange:range]];
            [rectArray addObject:[NSValue valueWithCGRect:lineRect]];
        }
    }

    NSMutableArray<NSMutableArray *> *segmentArray = [NSMutableArray array];
    NSMutableArray *currentArray = [NSMutableArray array];
    [segmentArray addObject:currentArray];
    NSInteger idx = 0;
    while (idx < rectArray.count) {
        if (rectArray[idx].CGRectValue.size.width <= 0.001) {
            if (currentArray.count > 0) {
                currentArray = [NSMutableArray array];
                [segmentArray addObject:currentArray];
            }
        } else {
            [currentArray addObject:rectArray[idx]];
        }
        ++idx;
    }
    
    for (CALayer *layer in self.testLayers) {
        [layer removeFromSuperlayer];
    }
    NSMutableArray *layers = [NSMutableArray array];
    for (NSArray *array in segmentArray) {
        CALayer *layer = [self p_testLayerWithRects:array];
        [self.textView.layer insertSublayer:layer atIndex:0];
        [layers addObject:layer];
    }
    self.testLayers = layers;
}

- (CALayer *)p_testLayerWithRects:(NSArray *)rects
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSInteger idx = 0; idx < rects.count; ++idx) {
        CGRect rect = [rects[idx] CGRectValue];
        
        const CGFloat minX = CGRectGetMinX(rect);
        const CGFloat maxX = CGRectGetMaxX(rect);
        static CGFloat offsetY = 1;
        const CGFloat minY = CGRectGetMinY(rect) + offsetY;
        const CGFloat maxY = CGRectGetMaxY(rect) - offsetY;
       
        [path moveToPoint:CGPointMake(minX, minY)];
        [path addLineToPoint:CGPointMake(maxX, minY)];
        [path addLineToPoint:CGPointMake(maxX, maxY)];
        [path addLineToPoint:CGPointMake(minX, maxY)];
        [path addLineToPoint:CGPointMake(minX, minY)];
    }
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColor.brownColor.CGColor;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    layer.path = path.CGPath;
    CGRect frame = self.textView.bounds;
    layer.frame = frame;
    [CATransaction commit];
    
    return layer;
}

@end
