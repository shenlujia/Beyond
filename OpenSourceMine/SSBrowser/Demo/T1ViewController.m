//
//  T1ViewController.m
//  Demo
//
//  Created by ZZZ on 2020/9/29.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "T1ViewController.h"
#import <WebKit/WebKit.h>

@interface T1ViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSDictionary * (^networkParamsHandler)(void);

@end

@implementation T1ViewController

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
    }

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = self.indicatorView;

    self.webView = ({
        WKWebView *view = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:view];
        view.UIDelegate = self;
        view.navigationDelegate = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view;
    });

    self.textView = ({
        CGSize size = self.view.bounds.size;
        CGRect frame = CGRectMake(0, 0, size.width, 80);
        frame.origin.y = size.height - frame.size.height - safeAreaInsets.bottom;

        UITextView *view = [[UITextView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        view.textColor = UIColor.whiteColor;
        view.font = [UIFont systemFontOfSize:9];
        view.editable = NO;
        view;
    });

    self.navigationItem.leftBarButtonItems = ({
        id a = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                             target:self
                                                             action:@selector(refreshAction)];
        @[a];
    });

    self.navigationItem.rightBarButtonItems = ({
        id a = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                             target:self
                                                             action:@selector(rewindAction)];
        id b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                             target:self
                                                             action:@selector(forwardAction)];
        @[b, a];
    });

    [self refreshAction];
}

- (void)refreshAction
{
    [self logSection:@"refresh"];
    NSURL *URL = [NSURL URLWithString:@"https://www.baidu.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)rewindAction
{
    [self logSection:@"back"];
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)forwardAction
{
    [self logSection:@"next"];
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [self log:NSStringFromSelector(_cmd)];

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(ios(13.0))
{
    [self log:NSStringFromSelector(_cmd)];

    decisionHandler(WKNavigationActionPolicyAllow, nil);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    [self log:NSStringFromSelector(_cmd)];

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self log:NSStringFromSelector(_cmd)];

    [self.indicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self log:NSStringFromSelector(_cmd)];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    [self log:NSStringFromSelector(_cmd)];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self log:NSStringFromSelector(_cmd)];

    [self.indicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];

    [self.indicatorView stopAnimating];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self log:NSStringFromSelector(_cmd)];
}

- (void)webView:(WKWebView *)webView authenticationChallenge:(NSURLAuthenticationChallenge *)challenge shouldAllowDeprecatedTLS:(void (^)(BOOL))decisionHandler
{
    [self log:NSStringFromSelector(_cmd)];
}

#pragma mark - private

- (void)logSection:(NSString *)title
{
    NSString *text = [NSString stringWithFormat:@"--------------------  %@", title = title ?: @""];
    [self log:text];
}

- (void)log:(NSString *)title
{
    NSMutableString *text = [NSMutableString stringWithString:self.textView.text ?: @""];
    if (text.length) {
        [text appendString:@"\n"];
    }

    title = title ?: @"";
    [text appendString:title];

    self.textView.text = text;
    CGSize contentSize = self.textView.contentSize;
    CGFloat visibleHeight = 10;
    [self.textView scrollRectToVisible:CGRectMake(0, contentSize.height - visibleHeight, contentSize.width, visibleHeight) animated:YES];
}

@end
