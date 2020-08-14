//
//  PBXGroupSection.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBXHeader.h"
#import "PBXFileReferenceSection.h"

@interface PBXGroup : NSObject

@property (nonatomic, weak, readonly) PBXGroup *parent;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *sourceTree;

@property (nonatomic, assign, readonly) PBXGroupSourceTreeType sourceTreeType;

@property (nonatomic, copy, readonly) NSSet<NSString *> *childrenIdentifiers;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, PBXGroup *> *children;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, PBXFileReference *> *fileReferences;

- (NSString *)relativePath;

- (void)addFileReferenceIfNeeded:(PBXFileReference *)reference;

@end

@interface PBXGroupSection : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSString *, PBXGroup *> *groups;

- (instancetype)initWithString:(NSString *)string;

@end
