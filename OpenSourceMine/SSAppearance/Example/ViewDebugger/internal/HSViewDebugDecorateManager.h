//
//  HSViewDebugDecorateManager.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import <UIKit/UIKit.h>

@interface HSViewDebugDecorateManager : NSObject

- (void)decorate:(UIView *)view;
- (void)clean:(UIView *)view;
- (void)cleanAll;

@end
