//
//  PBXHeader.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBXGroupSourceTreeType) {
    PBXGroupSourceTreeTypeUnknown = 0,
    PBXGroupSourceTreeTypeGroup,
    PBXGroupSourceTreeType_SOURCE_ROOT,
    PBXGroupSourceTreeType_SDKROOT,
    PBXGroupSourceTreeType_BUILT_PRODUCTS_DIR
};

extern PBXGroupSourceTreeType PBXGroupSourceTreeTypeValue(NSString *string);

extern void PBXLogging(NSString *string);

@interface PBXHeader : NSObject

@end
