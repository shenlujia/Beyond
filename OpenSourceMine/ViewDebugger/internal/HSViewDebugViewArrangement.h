//
//  HSViewDebugViewArrangement.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import <Foundation/Foundation.h>

@class HSViewDebugViewPosition;

@interface HSViewDebugViewArrangement : NSObject

@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, copy, readonly) NSArray<HSViewDebugViewPosition *> *subviewPositions;

- (instancetype)initWithView:(UIView *)view;

@end
