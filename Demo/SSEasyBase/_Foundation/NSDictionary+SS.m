//
//  NSDictionary+SS.m — stub
//

#import "NSDictionary+SS.h"

@implementation NSDictionary (SS)

- (id)btd_objectForKey:(id)key
{
    if (!key) return nil;
    return [self objectForKey:key];
}

@end
