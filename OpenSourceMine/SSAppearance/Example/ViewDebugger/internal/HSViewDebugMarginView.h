//
//  HSViewDebugMarginView.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import <UIKit/UIKit.h>

@class HSViewDebugViewPosition;

@interface HSViewDebugMarginView : UIView

@property (nonatomic, copy, readonly) NSString *identifier;

+ (NSArray *)marginViewsWithPosition:(HSViewDebugViewPosition *)position;

@end
