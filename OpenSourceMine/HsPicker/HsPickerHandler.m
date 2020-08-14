

#import "HsPickerHandler.h"
#import "UIToolbar+Picker.h"

static const CGFloat kToolBarHeight = 44;

static NSMutableSet *localPickerHandlers = nil;

static UIEdgeInsets _p_window_safeAreaInsets(void)
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
    if (@available(iOS 11, *)) {
        insets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
    }
#endif
    return insets;
}

@implementation UIView (HsPickerHandler)

- (void)reloadWithToolbar:(UIToolbar *)toolbar
           pickerPosition:(HsPickerPosition)pickerPosition
               pickerView:(UIView *)pickerView
               headerView:(UIView *)headerView
               footerView:(UIView *)footerView
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat toolbarHeight = toolbar.bounds.size.height;
    CGFloat pickerHeight = pickerView.bounds.size.height;
    if ([pickerView isKindOfClass:HsPickerView.class]) {
        HsPickerView *picker = (HsPickerView *)pickerView;
        pickerHeight = picker.pickerViewHeight;
    }
    CGFloat headerHeight = headerView.bounds.size.height;
    CGFloat footerHeight = footerView.bounds.size.height;
    
    CGRect frame = self.frame;
    frame.size.height = toolbarHeight + pickerHeight + headerHeight + footerHeight;
    if (pickerPosition == HsPickerPositionBottom) {
        frame.size.height += _p_window_safeAreaInsets().bottom;
    }
    self.frame = frame;
    
    frame.origin = CGPointZero;
    if (pickerPosition == HsPickerPositionBottom) {
        [self addView:toolbar height:toolbarHeight frame:&frame];
        [self addView:headerView height:headerHeight frame:&frame];
        [self addView:pickerView height:pickerHeight frame:&frame];
        [self addView:footerView height:footerHeight frame:&frame];
    } else {
        [self addView:headerView height:headerHeight frame:&frame];
        [self addView:pickerView height:pickerHeight frame:&frame];
        [self addView:footerView height:footerHeight frame:&frame];
        [self addView:toolbar height:toolbarHeight frame:&frame];
    }
}

- (void)addView:(UIView *)view height:(CGFloat)height frame:(CGRect *)pFrame
{
    if (!view || !pFrame) {
        return;
    }
    
    [view removeFromSuperview];
    [self addSubview:view];
    
    pFrame->size.height = height;
    view.frame = *pFrame;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    pFrame->origin.y += height;
}

@end

@interface HsPickerHandler() <HsPickerToolbarDelegate>

@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) HsPickerBuilder *builder;
@property (nonatomic, assign) HsPickerDismissType dismissType;
@end

@implementation HsPickerHandler

#pragma mark - lifecycle

+ (instancetype)pickerHandlerWithBuilder:(void (^)(HsPickerBuilder *builder))block
{
    id instance = [[self alloc] init];
    return [instance initWithMaker:block];
}

- (instancetype)initWithMaker:(void (^)(HsPickerBuilder *maker))block
{
    HsPickerBuilder *pickerBuilder = [[HsPickerBuilder alloc] init];
    if (block) {
        block(pickerBuilder);
    }
    self.builder = pickerBuilder;
    
    if (pickerBuilder.pickerType == HsPickerTypeDate) {
        _datePicker = [[UIDatePicker alloc] init];
    } else if (pickerBuilder.pickerType == HsPickerTypeNormal) {
        _normalPicker = [[HsPickerView alloc] init];
    }
    
    self.maskView = [[UIButton alloc] init];
    self.maskView.backgroundColor = pickerBuilder.maskColor;
    [self.maskView addTarget:self action:@selector(maskAction) forControlEvents:UIControlEventTouchUpInside];
    
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = self.builder.backgroundColor;
    
#if defined(DEFINE_CLOUD_HOSPITAL)
     self.toolbar = [[UIToolbar alloc] initWithLeftTitles:nil
                                              rightTitles:pickerBuilder.rightBarButtonTitles];
#else
     self.toolbar = [[UIToolbar alloc] initWithLeftTitles:pickerBuilder.leftBarButtonTitles
                                              rightTitles:pickerBuilder.rightBarButtonTitles
                                                leftColor:pickerBuilder.leftBarButtonColor
                                               rightColor:pickerBuilder.rightBarButtonColor];
#endif
    // title
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.toolbar.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.text = pickerBuilder.barTitle;
        label.font = pickerBuilder.barTitleFont;
        label.textColor = pickerBuilder.barTitleColor;
        label.textAlignment = NSTextAlignmentCenter;
        [self.toolbar addSubview:label];
    }
    
    self.toolbar.frame = CGRectMake(0, 0, 0, kToolBarHeight);
    self.toolbar.barTintColor = pickerBuilder.backgroundColor;
    self.toolbar.translucent = NO;
    self.toolbar.pickerToolbarDelegate = self;
    
    self.dismissType = HsPickerDismissTypeOther;
    
    return self;
}

