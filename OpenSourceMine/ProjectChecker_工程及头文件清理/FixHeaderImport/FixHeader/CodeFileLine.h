//
//  CodeFileLine.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/3.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeFileLine : NSObject

@property (nonatomic, copy, readonly) NSString *lineString;

@property (nonatomic, copy, readonly) NSString *header;

@property (nonatomic, copy, readonly) NSString *result;

- (instancetype)initWithLine:(NSString *)line
                     headers:(NSDictionary *)headers
            whiteListHeaders:(NSMutableSet *)whiteListHeaders;

@end
