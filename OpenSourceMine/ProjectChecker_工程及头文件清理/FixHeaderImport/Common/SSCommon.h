//
//  SSCommon.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCommon : NSObject

+ (NSError *)errorWithError:(NSError *)error description:(NSString *)description;

+ (NSString *)substring:(NSString *)text
                   head:(NSString *)head
                   tail:(NSString *)tail;

+ (NSString *)substring:(NSString *)text
                   head:(NSString *)head
           containsHead:(BOOL)containsHead
                   tail:(NSString *)tail
           containsTail:(BOOL)containsTail
                  range:(NSRange)range
               outRange:(NSRange *)outRange;

+ (NSMutableSet *)substrings:(NSString *)text
                        head:(NSString *)head
                containsHead:(BOOL)containsHead
                        tail:(NSString *)tail
                containsTail:(BOOL)containsTail;

+ (NSMutableSet *)substrings:(NSString *)text head:(NSString *)head tail:(NSString *)tail;

+ (NSString *)fixXibString:(NSString *)string;

+ (NSString *)trimString:(NSString *)string;

+ (NSSet *)contentsAtPath:(NSString *)path extensions:(NSSet *)extensions;

@end
