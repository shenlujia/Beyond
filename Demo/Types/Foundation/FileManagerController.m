//
//  FileManagerController.m
//  Beyond
//
//  Created by ZZZ on 2021/9/15.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "FileManagerController.h"
#import "NSFileManager+SS.h"
#import "SSDEBUGTextViewController.h"

@interface FileManagerController ()

@end

@implementation FileManagerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"file_manager_test"];
    
    NSArray * (^all_simple_contents)(void) = ^NSArray * {
        NSError *error = nil;
        NSArray *contents = [[NSFileManager defaultManager] acc_contentsAtPath:path error:&error];
        NSMutableArray *prints = [NSMutableArray array];
        for (NSString *content in contents) {
            NSRange range = [content rangeOfString:path];
            if (range.location != NSNotFound) {
                [prints addObject:[content stringByReplacingCharactersInRange:range withString:@""]];
            }
        }
        [prints sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        return prints;
    };
    
    [self test:@"创建一些文件" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:path error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *subpath = [path stringByAppendingPathComponent:@"0abc"];
        [manager createDirectoryAtPath:subpath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *subsubpath = [subpath stringByAppendingPathComponent:@"0def"];
        [manager createDirectoryAtPath:subsubpath withIntermediateDirectories:YES attributes:nil error:nil];
        {
            NSString *s1 = @"1aa";
            [s1 writeToFile:[path stringByAppendingPathComponent:@"1a.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSString *s2 = @"2bb";
            [s2 writeToFile:[path stringByAppendingPathComponent:@"2b.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        {
            NSString *s1 = @"11cc";
            [s1 writeToFile:[subpath stringByAppendingPathComponent:@"11c.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSString *s2 = @"22dd";
            [s2 writeToFile:[subpath stringByAppendingPathComponent:@"22d.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        {
            NSString *s1 = @"111ee";
            [s1 writeToFile:[subsubpath stringByAppendingPathComponent:@"111e.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSString *s2 = @"222ff";
            [s2 writeToFile:[subsubpath stringByAppendingPathComponent:@"222f.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
    
    [self test:@"列举文件夹下所有文件" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSArray *prints = all_simple_contents();
        [SSDEBUGTextViewController showText:[prints componentsJoinedByString:@"\n"]];
    }];
    
    [self test:@"拷贝文件夹 测试是否全部被拷贝" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *toPath = [documentPath stringByAppendingPathComponent:@"tooo_path"];
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:nil];
    }];
    
    [self test:@"检测路径中带a" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSMutableArray *prints = [all_simple_contents() mutableCopy];
        for (NSString *s in [prints copy]) {
            if (![s containsString:@"a"]) {
                [prints removeObject:s];
            }
        }
        [SSDEBUGTextViewController showText:[prints componentsJoinedByString:@"\n"]];
    }];
    
    [self test:@"检测路径中带b" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSMutableArray *prints = [all_simple_contents() mutableCopy];
        for (NSString *s in [prints copy]) {
            if (![s containsString:@"b"]) {
                [prints removeObject:s];
            }
        }
        [SSDEBUGTextViewController showText:[prints componentsJoinedByString:@"\n"]];
    }];
    
    [self test:@"trim自定义对象" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSDictionary *a = @{@"1":@"2",@"a":@"1",@"3":@"a"};
        NSArray *b = @[@"a",@"b",@"c",a,a];
        NSDictionary *c = @{@"a":b,@"1":b,@"c":@"d"};
        NSMutableArray *result = [NSMutableArray array];
        [FileManagerController p_trimObject:c draftID:@"a" prefix:nil result:result];
        [SSDEBUGTextViewController showJSONObject:result];
    }];
}

+ (NSString *)p_trimPath:(NSString *)path draftID:(NSString *)draftID
{
    return path;
}

+ (id)p_trimObject:(id)object draftID:(NSString *)draftID prefix:(NSString *)prefix result:(NSMutableArray *)result
{
    if (draftID.length == 0) {
        return object;
    }
    
    NSString * (^join)(NSString *) = ^NSString * (NSString *text) {
        if (!prefix) {
            return text;
        }
        return [NSString stringWithFormat:@"%@%@%@", prefix, @" -> ", text];
    };
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *text = object;
        text = [self p_trimPath:text draftID:draftID];
        text = [text stringByReplacingOccurrencesOfString:draftID withString:@"[DRAFTID]"];
        text = join(text);
        [result addObject:text];
        return text;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        for (id item in object) {
            [self p_trimObject:item draftID:draftID prefix:join(@"NSArray") result:result];
        }
        return object;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *fixedKey = [self p_trimObject:key draftID:draftID prefix:prefix result:nil];
            [self p_trimObject:obj draftID:draftID prefix:join(fixedKey) result:result];
        }];
        return object;
    }
    
    [result addObject:object];
    return object;
}

@end
