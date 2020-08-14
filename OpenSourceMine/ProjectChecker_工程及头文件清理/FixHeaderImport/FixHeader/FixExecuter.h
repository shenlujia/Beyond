//
//  FixExecuter.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PodModel.h"
#import "CodeModel.h"

@class FixExecuter;

@protocol FixExecuterDelegate <NSObject>
@required
- (void)executer:(FixExecuter *)executer log:(NSString *)log;
@end

@interface FixExecuter : NSObject

@property (nonatomic, weak) id<FixExecuterDelegate> delegate;

- (void)fix:(CodeModel *)codeObject pod:(PodModel *)podObject;

@end