#pragma mark - public

- (void)show
{
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    [self showInView:window.rootViewController.view];
}

- (void)showInView:(UIView *)view
{
    if (!view) {
        return;
    }
    
    if (!localPickerHandlers) {
        localPickerHandlers = [NSMutableSet set];
    }
    [localPickerHandlers addObject:self];
    
    [self.backgroundView removeFromSuperview];
    [self.maskView removeFromSuperview];
    
    [view addSubview:self.maskView];
    [view addSubview:self.backgroundView];
    
    UIView *pickerView = self.datePicker ? : self.normalPicker;
    [self.backgroundView reloadWithToolbar:self.toolbar
                            pickerPosition:self.builder.pickerPosition
                                pickerView:pickerView
                                headerView:self.headerView
                                footerView:self.footerView];
    
    [self startAnimation:YES];
}

- (void)dismiss
{
    [self startAnimation:NO];
}

+ (void)dismissAll
{
    for (HsPickerHandler *picker in localPickerHandlers) {
        picker.dismissType = HsPickerDismissTypeCancel;
        [picker dismiss];
    }
}

#pragma mark - HsPickerToolbarDelegate

- (void)toolbar:(UIToolbar *)toolbar clickedItemAtIndex:(NSInteger)buttonIndex
{
#if defined(DEFINE_CLOUD_HOSPITAL)
    self.dismissType = HsPickerDismissTypeConfirm;
#else
    if (buttonIndex == 0) {
        self.dismissType = HsPickerDismissTypeCancel;
    } else if (buttonIndex == 1) {
        self.dismissType = HsPickerDismissTypeConfirm;
    }
#endif
    [self dismiss];
}

#pragma mark - private

- (void)startAnimation:(BOOL)show
{
    __weak typeof (self) weakP = self;
    CGSize viewSize = self.maskView.superview.bounds.size;
    CGFloat containerHeight = self.backgroundView.bounds.size.height;
    CGRect containerFrameBefore, containerFrameAfter;
    CGFloat containerAlphaBefore, containerAlphaAfter, maskAlphaBefore, maskAlphaAfter;
    
    self.maskView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    containerAlphaBefore = show ? 1 : 1;
    containerAlphaAfter = show ? 1 : 1;
    maskAlphaBefore = show ? 0 : 1;
    maskAlphaAfter = show ? 1 : 0;
    
    CGFloat pickerWidth = self.builder.pickerWidth;
    if (pickerWidth <= 0) {
        pickerWidth = viewSize.width;
    }
    containerFrameBefore = containerFrameAfter = CGRectMake((viewSize.width - pickerWidth) / 2, 0, pickerWidth, containerHeight);
    CGFloat containerY0, containerY1;
    if (self.builder.pickerPosition == HsPickerPositionBottom) {
        containerY0 = viewSize.height;
        containerY1 = viewSize.height - containerHeight;
    } else {
        containerY0 = viewSize.height;
        containerY1 = (viewSize.height - containerHeight) / 2;
    }
    
    containerFrameBefore.origin.y = show ? containerY0 : containerY1;
    containerFrameAfter.origin.y = !show ? containerY0 : containerY1;
    
    weakP.maskView.alpha = maskAlphaBefore;
    weakP.backgroundView.alpha = containerAlphaBefore;
    weakP.backgroundView.frame = containerFrameBefore;
    dispatch_block_t animationBlock = ^() {
        if (!show) {
            if ([weakP.pickerHandlerDelegate respondsToSelector:@selector(pickerHandler:willDismissWithType:)]) {
                [weakP.pickerHandlerDelegate pickerHandler:weakP willDismissWithType:weakP.dismissType];
            }
        }
        weakP.maskView.alpha = maskAlphaAfter;
        weakP.backgroundView.alpha = containerAlphaAfter;
        weakP.backgroundView.frame = containerFrameAfter;
    };
    dispatch_block_t completionBlock = ^() {
        if (!show) {
            if ([weakP.pickerHandlerDelegate respondsToSelector:@selector(pickerHandler:didDismissWithType:)] && weakP.dismissType == HsPickerDismissTypeConfirm) {
                [weakP.pickerHandlerDelegate pickerHandler:weakP didDismissWithType:weakP.dismissType];
            }
        }
        if (!show) {
            [weakP cleanup];
        }
    };
    
    [UIView animateWithDuration:self.builder.animationDuration animations:animationBlock completion:^(BOOL finished) {
        completionBlock();
    }];
}

- (void)maskAction
{
    if (self.builder.dismissWhenMaskClicked) {
        self.dismissType = HsPickerDismissTypeCancel;
        [self dismiss];
    }
}

- (void)cleanup
{
    [self.maskView removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [localPickerHandlers removeObject:self];
}

@end
