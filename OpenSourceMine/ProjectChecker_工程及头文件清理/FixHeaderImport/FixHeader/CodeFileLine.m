//
//  CodeFileLine.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/3.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "CodeFileLine.h"

@interface CodeFileLine ()

@end

@implementation CodeFileLine

- (instancetype)initWithLine:(NSString *)line
                     headers:(NSDictionary *)headers
            whiteListHeaders:(NSMutableSet *)whiteListHeaders
{
    self = [super init];
    if (self) {
        [self resetWithLine:line headers:headers whiteListHeaders:whiteListHeaders];
    }
    return self;
}

- (void)resetWithLine:(NSString *)line
              headers:(NSDictionary *)headers
     whiteListHeaders:(NSMutableSet *)whiteListHeaders
{
    _lineString = line;
    NSString *toReplaceText = line;
    
    NSCharacterSet *characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    NSString *trimText = [toReplaceText stringByTrimmingCharactersInSet:characterSet];
    
    if ([trimText hasPrefix:@"'#import"]) {
        toReplaceText = [self substringWithString:trimText from:@"'" to:@"'"];
        trimText = [trimText stringByReplacingOccurrencesOfString:@"'" withString:@""];
        trimText = [trimText stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    NSString *noSpaceLine = [trimText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![noSpaceLine hasPrefix:@"#import"]) {
        return;
    }
    
    BOOL maybeOK = NO;
    _header = ({
        NSArray *components = [noSpaceLine componentsSeparatedByString:@"import"];
        NSString *text = components.lastObject;
        text = [text stringByReplacingOccurrencesOfString:@"<" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@">" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        components = [text componentsSeparatedByString:@"/"];
        maybeOK = components.count > 1;
        components.lastObject;
    });
    if (self.header.length == 0) {
        return;
    }
    
    NSString *recommendedText = ({
        NSString *from = @"<";
        NSString *to = @">";
        NSString *content = [self substringWithString:noSpaceLine from:from to:to];
        if (content.length == 0) {
            from = @"\"";
            to = @"\"";
            content = [self substringWithString:noSpaceLine from:from to:to];
        }
        NSString *ret = nil;
        if (content.length) {
            ret = [NSString stringWithFormat:@"#import %@%@%@", from, content, to];
        }
        ret;
    });
    
    NSString *to = nil;
    if (maybeOK == NO && ![whiteListHeaders containsObject:self.header.lowercaseString]) {
        to = headers[self.header.lowercaseString];
    }
    if (to.length == 0) {
        to = recommendedText;
    }
    if (to.length) {
        _result = [line stringByReplacingOccurrencesOfString:toReplaceText withString:to];
    }
}

- (NSString *)substringWithString:(NSString *)string from:(NSString *)from to:(NSString *)to
{
    if (string.length == 0 || from.length == 0 || to.length == 0) {
        return nil;
    }
    
    NSRange r0 = [string rangeOfString:from];
    NSRange r1 = [string rangeOfString:to options:NSBackwardsSearch];
    if (r0.location != NSNotFound && r1.location != NSNotFound) {
        NSRange range = NSMakeRange(NSMaxRange(r0), r1.location - NSMaxRange(r0));
        return [string substringWithRange:range];
    }
    
    return nil;
}

@end
