//
//  NSObject+SSJSON.h — stub
//

#import <Foundation/Foundation.h>

@interface NSObject (SSJSON)
/// Convert to a JSON-safe object (NSString/NSNumber/NSArray/NSDictionary/NSNull).
- (id)ss_JSON;
/// Short alias for ss_JSON.
- (id)ss;
/// Dump key-value pairs — returns a dictionary representation of the object's internal state.
- (id)ss_keyValues;
@end
