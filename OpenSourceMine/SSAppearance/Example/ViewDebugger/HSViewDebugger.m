//
//  HSViewDebugger.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import "HSViewDebugger.h"
#import "HSViewDebugDecorateManager.h"
#import "HSViewDebugUtility.h"

@interface HSViewDebugger ()

@property (nonatomic, strong) HSViewDebugDecorateManager *manager;

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@property (nonatomic, weak) UIView *previousView;

@end

@implementation HSViewDebugger

- (instancetype)init
{
    self = [super init];
    
    self.manager = [[HSViewDebugDecorateManager alloc] init];
    
    self.gestureRecognizer = ({
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPress:)];
    });
    
    return self;
}

+ (instancetype)instance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)install
{
    HSViewDebugger *instance = [HSViewDebugger instance];
    UIView *view = UIApplication.sharedApplication.delegate.window;
    [view addGestureRecognizer:instance.gestureRecognizer];
}

+ (void)uninstall
{
    HSViewDebugger *instance = [HSViewDebugger instance];
    UIView *view = UIApplication.sharedApplication.delegate.window;
    [view removeGestureRecognizer:instance.gestureRecognizer];
    
    [instance reset];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self reset];
        [self decorateWithGestureRecognizer:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self decorateWithGestureRecognizer:gestureRecognizer];
    }
}

- (void)decorateWithGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:view];
    
    CGRect rect = CGRectMake(point.x, point.y, 0, 0);
    
    UIView *currentView = [HSViewDebugUtility viewContainsRect:rect inView:view];
    if (currentView == self.previousView) {
        return;
    }
    
    if (currentView && self.previousView) {
        if ([HSViewDebugUtility isView:currentView parentViewOfView:self.previousView]) {
            currentView = currentView;
        } else if ([HSViewDebugUtility isView:self.previousView parentViewOfView:currentView]) {
            currentView = self.previousView;
        } else {
            UIView *sameParentView = ({
                [HSViewDebugUtility commonParentViewOfView:currentView
                                                   andView:self.previousView];
            });
            if (sameParentView) {
                currentView = sameParentView;
            }
        }
    }
    
    if (currentView == self.previousView) {
        return;
    }
    
    printf("%s\n", currentView.description.UTF8String);
    [self.manager clean:self.previousView];
    
    [self.manager decorate:currentView];
    self.previousView = currentView;
}

- (void)reset
{
    self.previousView = nil;
    [self.manager cleanAll];
}

@end
