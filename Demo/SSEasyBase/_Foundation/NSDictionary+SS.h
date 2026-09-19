//
//  NSDictionary+SS.h — stub
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SS)
/// Safe key accessor — returns nil if key is absent.
- (nullable id)btd_objectForKey:(id)key;
@end
