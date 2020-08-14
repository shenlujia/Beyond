//
//  NSObject+SSDescription.h
//  AFNetworking
//
//  Created by shenlujia on 2017/11/16.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSDescription)

+ (NSArray<NSString *> *)ss_selectors;

+ (NSArray<NSString *> *)ss_properties;

+ (NSArray<NSString *> *)ss_ivars;

@end
