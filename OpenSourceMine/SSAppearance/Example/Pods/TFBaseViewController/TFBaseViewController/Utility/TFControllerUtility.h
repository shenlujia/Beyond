//
//  TFControllerUtility.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/28.
//

#import <Foundation/Foundation.h>

@interface TFControllerUtility : NSObject

+ (void)push:(NSString *)name data:(id)data;
+ (void)broadcast:(NSString *)name data:(id)data;

@end
