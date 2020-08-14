//
//  CodeFile.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/3.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeFile : NSObject

@property (nonatomic, copy, readonly) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

- (void)updateWithHeaders:(NSDictionary *)headers whiteListHeaders:(NSMutableSet *)whiteListHeaders;

@end
