

#import <Foundation/Foundation.h>

@interface HsPickerItem : NSObject

// important!!! 强引用，且不拷贝
@property (nonatomic, strong, readonly) __kindof NSObject *object;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *value;
@property (nonatomic, copy, readonly) NSArray<__kindof HsPickerItem *> *subItems;
@property (nonatomic, assign, readonly) NSInteger level;

- (instancetype)initWithObject:(NSObject *)object
                    identifier:(NSString *)identifier
                         value:(NSString *)value
                      subItems:(NSArray *)subItems;

- (instancetype)initWithIdentifier:(NSString *)identifier
                             value:(NSString *)value
                          subItems:(NSArray *)subItems;

- (instancetype)initWithValue:(NSString *)value
                     subItems:(NSArray *)subItems;

// identifier与value都相等时，两个对象才相等
- (BOOL)isEqualToItem:(HsPickerItem *)other;

@end
