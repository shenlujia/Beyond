//
//  PBXFileObject.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBXFileReferenceSection.h"
#import "PBXGroupSection.h"

@interface PBXFileObject : NSObject

@property (nonatomic, strong, readonly) PBXGroup *folderGroup;
@property (nonatomic, strong, readonly) PBXFileReference *reference;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;

- (instancetype)initWithFolder:(NSString *)folder
                         group:(PBXGroup *)group
                     reference:(PBXFileReference *)reference;

@end
