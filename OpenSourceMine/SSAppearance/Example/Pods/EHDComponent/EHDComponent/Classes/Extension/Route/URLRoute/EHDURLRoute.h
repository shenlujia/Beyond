//
//  EHDURLRoute.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EHDURLRoute : NSObject
+ (void)registerURL:(NSString *)URL handler:(id (^)(NSDictionary *parameters))handler;
+ (void)deregisterURL:(NSString *)URL;
+ (id)openURL:(NSString *)URL completion:(void (^)(id))completion;
+ (id)openURL:(NSString *)URL extraData:(id)extraData completion:(void (^)(id))completion;
@end
