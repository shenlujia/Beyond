//
//  TextViewController.m
//  Beyond
//
//  Created by ZZZ on 2022/1/6.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import "TextViewController.h"
#import <Masonry/Masonry.h>
#import "SSEasy.h"

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
        view.font = [UIFont systemFontOfSize:25];
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
    
    __block float baseLineOffset = 0;
    __block float lineHeight = 30;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    attributes[NSFontAttributeName] = self.textView.font;
    attributes[NSForegroundColorAttributeName] = self.textView.textColor;
    
    void (^action)(void) = ^{
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        // 字体默认从下往上绘制
        // 行高需要和下面的搭配食用
        CGFloat realOffset = baseLineOffset + (lineHeight - weak_s.textView.font.lineHeight) / 2;
        attributes[NSBaselineOffsetAttributeName] = @(realOffset);
        
        UITextView *textView = weak_s.textView;
        [textView.textStorage setAttributes:attributes range:NSMakeRange(0, textView.text.length)];
        [weak_s p_updateTestLayers];
    };
    
    [self test:@"alignment" tap:^(UIButton *button, NSDictionary *userInfo) {
        paragraphStyle.alignment = (paragraphStyle.alignment + 1) % 3;
        action();
    }];
    
    [self test:@"font" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"font";
            UIFont *font = attributes[NSFontAttributeName];
            NSInteger size = font.pointSize;
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.text = [@(size) stringValue];
            }];
            [configuration addConfirmHandler:^(UIAlertController *alert) {
                NSInteger size = alert.textFields.firstObject.text.integerValue;
                attributes[NSFontAttributeName] = [UIFont systemFontOfSize:MAX(size, 5)];
                action();
            }];
        });
    }];
    
    [self test:@"lineSpace尽量不要改 会有偏移" tap:^(UIButton *button, NSDictionary *userInfo) {
        // http://pingguohe.net/2018/03/29/how-to-implement-line-height.html
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"lineSpace";
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.text = [@(paragraphStyle.lineSpacing) stringValue];
            }];
            [configuration addConfirmHandler:^(UIAlertController *alert) {
                NSInteger value = alert.textFields.firstObject.text.integerValue;
                paragraphStyle.lineSpacing = value;
                action();
            }];
        });
    }];
    
    [self test:@"lineHeight" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"lineHeight";
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.text = [@(lineHeight) stringValue];
            }];
            [configuration addConfirmHandler:^(UIAlertController *alert) {
                lineHeight = alert.textFields.firstObject.text.integerValue;
                action();
            }];
        });
    }];
    
    [self test:@"baseLineOffset" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"baseLineOffset";
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.text = [@(baseLineOffset) stringValue];
            }];
            [configuration addConfirmHandler:^(UIAlertController *alert) {
                baseLineOffset = alert.textFields.firstObject.text.integerValue;
                action();
            }];
        });
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
