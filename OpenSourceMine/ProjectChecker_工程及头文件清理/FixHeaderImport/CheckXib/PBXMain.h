//
//  PBXMain.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBXFileReferenceSection.h"
#import "PBXGroupSection.h"
#import "PBXProjectSection.h"
#import "PBXFileObject.h"

@interface PBXMain : NSObject

@property (nonatomic, strong, readonly) NSString *path;

@property (nonatomic, strong, readonly) PBXGroupSection *groupSection;
@property (nonatomic, strong, readonly) PBXProjectSection *projectSection;
@property (nonatomic, strong, readonly) PBXFileReferenceSection *fileReferenceSection;

@property (nonatomic, strong, readonly) PBXGroup *mainGroup;

- (instancetype)initWithPath:(NSString *)path;

@end
