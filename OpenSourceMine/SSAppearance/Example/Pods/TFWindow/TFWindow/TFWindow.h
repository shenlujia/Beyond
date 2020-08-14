//
//  TFWindow.h
//  Pods-TFWindow
//
//  Created by admin on 2018/5/12.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, TFWindowType) {
    TFWindowTypeNormal = 0,
    TFWindowTypeAlert
};

////////////////////////////////////////////////////////////

@interface TFWindow : UIWindow

@property (nonatomic, assign, readonly) TFWindowType type;

- (instancetype)initWithType:(TFWindowType)type;

+ (__kindof UIWindow *)topWindow;

+ (__kindof UIViewController *)topViewController;

@end

////////////////////////////////////////////////////////////
