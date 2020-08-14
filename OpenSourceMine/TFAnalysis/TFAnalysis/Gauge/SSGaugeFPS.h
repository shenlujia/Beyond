//
//  SSGaugeFPS.h
//  Pods-Demo
//
//  Created by TF020283 on 2018/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSGaugeFPS : NSObject

@property (nonatomic, copy) void (^callback)(CGFloat value);

@end

NS_ASSUME_NONNULL_END
