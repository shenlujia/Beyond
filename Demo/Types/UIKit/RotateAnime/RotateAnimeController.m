//
//  RotateAnimeController.m
//  Demo
//
//  Created by SLJ on 2020/7/30.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "RotateAnimeController.h"
#import <Masonry/Masonry.h>

@interface ACCLightningRecordLongtailView : UIView

@property (nonatomic, assign) CGFloat progress;

@end

static const CGFloat kDiameterLT = 130;
// UI 给的图不标准
static const CGFloat kRadiusHeadMax = 5.2;
static const CGFloat kRadiusHeadMin = 1.1;

@interface ACCLightningRecordLongtailView ()

@property (nonatomic, strong) UIView *longtailView;
@property (nonatomic, strong) CALayer *longtailLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation ACCLightningRecordLongtailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, kDiameterLT, kDiameterLT)];
    if (self) {
        __unused UIView *leftLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(1);
                make.left.top.bottom.equalTo(view.superview);
            }];
            view;
        });
        __unused UIView *rightLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(1);
                make.right.top.bottom.equalTo(view.superview);
            }];
            view;
        });
        __unused UIView *topLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(1);
                make.left.right.top.equalTo(view.superview);
            }];
            view;
        });
        __unused UIView *bottomLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(1);
                make.left.right.bottom.equalTo(view.superview);
            }];
            view;
        });
        __unused UIView *xLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(1);
                make.left.right.centerY.equalTo(view.superview);
            }];
            view;
        });
        __unused UIView *yLine = ({
            UIView *view = [self p_createLine];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(1);
                make.top.bottom.centerX.equalTo(view.superview);
            }];
            view;
        });
        
        self.longtailView = [[UIView alloc] initWithFrame:self.frame];
        [self addSubview:self.longtailView];
        
        _longtailLayer = [CALayer layer];
        _longtailLayer.frame = self.bounds;
        _longtailLayer.contents = (__bridge id)([UIImage imageNamed:@"icon_longtail_progress"].CGImage);
//        _longtailLayer.backgroundColor = UIColor.blueColor.CGColor;
        [self.longtailView.layer addSublayer:_longtailLayer];
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = self.frame;
        _maskLayer.backgroundColor = [UIColor.clearColor colorWithAlphaComponent:0].CGColor;
        _maskLayer.fillColor = [UIColor.clearColor colorWithAlphaComponent:1].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(kDiameterLT / 2, kDiameterLT / 2) radius:kDiameterLT / 2 startAngle:M_PI + M_PI_2 endAngle:M_PI_2 clockwise:YES];
        [path addArcWithCenter:CGPointMake(kDiameterLT / 2, kRadiusHeadMax) radius:kRadiusHeadMax startAngle:M_PI_2 endAngle:M_PI + M_PI_2 clockwise:YES];
        [path closePath];
        _maskLayer.path = path.CGPath;
        self.longtailView.layer.mask = _maskLayer;
    }
    return self;
}

- (UIView *)p_createLine
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
    return view;
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    self.progress = progress;
    
    self.longtailLayer.transform = CATransform3DMakeRotation(2 * M_PI * progress, 0, 0, 1);
    
    const CGFloat kMiddle = 0.375;
    if (progress >= 0.5) {
        self.longtailView.layer.mask = nil;
    } else {
        self.longtailView.layer.mask = nil;
        CGFloat radius = MAX((kMiddle - progress), 0) / kMiddle * (kRadiusHeadMax - kRadiusHeadMin) + kRadiusHeadMin;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(kDiameterLT / 2, kDiameterLT / 2) radius:kDiameterLT / 2 startAngle:M_PI + M_PI_2 endAngle:M_PI_2 clockwise:YES];
        [path addArcWithCenter:CGPointMake(kDiameterLT / 2, radius) radius:radius startAngle:M_PI_2 endAngle:M_PI + M_PI_2 clockwise:YES];
        [path closePath];
        self.maskLayer.path = path.CGPath;
        self.longtailView.layer.mask = self.maskLayer;
    }
}

@end

@interface RotateAnimeController () <UITextFieldDelegate>

@property (nonatomic, strong) ACCLightningRecordLongtailView *animationView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RotateAnimeController

- (void)viewDidLoad
{
    WEAKSELF
    [super viewDidLoad];

    [self activateInputView];
    self.textInputView.delegate = self;
    self.textInputView.keyboardType = UIKeyboardTypeDecimalPad;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.animationView setProgress:0 animated:NO];
    });

    self.animationView = ({
        CGRect frame = CGRectMake(0, 0, kDiameterLT, kDiameterLT);
        ACCLightningRecordLongtailView *view = [[ACCLightningRecordLongtailView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(frame.size);
            make.centerX.equalTo(view.superview);
            make.top.equalTo(self.textInputView.mas_bottom).offset(15);
        }];
        
        view;
    });
    
    [self add_navi_right_item:@"timer" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.animationView setProgress:0 animated:NO];
        [weak_s.timer invalidate];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (self.animationView.progress >= 1) {
                [weak_s.timer invalidate];
            }
            static NSInteger flag = 0;
            ++flag;
            CGFloat progress = weak_s.animationView.progress + (flag % 2 ? 0.02 : 0.04);
            progress = MIN(progress, 1);
            [weak_s.animationView setProgress:progress animated:YES];
        }];
        weak_s.timer = timer;
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGFloat value = textField.text.floatValue;
    value = MAX(value, 0);
    value = MIN(value, 100);
    [self.animationView setProgress:value / 100 animated:YES];
}

@end
