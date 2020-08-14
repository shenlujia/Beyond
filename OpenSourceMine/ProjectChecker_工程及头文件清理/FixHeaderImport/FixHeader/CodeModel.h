//
//  CodeModel.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeModel : NSObject

@property (nonatomic, copy, readonly) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

- (void)updateWithHeaders:(NSDictionary *)headers;

@end
