
#if INHOUSE_TARGET

#import <Foundation/Foundation.h>

@interface NSObject (SSJSON)

- (NSDictionary<NSString *, id> *)ss_keyValues;

- (id)ss_JSON;

@end

#endif
