//
//  SSCrypto.h
//  NameCenter
//
//  Created by ZZZ on 2022/9/17.
//

#import <Foundation/Foundation.h>

@interface SSCrypto : NSObject

+ (NSString *)AES_en:(NSString *)string key:(NSString *)key;

+ (NSString *)AES_de:(NSString *)string key:(NSString *)key;

@end
