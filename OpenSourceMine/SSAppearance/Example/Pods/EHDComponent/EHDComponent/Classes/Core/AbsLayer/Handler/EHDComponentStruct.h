//
//  EHDComponentStruct.h
//  Pods
//
//  Created by luohs on 2017/11/16.
//
//

#import <Foundation/Foundation.h>

@interface EHDComponentStruct : NSObject
@property (nonatomic, copy)   NSString  *componentName;
@property (nonatomic, assign) Class     componentClass;
@property (nonatomic, assign) SEL       componentSelector;
@end
