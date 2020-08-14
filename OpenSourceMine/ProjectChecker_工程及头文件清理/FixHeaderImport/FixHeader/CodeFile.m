//
//  CodeFile.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/3.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "CodeFile.h"
#import "CodeFileLine.h"

@interface CodeFile ()

@property (nonatomic, copy, readonly) NSDictionary<NSString *, CodeFileLine *> *dictionary;

@end

@implementation CodeFile

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = [path copy];
    }
    return self;
}

- (void)updateWithHeaders:(NSDictionary *)headers whiteListHeaders:(NSMutableSet *)whiteListHeaders
{
    NSData *data = [NSData dataWithContentsOfFile:self.path];
    if (data.length == 0) {
        return;
    }
    
    NSString *fileString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *components = [fileString componentsSeparatedByString:@"\n"];
    
    NSMutableArray *lineObjects = [NSMutableArray array];
    NSMutableSet *currentHeaders = [NSMutableSet set];
    [components enumerateObjectsUsingBlock:^(NSString *lineString, NSUInteger idx, BOOL *stop) {
        CodeFileLine *object = [[CodeFileLine alloc] initWithLine:lineString
                                                          headers:headers
                                                 whiteListHeaders:whiteListHeaders];
        if (object.header.length == 0) {
            // 不是import 直接添加行
            [lineObjects addObject:lineString];
        } else {
            if (![currentHeaders containsObject:object.header]) {
                [currentHeaders addObject:object.header];
                [lineObjects addObject:object];
            }
        }
    }];
    
    [lineObjects sortUsingComparator:^NSComparisonResult(CodeFileLine *obj1, CodeFileLine *obj2) {
        if (![obj1 isKindOfClass:[CodeFileLine class]] ||
            ![obj2 isKindOfClass:[CodeFileLine class]]) {
            return NSOrderedSame;
        }
        return [obj1.result compare:obj2.result];
    }];
    
    for (NSInteger idx = 0; idx < lineObjects.count; ++idx) {
        CodeFileLine *line = lineObjects[idx];
        if ([line isKindOfClass:[CodeFileLine class]]) {
            lineObjects[idx] = [line result];
        }
    }
    
    NSString *outString = [lineObjects componentsJoinedByString:@"\n"];
    NSData *outData = [outString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL status = [outData writeToFile:self.path atomically:YES];
    if (!status) {
        NSLog(@"WTF !!!");
    }
}

@end
