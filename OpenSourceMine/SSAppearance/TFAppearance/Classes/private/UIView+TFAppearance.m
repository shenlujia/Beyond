//
//  UIView+TFAppearance.m
//  TFAppearance
//
//  Created by shenlujia on 2018/6/4.
//

#import "UIView+TFAppearance.h"
#import <objc/runtime.h>
#import "TFAppearanceObject.h"

@implementation UIView (TFAppearance)

- (__kindof id <TFAppearance>)appearance_objectWithClass:(Class)aClass
{
    NSMutableArray *array = [self appearance_objectArray];
    for (id <TFAppearance> object in [array copy]) {
        if ([object class] == aClass &&
            [object conformsToProtocol:@protocol(TFAppearance)]) {
            return object;
        }
    }
    return nil;
}

- (void)appearance_addObject:(id <TFAppearance>)object
{
    if (!object) {
        return;
    }
    
    Class aClass = [object class];
    NSString *key = NSStringFromClass(aClass);
    if (key.length == 0) {
        return;
    }
    
    NSMutableArray *array = [self appearance_objectArray];
    for (id temp in [array copy]) {
        if (aClass == [temp class]) {
            [array removeObject:temp];
        }
    }
    [array addObject:object];
}

- (void)appearance_setNeedsUpdateAppearance
{
    NSMutableArray *array = [self appearance_objectArray];
    for (TFAppearanceObject *object in [array copy]) {
        object.needsUpdateAppearance = YES;
        if ([object conformsToProtocol:@protocol(TFAppearance)]) {
            id <TFAppearance> appearance = (id)object;
            appearance.decorate(self);
        }
    }
}

- (NSMutableArray *)appearance_objectArray
{
    const void * key = @selector(appearance_objectArray);
    NSMutableArray *array = objc_getAssociatedObject(self, key);
    if (![array isKindOfClass:[NSMutableArray class]]) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, key, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

@end
