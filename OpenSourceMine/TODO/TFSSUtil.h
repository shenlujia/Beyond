//
//  TFSSUtil.h
//  AFNetworking
//
//  Created by admin on 2018/5/10.
//

#import <Foundation/Foundation.h>

@interface TFSSUtil : NSObject

+ (NSArray *)appClassNames; // 用户所有类名
+ (NSArray *)allClassNames; // 系统所有类名
+ (NSArray *)appClassNamesRespondsToSelector:(SEL)aSelector;
+ (NSArray *)allClassNamesRespondsToSelector:(SEL)aSelector;

+ (NSSet *)classNameWhiteList;

@end
