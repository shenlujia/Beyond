//
//  NSArray+SS.m — stub
//

#import "NSArray+SS.h"

@implementation NSArray (SS)

- (id)btd_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return self[index];
    }
    return nil;
}

@end

@implementation NSMutableArray (SS)

- (void)btd_addObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
}

@end
