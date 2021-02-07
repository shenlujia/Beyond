//
//  AWEClassUsageHelper.h
//  AWEAppConfigurations
//
//  Created by JinyDu on 2020/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWEClassUsageHelper : NSObject

@property (nonatomic, copy, readonly) NSDictionary *allClassInfo;

+ (instancetype)sharedInstance;
- (void)flashAllClass;
- (void)dumpToFile;

@end

NS_ASSUME_NONNULL_END
