//
//  PBXOldGroup.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBXOldGroup : NSObject

@property (nonatomic, weak, readonly) PBXOldGroup *parent;

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, copy, readonly) NSSet *childrenKeys;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, PBXOldGroup *> *children;

- (PBXOldGroup *)childWithKey:(NSString *)key;

- (NSString *)relativePath;

@end

@interface PBXOldGroupParser : NSObject

+ (PBXOldGroup *)rootGroupWithString:(NSString *)string;

@end
