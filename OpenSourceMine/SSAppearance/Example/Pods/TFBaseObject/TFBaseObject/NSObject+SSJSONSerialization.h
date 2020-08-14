//
//  NSObject+SSJSONSerialization.h
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import <Foundation/Foundation.h>

@interface SSProperty : NSObject

/** 成员属性的名字 */
@property (nonatomic, copy, readonly) NSString *name;
/** 是否为id类型 */
@property (nonatomic, assign, readonly) BOOL idType;
/** 成员属性来源于哪个类（可能是父类） */
@property (nonatomic, assign, readonly) Class srcClass;
/** 对象类型（如果是基本数据类型，此值为nil） */
@property (nonatomic, assign, readonly) Class typeClass;
/** 类型是否来自于Foundation框架，比如NSString、NSArray */
@property (nonatomic, assign, readonly) BOOL fromFoundation;

@end

@interface NSObject (SSJSONSerialization)

+ (NSArray<NSString *> *)ss_ignoredSystemPropertyNames; // 需要忽略的系统属性名
+ (NSDictionary<NSString *, NSArray<SSProperty *> *> *)ss_classProperties; // key = class, value = 对应类所有属性
+ (NSArray<SSProperty *> *)ss_properties; // 所有属性

- (id)ss_keyValues; // 返回数组或者字典
- (void)ss_setKeyValues:(id)keyValues; // 支持字典和自定义对象

- (id)ss_copyIfAllowed;

@end
