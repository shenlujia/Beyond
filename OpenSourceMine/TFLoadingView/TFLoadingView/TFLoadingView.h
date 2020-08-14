//
//  TFLoadingView.h
//  Pods
//
//  Created by shenlujia on 15/9/6.
//
//

#import <UIKit/UIKit.h>
#import "TFLoadingStyle.h"
#import "TFLoadingConfiguration.h"

@interface TFLoadingView : UIView

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIButton *reloadButton;

@property (nonatomic, assign) TFLoadingState state;

@property (nonatomic, strong) TFLoadingConfiguration *configuration;

@property (nonatomic, copy) void (^tapBlock)(TFLoadingView *loadingView);

@end

@interface UIView (TFLoadingView)

@property (nonatomic, strong) TFLoadingView *tf_loadingView;

@end
