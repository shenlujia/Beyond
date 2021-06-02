//
//  DontLikeCommon.h
//  Demo
//
//  Created by SLJ on 2020/8/24.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DontLikeCommon : NSObject

@end

extern CGSize calcTextSize(CGSize fitsSize, id text, NSInteger numberOfLines, UIFont *font, NSTextAlignment textAlignment, NSLineBreakMode lineBreakMode, CGFloat minimumScaleFactor, CGSize shadowOffset);

extern CGSize calcTextSizeV2(CGSize fitsSize, id text, NSInteger numberOfLines, UIFont *font);

extern void ss_connect_add(id object, NSObject *value);
extern void ss_connect_remove(id object, NSObject *value);
extern void ss_connect_cleanup(id object);
