//
//  Created by ZZZ on 2021/11/16.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSJSON)

- (NSDictionary<NSString *, id> *)ss_keyValues;

// 方便打印
- (id)ss;

- (id)v:(NSString *)key;

- (id)ss_JSON;

+ (NSArray *)ss_allMethods;

+ (NSDictionary<NSString *, NSString *> *)ss_classToIvarNames;

@end

FOUNDATION_EXTERN NSArray<NSString *> * ss_oc_all_images(void);

FOUNDATION_EXTERN NSArray<NSString *> * ss_oc_classes_in_image(NSString *image);

FOUNDATION_EXTERN NSDictionary<NSString *, NSArray<NSString *> *> * ss_oc_all_classes(void);
