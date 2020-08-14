//
//  TFBaseModel.h
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import <Foundation/Foundation.h>
#import "NSDate+SSJSONSerialization.h"
#import "NSObject+SSJSONSerialization.h"

@protocol SSJSONSerialization <NSObject>
@required
+ (NSArray *)ss_ignoredPropertyNames;
+ (NSDictionary *)ss_replacedKeyFromPropertyName;
+ (NSDictionary *)ss_objectClassInArray;
- (id)ss_newValueFromOldValue:(id)oldValue property:(NSString *)property class:(Class)aClass;
@end

@interface TFBaseObject : NSObject <NSCoding, NSCopying, SSJSONSerialization>

/// 深拷贝
- (id)ss_deepCopy;

/// 值填充 如果属性类和当前类相同 会导致死循环
- (void)ss_setFill;

@end
