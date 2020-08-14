//
//  Person.h
//  HSKVO
//
//  Created by shenlujia on 2016/1/7.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Engine : NSObject

@property (nonatomic, copy) NSString *power;
@property (nonatomic, copy) NSString *weight;

@end

@interface Car : NSObject

@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, strong) Engine *engine;

@end

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Car *car;
@property (nonatomic, strong) NSMutableArray *userInfo;

@end
