//
//  SSCommon.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "SSCommon.h"

static NSString * const kSSErrorDomain = @"SSErrorDomain";

@implementation SSCommon

+ (NSError *)errorWithError:(NSError *)error description:(NSString *)description
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (error) {
        if (error.userInfo) {
            [userInfo addEntriesFromDictionary:error.userInfo];
        }
        userInfo[@"originalDomain"] = error.domain;
        userInfo[@"originalCode"] = @(error.code);
    }
    userInfo[@"description"] = description;
    return [NSError errorWithDomain:kSSErrorDomain code:-1 userInfo:userInfo];
}

+ (NSString *)substring:(NSString *)text
                   head:(NSString *)head
                   tail:(NSString *)tail
{
    NSRange r = NSMakeRange(0, text.length);
    return [self substring:text
                      head:head
              containsHead:NO
                      tail:tail
              containsTail:NO
                     range:r
                  outRange:nil];
}

+ (NSString *)substring:(NSString *)text
                   head:(NSString *)head
           containsHead:(BOOL)containsHead
                   tail:(NSString *)tail
           containsTail:(BOOL)containsTail
                  range:(NSRange)range
               outRange:(NSRange *)outRange
{
    NSString *ret = nil;
    NSRange retRange = NSMakeRange(NSNotFound, 0);
    
    do {
        if (text.length == 0 || head.length == 0 || tail.length == 0) {
            break;
        }
        
        NSRange headRange = [text rangeOfString:head options:NSLiteralSearch range:range];
        if (headRange.location == NSNotFound) {
            break;
        }
        
        NSRange searchRange = NSMakeRange(NSMaxRange(headRange), NSMaxRange(range) - NSMaxRange(headRange));
        NSRange tailRange = [text rangeOfString:tail options:NSLiteralSearch range:searchRange];
        if (tailRange.location == NSNotFound) {
            break;
        }
        
        NSInteger start = containsHead ? headRange.location : NSMaxRange(headRange);
        NSInteger end = containsTail ? NSMaxRange(tailRange) : tailRange.location;
        retRange = NSMakeRange(start, end - start);
        ret = [text substringWithRange:retRange];
        
    } while (NO);
    
    if (outRange) {
        *outRange = retRange;
    }
    return ret;
}

+ (NSMutableSet *)substrings:(NSString *)text
                        head:(NSString *)head
                containsHead:(BOOL)containsHead
                        tail:(NSString *)tail
                containsTail:(BOOL)containsTail
{
    NSMutableSet *ret = [NSMutableSet set];
    
    NSRange range = NSMakeRange(0, text.length);
    NSRange outRange = NSMakeRange(0, 0);
    
    while (YES) {
        range = NSMakeRange(NSMaxRange(outRange), NSMaxRange(range) - NSMaxRange(outRange));
        NSString *content = [SSCommon substring:text
                                           head:head
                                   containsHead:containsHead
                                           tail:tail
                                   containsTail:containsTail
                                          range:range
                                       outRange:&outRange];
        if (content.length == 0 || outRange.location == NSNotFound) {
            break;
        }
        [ret addObject:content];
    }
    
    return ret;
}

+ (NSMutableSet *)substrings:(NSString *)text head:(NSString *)head tail:(NSString *)tail
{
    return [self substrings:text head:head containsHead:NO tail:tail containsTail:NO];
}

+ (NSString *)fixXibString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    // @"AAAAAA"
    if ([string hasPrefix:@"@\""] && [string hasSuffix:@"\""]) {
        string = [string stringByReplacingOccurrencesOfString:@"@" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        return string;
    }
    
    // AAAAAA.viewNib  AAAAAA.htuc_viewWithNib
    if ([string hasSuffix:@"viewNib"] ||
        [string hasSuffix:@"viewWithNib"]) {
        return [string componentsSeparatedByString:@"."].firstObject;
    }
    
    // [UINib htuc_nibNamed:AAAAAA]
    // [UINib nibWithNibName:AAAAAA bundle:nil]
    // [UINib htuc_nibNamed:NSStringFromClass([AAAAAA class])]
    if ([string hasPrefix:@"[UINib "]) {
        NSString *temp = [string componentsSeparatedByString:@"bundle:"].firstObject;
        NSArray *array = [temp componentsSeparatedByString:@":"];
        if (array.count == 2) {
            temp = [array[1] stringByReplacingOccurrencesOfString:@"]" withString:@""];
            return [self fixXibString:temp];
        }
    }
    
    // [AAAAAA viewNib]  [AAAAAA createViewFromXib]
    if ([string hasPrefix:@"["] && [string hasSuffix:@"]"]) {
        NSString *temp = string;
        if ([temp hasSuffix:@"viewNib]"] ||
            [temp hasSuffix:@"viewWithNib]"] ||
            [temp hasSuffix:@"createViewFromXib]"] ||
            [temp hasSuffix:@"createViewWithXib]"] ||
            [temp hasSuffix:@"createFromXIB]"] ||
            [temp hasSuffix:@"ViewWithXib]"]) {
            temp = [temp componentsSeparatedByString:@" "].firstObject;
            temp = [temp stringByReplacingOccurrencesOfString:@"[" withString:@""];
            return [temp stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }
    }
    
    // NSStringFromClass(AAAAAA.class)  NSStringFromClass([AAAAAA class])
    if ([string hasPrefix:@"NSStringFromClass"]) {
        NSString *temp = [SSCommon substring:string head:@"(" tail:@")"];
        if (temp.length) {
            temp = [temp stringByReplacingOccurrencesOfString:@"[" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"]" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"." withString:@" "];
            return [temp componentsSeparatedByString:@" "].firstObject;
        }
    }
    
    return string;
}

+ (NSString *)trimString:(NSString *)string
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n\t "];
    return [string stringByTrimmingCharactersInSet:characterSet];
}

+ (NSSet *)contentsAtPath:(NSString *)path extensions:(NSSet *)extensions
{
    NSMutableSet *ret = [NSMutableSet set];
    NSFileManager *manager = NSFileManager.defaultManager;
    for (NSString *name in [manager contentsOfDirectoryAtPath:path error:nil]) {
        if ([name hasPrefix:@"."]) {
            continue;
        }
        NSString *subpath = [path stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        if (![manager fileExistsAtPath:subpath isDirectory:&isDirectory]) {
            continue;
        }
        if (isDirectory) {
            NSSet *temp = [self contentsAtPath:subpath extensions:extensions];
            [ret addObjectsFromArray:temp.allObjects];
            continue;
        }
        NSString *extension = name.pathExtension;
        if (extension.length && [extensions containsObject:extension]) {
            [ret addObject:subpath];
        }
    }
    return ret;
}

@end
