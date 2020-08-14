//
//  XIBChecker.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBXMain.h"

@interface XIBChecker : NSObject

@property (nonatomic, strong, readonly) PBXMain *main;
@property (nonatomic, strong, readonly) PBXGroup *group;

@property (nonatomic, strong, readonly) NSSet *inuse;
@property (nonatomic, strong, readonly) NSSet *notInUse;
@property (nonatomic, strong, readonly) NSSet *found;
@property (nonatomic, strong, readonly) NSSet *notFound;

@property (nonatomic, strong, readonly) NSDictionary *xibMapping;

- (instancetype)initWithObject:(PBXMain *)main group:(PBXGroup *)group;

- (NSDictionary<NSString *, NSString *> *)allXibReferences;

- (void)check;

@end
