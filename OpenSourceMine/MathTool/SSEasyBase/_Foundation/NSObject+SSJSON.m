//
//  Created by ZZZ on 2021/11/16.
//

#import "NSObject+SSJSON.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Mantle/Mantle.h>
#import <dlfcn.h>
#import <os/lock.h>
#import <mach-o/ldsyms.h>

@implementation NSObject (SSJSON)

- (void)ss_enumerateIvarsUsingBlock:(void (^)(Ivar ivar))block
{
    Class cls = [self class];
    while (cls && cls != [NSObject class]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList(cls, &count);
        for (int i = 0; i < count; ++i) {
            Ivar ivar = ivars[i];
            if (block) {
                block(ivar);
            }
        }
        free(ivars);
        cls = [cls superclass];
    }
}

- (id)ss_valueWithIvar:(Ivar)ivar
{
    const char *type = ivar_getTypeEncoding(ivar);
    ptrdiff_t offset = ivar_getOffset(ivar);
    unsigned char *bytes = (unsigned char *)(__bridge void *)self;
    
    id value = nil;
    switch (type[0]) {
        case '@': {
            id v = object_getIvar(self, ivar);
            if (strncmp(type, "@?", 2) == 0) {
                value = [NSString stringWithFormat:@"Block: %p", v];
            } else {
                value = [v ss_JSON];
                if (!value) {
                    value = [NSNull null];
                }
            }
            break;
        }
        case 'c': {
            char v = *((char *)(bytes + offset));
            value = [NSString stringWithFormat:@"%c", v];
            break;
        }
        case 'i': {
            int v = *((int *)(bytes + offset));
            value = @(v);
            break;
        }
        case 's': {
            short v = *((short *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'l': {
            long v = *((long *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'q': {
            long long v = *((long long *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'C': {
            unsigned char v = *((unsigned char *)(bytes + offset));
            value = [NSString stringWithFormat:@"%uc", v];
            break;
        }
        case 'I': {
            unsigned int v = *((unsigned int *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'S': {
            unsigned short v = *((unsigned short *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'L': {
            unsigned long v = *((unsigned long *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'Q': {
            unsigned long long v = *((unsigned long long *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'f': {
            float v = *((float *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'd': {
            double v = *((double *)(bytes + offset));
            value = @(v);
            break;
        }
        case 'B': {
            bool v = *((bool *)(bytes + offset));
            value = @(v);
            break;
        }
        case '*': {
            char *v = ((char* (*)(id, Ivar))object_getIvar)(self, ivar);
            value = [NSString stringWithFormat:@"%s", v];
            break;
        }
        case '#': {
            id v = object_getIvar(self, ivar);
            value = [NSString stringWithFormat:@"Class: %s", object_getClassName(v)];
            break;
        }
        case ':': {
            SEL v = ((SEL (*)(id, Ivar))object_getIvar)(self, ivar);
            value = [NSString stringWithFormat:@"Selector: %s", sel_getName(v)];
            break;
        }
        case '[':
        case '{':
        case '(':
        case 'b':
        case '^': {
            value = [self p_structValueWithType:type offset:offset];
            if (!value) {
                value = [NSString stringWithFormat:@"SLJ TODO: %s", type];
            }
            break;
        }
        default: {
            value = [NSString stringWithFormat:@"!!! SLJ TODO UNKNOWN TYPE: %s", type];
            break;
        }
    }
    
    return value;
}

- (NSString *)p_structValueWithType:(const char *)type offset:(ptrdiff_t)offset
{
    unsigned char *bytes = (unsigned char *)(__bridge void *)self;
    
    NSArray *all = nil;
    NSString * (^s)(CGFloat v) = ^(CGFloat v) {
        return [@(v) stringValue];
    };
    
    NSString *prefix = @"";
    if (strncmp(type, "{CGSize=", 8) == 0) {
        CGSize v = *((CGSize *)(bytes + offset));
        prefix = @"CGSize";
        all = @[s(v.width), s(v.height)];
    } else if (strncmp(type, "{CGRect=", 8) == 0) {
        CGRect v = *((CGRect *)(bytes + offset));
        prefix = @"CGRect";
        all = @[s(v.origin.x), s(v.origin.y), s(v.size.width), s(v.size.height)];
    } else if (strncmp(type, "{CGPoint=", 9) == 0) {
        CGPoint v = *((CGPoint *)(bytes + offset));
        prefix = @"CGPoint";
        all = @[s(v.x), s(v.y)];
    } else if (strncmp(type, "{CGAffineTransform=", 19) == 0) {
        CGAffineTransform v = *((CGAffineTransform *)(bytes + offset));
        prefix = @"CGAffineTransform";
        all = @[s(v.a), s(v.b), s(v.c), s(v.d), s(v.tx), s(v.ty)];
    } else if (strncmp(type, "{UIEdgeInsets=", 14) == 0) {
        UIEdgeInsets v = *((UIEdgeInsets *)(bytes + offset));
        prefix = @"UIEdgeInsets";
        all = @[s(v.top), s(v.left), s(v.bottom), s(v.right)];
    } else if (strncmp(type, "{os_unfair_lock_s=", 17) == 0) {
        os_unfair_lock v = *((os_unfair_lock *)(bytes + offset));
        prefix = @"os_unfair_lock";
        all = @[s(v._os_unfair_lock_opaque)];
    }
    
    NSString *text = [all componentsJoinedByString:@","];
    if (text.length) {
        return [NSString stringWithFormat:@"%@{%@}", prefix, text];
    }
    return nil;
}

- (NSDictionary<NSString *, id> *)ss_keyValues
{
    extern NSArray *FBGetObjectStrongReferences(id o, NSMutableDictionary *d);
    NSArray *strongIvars = FBGetObjectStrongReferences(self, nil);
    NSMutableSet *strongIvarNames = [NSMutableSet set];
    for (id obj in strongIvars) {
        NSString *name = [obj valueForKey:@"name"];
        if (name) {
            [strongIvarNames addObject:name];
        }
    }
    
    NSMutableDictionary<NSString *, id> *ret = [NSMutableDictionary dictionary];
    
    [self ss_enumerateIvarsUsingBlock:^(Ivar ivar) {
        BOOL enabled = YES;
        const char *type = ivar_getTypeEncoding(ivar);
        const char *ivarName = ivar_getName(ivar);
        NSString *name = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        if (type[0] == '@') {
            if (![strongIvarNames containsObject:name]) {
                enabled = NO;
            }
        }
        if (enabled) {
            ret[name] = [[self ss_valueWithIvar:ivar] ss_JSON];
        }
    }];
    
    return ret;
}

+ (NSDictionary<NSString *, NSString *> *)ss_classToIvarNames
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSCharacterSet *filter = [NSCharacterSet characterSetWithCharactersInString:@"@\\\""];
    [self ss_enumerateIvarsUsingBlock:^(Ivar ivar) {
        const char *type = ivar_getTypeEncoding(ivar);
        const char *name = ivar_getName(ivar);
        if (type[0] == '@') {
            NSString *key = [NSString stringWithUTF8String:type];
            key = [key stringByTrimmingCharactersInSet:filter];
            if (NSClassFromString(key) && name) {
                dictionary[key] = [NSString stringWithUTF8String:name];
            }
        }
    }];
    return dictionary;
}

- (id)ss
{
    return [self p_JSON];
}

- (id)v:(NSString *)key
{
    return [self valueForKey:key];
}

- (id)ss_JSON
{
    return [self p_JSON];
}

+ (NSArray *)ss_allMethods
{
    unsigned int count = 0;
    Method *methods = class_copyMethodList([self class], &count);
    NSMutableArray *array = [NSMutableArray array];
    for (unsigned int i = 0; i < count; ++i) {
        Method method = methods[i];
        NSString *name = NSStringFromSelector(method_getName(method));
        if (name) {
            [array addObject:name];
        }
    }
    free(methods);
    return array;
}

- (id)p_JSON
{
    // NSString NSNull
    if ([self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSNull class]]) {
        return self;
    }
    // NSNumber
    if ([self isKindOfClass:[NSNumber class]]) {
        NSNumber *object = (NSNumber *)self;
        if (isnan(object.doubleValue)) {
            return @"Number: isnan";
        } else if (isinf(object.doubleValue)) {
            return @"Number: isinf";
        }
        return object;
    }
    
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"AV"] ||
        [className hasPrefix:@"HTSGL"] ||
        [className hasPrefix:@"NLE"] ||
        [className hasPrefix:@"UI"]) {
        return [self ss_description];
    }
    if ([self isKindOfClass:[UIResponder class]]) {
        return [self ss_description];
    }
    if ([self isKindOfClass:[NSHashTable class]] ||
        [self isKindOfClass:[NSMapTable class]] ||
        [self isKindOfClass:[NSPointerArray class]]) {
        return [self ss_description];
    }
    
    if ([self conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        id <MTLJSONSerializing> object = (id <MTLJSONSerializing>)self;
        return [MTLJSONAdapter JSONDictionaryFromModel:object error:nil];
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *object = (NSArray *)self;
        NSMutableArray *ret = [NSMutableArray array];
        for (id item in object) {
            id JSON = [item ss_JSON];
            if (JSON) {
                [ret addObject:JSON];
            }
        }
        return ret;
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *object = (NSDictionary *)self;
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *string_key = nil;
            if ([key isKindOfClass:[NSString class]]) {
                string_key = key;
            } else if ([key isKindOfClass:[NSNumber class]]) {
                id JSON_key = [key ss_JSON];
                if ([JSON_key isKindOfClass:[NSString class]]) {
                    string_key = JSON_key;
                }
            }
            if (string_key.length == 0) {
                string_key = [key ss_description];
            }
            
            id JSON_value = [obj ss_JSON];
            if (string_key && JSON_value) {
                ret[string_key] = JSON_value;
            }
        }];
        return ret;
    }
    
    if ([self isKindOfClass:[NSSet class]]) {
        NSSet *object = (NSSet *)self;
        return [object.allObjects ss_JSON];
    }
    
    return [self ss_keyValues];
}

- (NSString *)ss_description
{
    NSString *desc1 = [self description];
    NSString *desc2 = [self debugDescription];
    return desc1.length > desc2.length ? desc1 : desc2;
}

@end

NSArray<NSString *> * ss_oc_all_images(void)
{
    unsigned int count = 0;
    const char **images = objc_copyImageNames(&count);
    
    NSMutableArray *ret = [NSMutableArray array];
    if (images) {
        for (unsigned int idx = 0; idx < count; ++idx) {
            const char *image = images[idx];
            NSString *name = [NSString stringWithUTF8String:image];
            if (name) {
                [ret addObject:name];
            }
        }
        free(images);
    }
    return ret;
}

NSArray<NSString *> * ss_oc_classes_in_image(NSString *image)
{
    if (!image) {
        return nil;
    }
    unsigned int count = 0;
    const char **classes = objc_copyClassNamesForImage(image.UTF8String, &count);
    NSMutableArray *ret = nil;
    if (classes) {
        ret = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int idx = 0; idx < count; ++idx) {
            const char *c = classes[idx];
            NSString *name = [NSString stringWithCString:c encoding:NSUTF8StringEncoding];
            [ret addObject:name];
        }
        free(classes);
    }
    return ret;
}

NSDictionary<NSString *, NSArray<NSString *> *> * ss_oc_all_classes(void)
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSArray *images = ss_oc_all_images();
    for (NSString *image in images) {
        NSArray *classes = ss_oc_classes_in_image(image);
        if (classes.count) {
             ret[image] = classes;
        }
    }
    return ret;
}
