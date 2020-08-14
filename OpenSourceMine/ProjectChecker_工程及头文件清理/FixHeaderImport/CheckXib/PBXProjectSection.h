//
//  PBXProjectSection.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBXProjectSection : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *mainGroup;

- (instancetype)initWithString:(NSString *)string;

@end
