//
//  EHDURLParse.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHDURLParse : NSObject
+ (void)addURLPattern:(NSString *)URLPattern handler:(id (^)(NSDictionary *parameters))handler;
+ (void)removeURLPattern:(NSString *)URL;
+ (NSString *)pathFromURL:(NSString *)URL;
+ (NSString *)lastPathComponentForURL:(NSString *)URL;
+ (NSDictionary *)paramsFromURL:(NSString *)URL;
+ (NSMutableDictionary *)extractParametersFromURL:(NSString *)URL;
@end
