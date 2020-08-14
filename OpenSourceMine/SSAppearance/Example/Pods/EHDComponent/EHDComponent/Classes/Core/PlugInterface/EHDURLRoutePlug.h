//
//  EHDURLRoutePlug.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#ifndef EHDURLRoutePlug_h
#define EHDURLRoutePlug_h

/**
 *  URL路由插件化接口
 */
@protocol EHDURLRoutePlug <NSObject>
+ (void)registerURL:(NSString *)URL handler:(id (^)(NSDictionary *parameters))handler;
+ (void)deregisterURL:(NSString *)URL;
+ (id)openURL:(NSString *)URL extraData:(id)extraData completion:(void (^)(id))completion;
@end

#endif /* EHDURLRoutePlug_h */
