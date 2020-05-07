//
//  ExerciseController.h
//  Demo
//
//  Created by SLJ on 2020/4/11.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BaseViewController.h"

@interface Father : NSObject

@end

@interface Son : Father

@end

@interface Student : NSObject

@property(nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;

@end

@interface Sark : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double fNum;
@property (nonatomic, strong) Student *myStudent;
@property (nonatomic, strong) NSNumber *age;

- (void)speak;

@end

@interface ExerciseController : BaseViewController

@end
