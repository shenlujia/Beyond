
#if INHOUSE_TARGET

#import "NSObject+SSJSON.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Mantle/Mantle.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

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
                value = [NSString stringWithFormat:@"TODO: %s", type];
            }
            break;
        }
        default: {
            value = [NSString stringWithFormat:@"!!! UNKNOWN TYPE: %s", type];
            break;
        }
    }
    
    return value;
}

- (NSString *)p_structValueWithType:(const char *)type offset:(ptrdiff_t)offset
{
    unsigned char *bytes = (unsigned char *)(__bridge void *)self;
    
    NSString * (^f)(CGFloat v) = ^(CGFloat v) {
        return [@(v) stringValue];
    };
    
    if (strncmp(type, "{CGPoint=", 9) == 0) {
        CGPoint v = *((CGPoint *)(bytes + offset));
        return [NSString stringWithFormat:@"Point{%@,%@}", f(v.x), f(v.y)];
    }
    
    if (strncmp(type, "{CGRect=", 8) == 0) {
        CGRect v = *((CGRect *)(bytes + offset));
        return [NSString stringWithFormat:@"Rect{%@,%@,%@,%@}", f(v.origin.x), f(v.origin.y), f(v.size.width), f(v.size.height)];
    }
    
    if (strncmp(type, "{CGAffineTransform=", 19) == 0) {
        CGAffineTransform v = *((CGAffineTransform *)(bytes + offset));
        return [NSString stringWithFormat:@"Transform{%@,%@,%@,%@,%@,%@}", f(v.a), f(v.b), f(v.c), f(v.d), f(v.tx), f(v.ty)];
    }
    
    return nil;
}

- (NSDictionary<NSString *, id> *)ss_keyValues
{
    extern NSArray *FBGetObjectStrongReferences(id o, NSMutableDictionary *d);
    NSArray *strongIvars = FBGetObjectStrongReferences(self, nil);
    NSMutableSet *names = [NSMutableSet set];
    for (id obj in strongIvars) {
        NSString *name = [obj valueForKey:@"name"];
        if (name) {
            [names addObject:name];
        }
    }
    
    NSMutableDictionary<NSString *, id> *ret = [NSMutableDictionary dictionary];
    
    [self ss_enumerateIvarsUsingBlock:^(Ivar ivar) {
        BOOL enabled = YES;
        const char *type = ivar_getTypeEncoding(ivar);
        const char *ivarName = ivar_getName(ivar);
        NSString *name = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        if (type[0] == '@') {
            if (![names containsObject:name]) {
                enabled = NO;
            }
        }
        if (enabled) {
            ret[name] = [[self ss_valueWithIvar:ivar] ss_JSON];
        }
    }];
    
    return ret;
}

- (id)ss_JSON
{
    if ([self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSNull class]]) {
        return self;
    }
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

#endif
