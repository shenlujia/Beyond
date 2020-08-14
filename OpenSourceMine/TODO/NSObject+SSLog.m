//
//  NSObject+SSLog.m
//  SSNetworking
//
//  Created by shenlujia on 2017/9/26.
//

#import "NSObject+SSLog.h"
#import <objc/runtime.h>

#ifdef DEBUG

static NSString *const Space = @"    ";
static NSString *const Newline = @"\n";

@implementation NSObject (SSLog)

- (NSString *)ss_descriptionWithLocale:(id)locale
                                indent:(NSUInteger)level
                                  head:(NSString *)head
                                  tail:(NSString *)tail
                                 count:(NSUInteger)count
                         keyEnumerator:(NSEnumerator *)keyEnumerator
                      objectEnumerator:(NSEnumerator *)objectEnumerator
{
    NSString * (^subDescription)(NSObject *) = ^(NSObject *object) {
        if ([object isKindOfClass:NSArray.class] ||
            [object isKindOfClass:NSDictionary.class] ||
            [object isKindOfClass:NSHashTable.class] ||
            [object isKindOfClass:NSMapTable.class] ||
            [object isKindOfClass:NSSet.class] ||
            [object isKindOfClass:NSOrderedSet.class]) {
            return [((id)object) descriptionWithLocale:locale indent:level + 1];
        }
        return object.description;
    };
    
    NSString *indentation = ({
        NSMutableString *text = [NSMutableString string];
        NSUInteger index = level;
        while (index--) {
            [text appendString:Space];
        }
        text;
    });
    
    NSMutableString *result = [NSMutableString string];
    
    if (head) {
        [result appendString:head];
    }
    
    NSObject *key = keyEnumerator.nextObject;
    NSObject *value = objectEnumerator.nextObject;
    NSInteger index = 0;
    while (key || value) {
        
        if (value) {
            [result appendFormat:@"%@%@%@", Newline, indentation, Space];
            if (key) {
                [result appendFormat:@"%@ = %@", subDescription(key), subDescription(value)];
            } else {
                [result appendFormat:@"%@", subDescription(value)];
            }
        }
        
        if (index != count - 1) {
            [result appendFormat:@", "];
        }
        
        ++index;
        key = keyEnumerator.nextObject;
        value = objectEnumerator.nextObject;
    }
    
    if (count) {
        [result appendFormat:@"%@%@", Newline, indentation];
    }
    
    if (tail) {
        [result appendString:tail];
    }
    
    return result;
}

@end

@implementation NSArray (SSLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"["
                                     tail:@"]"
                                    count:self.count
                            keyEnumerator:nil
                         objectEnumerator:self.objectEnumerator];
}

@end

@implementation NSDictionary (SSLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"{"
                                     tail:@"}"
                                    count:self.count
                            keyEnumerator:self.keyEnumerator
                         objectEnumerator:self.objectEnumerator];
}

@end

@implementation NSHashTable (SSLog)

- (NSString *)description
{
    return [self descriptionWithLocale:[NSLocale currentLocale] indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"NSHashTable ["
                                     tail:@"]"
                                    count:self.count
                            keyEnumerator:nil
                         objectEnumerator:self.objectEnumerator];
}

@end

@implementation NSMapTable (SSLog)

- (NSString *)description
{
    return [self descriptionWithLocale:[NSLocale currentLocale] indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"NSMapTable {"
                                     tail:@"}"
                                    count:self.count
                            keyEnumerator:self.keyEnumerator
                         objectEnumerator:self.objectEnumerator];
}

@end

@implementation NSSet (SSLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"NSSet ["
                                     tail:@"]"
                                    count:self.count
                            keyEnumerator:nil
                         objectEnumerator:self.objectEnumerator];
}

@end

@implementation NSOrderedSet (SSLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self ss_descriptionWithLocale:locale
                                   indent:level
                                     head:@"NSOrderedSet ["
                                     tail:@"]"
                                    count:self.count
                            keyEnumerator:nil
                         objectEnumerator:self.objectEnumerator];
}

@end

#endif
