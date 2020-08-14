//
//  HSKVODeallocSwizzle.h
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSKVODeallocSwizzle : NSObject

+ (void)inject:(id)object callback:(void (^)(__unsafe_unretained id unretainedObject))callback;

@end
