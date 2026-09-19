//
//  NSObject+MethodSwizzle.h — stub
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzle)
+ (BOOL)ss_swizzleMethod:(SEL)originalSEL withMethod:(SEL)otherSEL;
+ (BOOL)ss_swizzleClassMethod:(SEL)originalSEL withClassMethod:(SEL)otherSEL;
@end
