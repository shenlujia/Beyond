//
//  NSArray+SS.h — stub
//

#import <Foundation/Foundation.h>

@interface NSArray (SS)
/// Safe index accessor (returns nil instead of out-of-bounds crash).
- (nullable id)btd_objectAtIndex:(NSUInteger)index;
@end

@interface NSMutableArray (SS)
/// Safe add — silently does nothing if object is nil.
- (void)btd_addObject:(nullable id)object;
@end
