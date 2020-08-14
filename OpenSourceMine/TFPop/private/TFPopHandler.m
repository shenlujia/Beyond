//
//  HsPopHandler.m
//  Pods
//
//  Created by shenlujia on 2017/1/19.
//
//

#import "TFPopHandler.h"
#import "TFPopContainerView.h"
#import "TFPopTask.h"
#import "UIView+TFPop.h"

@interface TFPopHandler () <TFPopContainerViewDelegate>

@property (nonatomic, weak) UIView *hostView;

@property (nonatomic, strong) TFPopContainerView *containerView;

@property (nonatomic, strong) NSMutableArray *tasks;

@end

@implementation TFPopHandler

- (instancetype)initWithHostView:(UIView *)hostView
{
    self = [self init];
    if (self) {
        _hostView = hostView;
        
        _containerView = ({
            TFPopContainerView *view = [[TFPopContainerView alloc] init];
            [self.hostView addSubview:view];
            view.hidden = YES;
            view.delegate = self;
            CGRect frame = view.superview.bounds;
            frame.origin = CGPointZero;
            view.frame = frame;
            view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight);
            view;
        });
        
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (void)show:(UIView *)view configuration:(TFPopConfiguration *)configuration
{
    if (!view || !configuration) {
        return;
    }
    
    TFPopTask *task = [[TFPopTask alloc] initWithView:view
                                        configuration:configuration];
    [self.tasks addObject:task];
    
    [self p_show:YES task:task animated:YES];
}

- (void)dismiss:(UIView *)view
{
    for (TFPopTask *task in [self.tasks copy]) {
        if (task.view == view) {
            [self.tasks removeObject:task];
            [self p_show:NO task:task animated:YES];
        }
    }
}

#pragma mark - TFPopContainerViewDelegate

- (void)containerViewFrameDidChange:(TFPopContainerView *)containerView
{
    TFPopTask *task = self.tasks.lastObject;
    [self p_show:YES task:task animated:NO];
}

- (void)containerViewDidTapMask:(TFPopContainerView *)containerView
{
    if (self.tasks.count == 0) {
        return;
    }
    TFPopTask *task = self.tasks.lastObject;
    if (task.configuration.dismissMode == TFPopDismissModeTapMask) {
        [self.tasks removeObject:task];
        [self p_show:NO task:task animated:YES];
    }
}

#pragma mark - private

- (void)p_show:(BOOL)show task:(TFPopTask *)task animated:(BOOL)animated
{
    if (!task) {
        return;
    }
    
    TFPopConfiguration *configuration = task.configuration;
    UIView *backgroundView = task.view.tfpop_backgroundView;
    
    __weak id <TFPopDelegate> delegate = configuration.delegate;
    if (show) {
        if ([delegate respondsToSelector:@selector(popViewWillAppear:)]) {
            [delegate popViewWillAppear:task.view];
        }
    } else {
        if ([delegate respondsToSelector:@selector(popViewWillDisappear:)]) {
            [delegate popViewDidDisappear:task.view];
        }
    }
    
    // 显示时 初始化参数
    if (show) {
        // containerView
        self.containerView.hidden = NO;
        [self.containerView removeFromSuperview];
        [self.hostView addSubview:self.containerView];
        
        // backgroundView
        [task.view.tfpop_backgroundView removeFromSuperview];
        [self.containerView addSubview:task.view.tfpop_backgroundView];
        
        // view
        [task.view removeFromSuperview];
        [self.containerView addSubview:task.view];
    }
    
    // maskViewAlpha
    const CGFloat maskViewAlpha0 = 0;
    const CGFloat maskViewAlpha1 = 1;
    
    // frame
    const CGRect viewBeginFrame = [task viewBeginFrame];
    const CGRect viewEndFrame = [task viewEndFrame];
    CGRect viewShowFrame = CGRectZero;
    CGRect backgroundViewShowFrame = CGRectZero;
    [task getShowFrame:&viewShowFrame backgroundViewFrame:&backgroundViewShowFrame];
   
    if (show) {
        task.view.frame = viewBeginFrame;
        task.view.alpha = [task viewBeginAlpha];
        backgroundView.frame = viewBeginFrame;
        backgroundView.alpha = [task viewBeginAlpha];
        self.containerView.maskView.alpha = maskViewAlpha0;
    }
    
    // animation
    void (^animations)(void) = ^{
        task.view.frame = show ? viewShowFrame : viewEndFrame;
        task.view.alpha = show ? [task viewShowAlpha] : [task viewEndAlpha];
        backgroundView.frame = show ? backgroundViewShowFrame : viewEndFrame;
        backgroundView.alpha = show ? [task viewShowAlpha] : [task viewEndAlpha];
        self.containerView.maskView.alpha = show ? maskViewAlpha1 : maskViewAlpha0;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (show) {
            if ([delegate respondsToSelector:@selector(popViewDidAppear:)]) {
                [delegate popViewDidAppear:task.view];
            }
        } else {
            if (self.tasks.count == 0) {
                self.containerView.hidden = YES;
            }
            [task.view removeFromSuperview];
            [backgroundView removeFromSuperview];
            
            if ([delegate respondsToSelector:@selector(popViewDidDisappear:)]) {
                [delegate popViewDidDisappear:task.view];
            }
        }
    };
    const CGFloat duration = ({
        show ? configuration.showAnimationDuration : configuration.dismissAnimationDuration;
    });
    if (animated && duration > 0) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

@end
