//
//  HSKVO.h
//  HSKVO
//
//  Created by shenlujia on 2015/12/25.
//

#import <Foundation/Foundation.h>
#import "NSObject+HSKVO.h"

@interface HSKVOManager : NSObject <HSKVO>

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObserver:(id)observer NS_DESIGNATED_INITIALIZER;

@end
