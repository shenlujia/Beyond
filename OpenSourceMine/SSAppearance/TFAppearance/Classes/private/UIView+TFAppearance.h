//
//  UIView+TFAppearance.h
//  TFAppearance
//
//  Created by shenlujia on 2018/6/4.
//

#import <UIKit/UIKit.h>
#import "TFAppearanceProtocol.h"

@interface UIView (TFAppearance)

- (__kindof id <TFAppearance>)appearance_objectWithClass:(Class)aClass;

- (void)appearance_addObject:(id <TFAppearance>)object;

- (void)appearance_setNeedsUpdateAppearance;

@end
