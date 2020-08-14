//
//  FileXibInfo.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "FileXibInfo.h"
#import "SSCommon.h"

@implementation FileXibOneItem

- (void)resetWithFile:(NSString *)file text:(NSString *)text xib:(NSString *)xib
{
    static NSCharacterSet *trimSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trimSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "];
    });
    
    _file = file;
    text = [text stringByTrimmingCharactersInSet:trimSet];
    _text = text;
    _xib = xib;
}

@end

@interface FileXibInfo ()

@property (nonatomic, copy, readonly) NSString *file;
@property (nonatomic, copy, readonly) NSString *name;

@end

@implementation FileXibInfo

- (instancetype)initWithPath:(NSString *)path
{
    self = [self init];
    if (self) {
        _path = path;
        _file = path.lastPathComponent;
        _name = [_file componentsSeparatedByString:@"."].firstObject;
        [self reset];
    }
    return self;
}

- (void)reset
{
    NSData *data = [NSData dataWithContentsOfFile:self.path];
    if (data.length == 0) {
        return;
    }
    
    NSString *fileString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableArray *xibs = [NSMutableArray array];
    
    NSArray *components = [fileString componentsSeparatedByString:@";"];
    for (NSString *one in components) {
        NSString *text = one;
        NSString *self_text = [NSString stringWithFormat:@"[%@ ", self.name];
        text = [text stringByReplacingOccurrencesOfString:@"[self " withString:self_text];
        text = [text stringByReplacingOccurrencesOfString:@"[super " withString:self_text];
        static NSCharacterSet *trimSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            trimSet = [NSCharacterSet characterSetWithCharactersInString:@"; "];
        });
        text = [text stringByTrimmingCharactersInSet:trimSet];
        
        if ([text hasSuffix:@"createViewFromXib]"] ||
            [text hasSuffix:@"createViewWithXib]"] ||
            [text hasSuffix:@"createFromXIB]"] ||
            [text hasSuffix:@"ViewWithXib]"]) {
            NSRange range = NSMakeRange(0, text.length);
            NSRange seperator = [text rangeOfString:@"[" options:NSBackwardsSearch range:range];
            if (seperator.location != NSNotFound) {
                NSString *right = [text substringFromIndex:seperator.location];
                FileXibOneItem *item = [[FileXibOneItem alloc] init];
                [item resetWithFile:self.file text:right xib:[SSCommon fixXibString:right]];
                [xibs addObject:item];
                continue;
            }
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"initWithNibName:" tail:@"bundle:"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"loadNibNamed:" tail:@"owner:"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"nibWithNibName:" tail:@"bundle:"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"UIStoryboard storyboardWithName:" tail:@"bundle:"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"registerNib:" tail:@"forCellReuseIdentifier"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        {
            NSSet *set = [SSCommon substrings:text head:@"registerNib:" tail:@"forHeaderFooterViewReuseIdentifier"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"registerNib:" tail:@"forCellWithReuseIdentifier"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        {
            NSSet *set = [SSCommon substrings:text head:@"registerNib:" tail:@"forSupplementaryViewOfKind"];
            [xibs addObjectsFromArray:[self fixSet:set]];
        }
        
        {
            NSSet *set = [SSCommon substrings:text head:@"createViewFromXibNamed:" tail:@"]"];
            if (set.count) {
                if (![text containsString:@"(instancetype)"]) {
                    [xibs addObjectsFromArray:[self fixSet:set]];
                }
            }
        }
    }
    
    _xibs = xibs;
}

- (NSArray *)fixSet:(NSSet *)set
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:set.count];
    for (NSString *text in set.allObjects) {
        NSString *temp = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        if ([temp isEqualToString:@"NSStringFromClass(self)"]) {
            NSString *to = [NSString stringWithFormat:@"%@.class", self.name];
            temp = [temp stringByReplacingOccurrencesOfString:@"self" withString:to];
        }
        FileXibOneItem *item = [[FileXibOneItem alloc] init];
        NSString *xib = [SSCommon fixXibString:temp];
        if ([xib isEqualToString:@"nil"] ||
            [xib isEqualToString:@"nibName"] ||
            [xib isEqualToString:@"(NSString *)xibName"] ||
            [xib isEqualToString:@"(NSString *_Nonnull)nibName"] ||
            [xib isEqualToString:@"nib"] ||
            [xib isEqualToString:@"cellNib"] ||
            [xib isEqualToString:@"nibNameOrNil"] ||
            [xib isEqualToString:@"(NSString *)nibNameOrNil"] ||
            [xib isEqualToString:@"(nullable NSString *)nibNameOrNil"] ||
            [xib isEqualToString:@"xibName"]) {
            continue;
        }
        [item resetWithFile:self.file text:text xib:xib];
        [ret addObject:item];
    }
    return ret;
}

@end
