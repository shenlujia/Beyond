//
//  TFAppearanceObject.m
//  TFAppearance
//
//  Created by shenlujia on 2018/6/8.
//

#import "TFAppearanceObject.h"

@interface TFAppearanceObject ()

@property (nonatomic, weak, readonly) TFAppearanceObject *p_master;

@end

@implementation TFAppearanceObject

+ (NSArray *)ss_ignoredPropertyNames
{
    NSArray *ret = @[@"p_leader", @"decorate"];
    
    NSArray *temp = [super ss_ignoredPropertyNames];
    if (temp.count) {
        ret = [ret arrayByAddingObjectsFromArray:temp];
    }
    
    return ret;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _needsUpdateAppearance = YES;
    }
    return self;
}

- (__kindof TFAppearanceObject *)createFollower
{
    TFAppearanceObject *object = [self copy];
    
    TFAppearanceObject *master = [self master];
    if (!master) {
        master = self;
    }
    object->_p_master = master;
    
    return object;
}

- (BOOL)isFollower
{
    return [self master] != nil;
}

- (__kindof TFAppearanceObject *)master
{
    TFAppearanceObject *ret = self.p_master;
    while (ret.p_master) {
        ret = ret.p_master;
    }
    return ret;
}

- (void)updateWithAppearanceObject:(TFAppearanceObject *)object
{
    if (![object isKindOfClass:[self class]]) {
        return;
    }
    
    NSArray *properties = [[self class] ss_properties];
    for (SSProperty *property in properties) {
        if ([property.typeClass isSubclassOfClass:[TFAppearanceObject class]]) {
            TFAppearanceObject *value0 = [self valueForKey:property.name];
            TFAppearanceObject *value1 = [object valueForKey:property.name];
            if (value0 && value1) {
                [value0 updateWithAppearanceObject:value1];
            }
        }
    }
}

@end
