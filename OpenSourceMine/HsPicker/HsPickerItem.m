

#import "HsPickerItem.h"

@interface HsPickerItem()

@property (nonatomic, assign, readonly) NSInteger privateLevel;

@end

@implementation HsPickerItem

- (instancetype)initWithObject:(NSObject *)object
                    identifier:(NSString *)identifier
                         value:(NSString *)value
                      subItems:(NSArray *)subItems
{
    self = [super init];
    
    _privateLevel = -1;
    _object = object;
    _identifier = [identifier copy];
    _value = [value copy];
    _subItems = [subItems copy];
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             value:(NSString *)value
                          subItems:(NSArray *)subItems
{
    return [self initWithObject:nil identifier:identifier value:value subItems:subItems];
}

- (instancetype)initWithValue:(NSString *)value
                     subItems:(NSArray *)subItems
{
    return [self initWithObject:nil identifier:nil value:value subItems:subItems];
}

- (BOOL)isEqualToItem:(HsPickerItem *)other
{
    if (![other isKindOfClass:HsPickerItem.class]) {
        return NO;
    }
    
    BOOL identifierEqual = NO;
    if (!self.identifier && !other.identifier) {
        identifierEqual = YES;
    } else if (self.identifier || other.identifier) {
        identifierEqual = [self.identifier isEqualToString:other.identifier];
    }
    
    BOOL valueEqual = NO;
    if (!self.value && !other.value) {
        valueEqual = YES;
    } else if (self.value || other.value) {
        valueEqual = [self.value isEqualToString:other.value];
    }
    
    return identifierEqual && valueEqual;
}

- (NSInteger)level
{
    if (self.privateLevel < 0) {
        NSInteger ret = 0;
        for (HsPickerItem *item in self.subItems) {
            ret = MAX(ret, item.level + 1);
        }
        _privateLevel = ret;
    }
    return self.privateLevel;
}

@end
