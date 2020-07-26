//
//  BlockNotCallChecker.h
//  Demo
//
//  Created by SLJ on 2020/7/13.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockNotCallChecker : NSObject

@property (nonatomic, copy) void (^callback)(void);

- (instancetype)initWithName:(NSString *)name;

- (void)didCall;

@end
