//
//  TFBaseModel.m
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import "TFBaseObject.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension/MJExtension.h>
#pragma clang diagnostic pop

@interface TFBaseObject ()

@end

@implementation TFBaseObject

- (NSString *)description
{
#ifdef DEBUG
    NSString *name = NSStringFromClass([self class]);
    NSString *head = [NSString stringWithFormat:@"======== %@ HEAD ========", name];
    NSString *tail = [NSString stringWithFormat:@"======== %@ TAIL ========", name];
    id keyValues = [self ss_keyValues];
    return [NSString stringWithFormat:@"%@\n%@\n%@", head, keyValues, tail];
#else
    return [super description];
#endif
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self mj_decode:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self mj_encode:aCoder];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    NSArray *ignoredPropertyNames = [[self class] mj_ignoredPropertyNames];
    id object = [[[self class] alloc] init];
    
    for (SSProperty *property in [[self class] ss_properties]) {
        NSString *name = property.name;
        if (![ignoredPropertyNames containsObject:name]) {
            id value = [self valueForKey:name];
            value = [value ss_copyIfAllowed];
            [object setValue:value forKey:name];
        }
    }
    
    return object;
}

#pragma mark - SSJSONSerialization

+ (NSArray *)ss_ignoredPropertyNames
{
    return nil;
}

+ (NSDictionary *)ss_replacedKeyFromPropertyName
{
    return nil;
}

+ (NSDictionary *)ss_objectClassInArray
{
    return nil;
}

- (id)ss_newValueFromOldValue:(id)oldValue property:(NSString *)property class:(Class)aClass
{
    return nil;
}

#pragma mark - public

- (id)ss_deepCopy
{
    id object = [[[self class] alloc] init];
    [object ss_setKeyValues:[self ss_keyValues]];
    return object;
}

- (void)ss_setFill
{
    NSArray *properties = [[self class] ss_properties];
    
    for (SSProperty *property in properties) {
        id obj = [self valueForKey:property.name];
        if (!obj) {
            if (property.typeClass) {
                id temp = [[property.typeClass alloc] init];
                // 可能拷贝 必须这样转换一次
                [self setValue:temp forKey:property.name];
                obj = [self valueForKey:property.name];
            }
        }
        if ([obj isKindOfClass:[TFBaseObject class]]) {
            [obj ss_setFill];
        }
    }
}

#pragma mark - MJExtension

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return [self ss_replacedKeyFromPropertyName];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return [self ss_objectClassInArray];
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    id newValue = [self ss_newValueFromOldValue:oldValue
                                       property:property.name
                                          class:property.type.typeClass];
    if (newValue) {
        return newValue;
    }
    
    if (property.type.typeClass == [NSDate class]) {
        return [NSDate ss_dateWithObject:oldValue];
    }
    return oldValue;
}

+ (NSArray *)mj_ignoredPropertyNames
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *ignoredPropertyNames = [self ss_ignoredPropertyNames];
    NSArray *ignoredSystemPropertyNames = [self ss_ignoredSystemPropertyNames];
    if (ignoredPropertyNames.count) {
        [result addObjectsFromArray:ignoredPropertyNames];
    }
    if (ignoredSystemPropertyNames.count) {
        [result addObjectsFromArray:ignoredSystemPropertyNames];
    }
    return result;
}

+ (NSArray *)mj_ignoredCodingPropertyNames
{
    return [self mj_ignoredPropertyNames];
}

@end
