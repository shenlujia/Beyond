//
//  TFTestBaseCaseViewController.m
//  AFNetworking
//
//  Created by admin on 2018/6/4.
//

#import "TFTestBaseCaseViewController.h"

static const CGFloat kMargin = 15;
static const CGFloat kButtonHeight = 50;
static const NSInteger kCaseStart = 999999;

@interface TFTestBaseCaseViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableDictionary *blocks;

@end

@implementation TFTestBaseCaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarTranslucent = NO;
    
    self.blocks = [NSMutableDictionary dictionary];
    
    self.scrollView = ({
        const CGSize size = self.view.bounds.size;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        view;
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    const CGSize size = self.view.bounds.size;
    
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in self.scrollView.subviews) {
        if (view.tag > kCaseStart) {
            [views addObject:view];
        }
    }
    [views enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = CGRectMake(kMargin, 0, size.width - 2 * kMargin, kButtonHeight);
        frame.origin.y = kMargin + idx * (kButtonHeight + kMargin);
        obj.frame = frame;
    }];
    
    CGSize contentSize = CGSizeMake(size.width, kMargin + (kButtonHeight + kMargin) * views.count);
    if (contentSize.height < size.height) {
        contentSize.height = size.height;
    }
    self.scrollView.contentSize = contentSize;
}

- (UIButton *)addCaseWithTitle:(NSString *)title block:(void (^)(UIButton *button))block
{
    UIButton *button = [self createButtonWithTitle:title];
    self.blocks[@(button.tag)] = block;
    [self.scrollView addSubview:button];
    return button;
}

- (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    [view setTitle:title forState:UIControlStateNormal];
    [view setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    [view setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [view setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [view setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [view addTarget:self
             action:@selector(tapAction:)
   forControlEvents:UIControlEventTouchUpInside];
    
    static NSInteger index = 0;
    view.tag = (++index) + kCaseStart;
    
    return view;
}

- (void)tapAction:(UIButton *)button
{
    void (^block)(UIButton *button) = self.blocks[@(button.tag)];
    if (block) {
        block(button);
    }
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
