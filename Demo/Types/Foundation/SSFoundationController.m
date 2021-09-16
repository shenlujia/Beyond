//
//  SSFoundationController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/17.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSFoundationController.h"
#import <pthread.h>
#import "NSObject+SSJSON.h"
#import "MacroHeader.h"
#import "Logger.h"
#import "fishhook.h"
#import <KVOController/KVOController.h>

static int (*orig_printf)(const char *c, ...);

int my_printf(const char *c, ...)
{
    return 0;
}

@interface SSFoundationDEBUGLogStruct : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGAffineTransform trans;

@end

@implementation SSFoundationDEBUGLogStruct

- (instancetype)init
{
    self = [super init];
    if (self) {
        _point = CGPointMake(1, 2);
        _rect = CGRectMake(3, 4, 5, 6);
        _trans = CGAffineTransformMake(1, 2, 3, 4, 5, 6);
    }
    return self;
}

@end

@interface SSFoundationDEBUGLogBase : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *temp;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) bool b1;
@property (nonatomic, assign) bool b2;
@property (nonatomic, assign) BOOL b3;
@property (nonatomic, assign) char c1;
@property (nonatomic, assign) char c2;
@property (nonatomic, assign) Class cls1;
@property (nonatomic, assign) Class cls2;
@property (nonatomic, assign) SEL sel1;
@property (nonatomic, assign) SEL sel2;
@property (nonatomic, assign) char *cc1;
@property (nonatomic, assign) char *cc2;
@property (nonatomic, assign) double d1;
@property (nonatomic, assign) double d2;
@property (nonatomic, assign) float f1;
@property (nonatomic, assign) float f2;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation SSFoundationDEBUGLogBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        _b2 = YES;
        _b3 = YES;
        _c1 = 'X';
        _cc1 = "abcde";
        _cls1 = [self class];
        _sel1 = @selector(tapCount);
        _d1 = 1.2;
        _f1 = 2.4;
        _temp = @"text";
        _tag = 10;
        _rect = CGRectMake(1, 2, 3, 4);
        _block = ^{
            
        };
    }
    return self;
}

@end

@interface SSFoundationDEBUGLogA : SSFoundationDEBUGLogBase

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) id weak_self;

@end

@implementation SSFoundationDEBUGLogA

- (NSString *)description
{
    return @"SSFoundationDEBUGLogA";
}

@end

@interface SSFoundationDEBUGLogB : NSObject

@end

@implementation SSFoundationDEBUGLogB

- (NSString *)debugDescription
{
    return @"SSFoundationDEBUGLogB";
}

@end

@interface SSFoundationController ()

@property (nonatomic, strong) SSFoundationDEBUGLogBase *baseObj;

@end

@implementation SSFoundationController

- (void)viewDidLoad
{
    WEAKSELF
    [super viewDidLoad];

    [self testRegularExpression];

//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        rebind_symbols((struct rebinding[1]){{"printf", my_printf, (void *)&orig_printf}}, 1);
//    });
    
    [self test_c:@"FileManager"];
    
    [self test:@"NSLog崩溃" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *text0 = nil;
        NSString *text1 = nil;
        text0 = [NSString stringWithFormat:@"abc%@@f3", @"YES%"];
//        text0 = [NSString stringWithFormat:@"%@", @"YES%d"];
//        text0 = [NSString stringWithFormat:@"YES"];
        
        NSLog(@"text0=%@  text1=%@", text0, text1);
//        text1 = [[NSString alloc] initWithFormat:text0 arguments:nil];
        NSLog(@"text0=%@  text1=%@", text0, text1);
        NSLog(@"text0=%@  text1=%@", text0, text1, @"");
        
        NSLog(@"text0=%@  text1=%@", text0); // crash
    }];
    
    [self test:@"先将NSObject+DEBUGLog屏蔽 debugDescription用于控制台默认调用description" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        NSLog(@"%p", weak_s);
        NSLog(@"%@", weak_s);
        NSLog(@"%@", [weak_s description]);
        NSLog(@"%@", [weak_s debugDescription]);

        PRINT_BLANK_LINE
        SSFoundationDEBUGLogA *a = [[SSFoundationDEBUGLogA alloc] init];
        NSLog(@"%p", a);
        NSLog(@"%@", a);
        NSLog(@"%@", [a description]);
        NSLog(@"%@", [a debugDescription]);

        PRINT_BLANK_LINE
        SSFoundationDEBUGLogB *b = [[SSFoundationDEBUGLogB alloc] init];
        NSLog(@"%p", b);
        NSLog(@"%@", b);
        NSLog(@"%@", [b description]);
        NSLog(@"%@", [b debugDescription]);
    }];
    
    [self test:@"KVOController" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.baseObj = [[SSFoundationDEBUGLogBase alloc] init];
        [weak_s.KVOController observe:weak_s.baseObj keyPath:@"text" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSLog(@"%@", change);
        }];
        weak_s.baseObj.text = @"1";
        weak_s.baseObj.text = @"1";
        weak_s.baseObj.text = @"1";
        weak_s.baseObj.text = @"2";
        weak_s.baseObj.text = @"2";
        weak_s.baseObj.text = @"2";
    }];
    
    [self test:@"weak test NSHashTable NSMapTable" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSHashTable *t1 = [[NSHashTable alloc] init];
        NSHashTable *t2 = [NSHashTable weakObjectsHashTable];
        __unused BOOL tt1 = t1.pointerFunctions.usesWeakReadAndWriteBarriers;
        __unused BOOL tt2 = t2.pointerFunctions.usesWeakReadAndWriteBarriers;
        NSMapTable *m1 = [NSMapTable weakToWeakObjectsMapTable];
        NSMapTable *m2 = [NSMapTable weakToStrongObjectsMapTable];
        NSMapTable *m3 = [NSMapTable strongToWeakObjectsMapTable];
        NSMapTable *m4 = [NSMapTable strongToStrongObjectsMapTable];
        __unused BOOL mm1 = m1.keyPointerFunctions.usesWeakReadAndWriteBarriers;
        __unused BOOL mm2 = m2.keyPointerFunctions.usesWeakReadAndWriteBarriers;
        __unused BOOL mm3 = m3.keyPointerFunctions.usesWeakReadAndWriteBarriers;
        __unused BOOL mm4 = m4.keyPointerFunctions.usesWeakReadAndWriteBarriers;
        
        [[NSUserDefaults standardUserDefaults] setObject:@[@"1",@"2"] forKey:@"test_array"];
        __unused id kk = [[NSUserDefaults standardUserDefaults] objectForKey:@"test_array"];
        
        PRINT_BLANK_LINE
    }];
    
    [self test:@"ss_JSON" tap:^(UIButton *button, NSDictionary *userInfo) {
        {
            PRINT_BLANK_LINE
            SSFoundationDEBUGLogStruct *a = [[SSFoundationDEBUGLogStruct alloc] init];
            NSDictionary *value = [a ss_JSON];
            NSLog(@"%@", value);
        }
        {
            PRINT_BLANK_LINE
            SSFoundationDEBUGLogA *a = [[SSFoundationDEBUGLogA alloc] init];
            a.view = [[UIView alloc] init];
            a.weak_self = a;
            NSDictionary *value = [a ss_JSON];
            NSLog(@"%@", value);
        }
        {
            PRINT_BLANK_LINE
            id object = UIApplication.sharedApplication.delegate.window.rootViewController;
            NSDictionary *value = [object ss_JSON];
            NSLog(@"%@", value);
        }
        {
            PRINT_BLANK_LINE
            id object = UIApplication.sharedApplication.delegate;
            NSDictionary *value = [object ss_JSON];
            NSLog(@"%@", value);
        }
        {
            PRINT_BLANK_LINE
            UINavigationController *controller = (id)UIApplication.sharedApplication.delegate.window.rootViewController;
            NSLog(@"%@", [controller.topViewController ss_JSON]);
        }
    }];

    [self test:@"safe assert" tap:^(UIButton *button, NSDictionary *userInfo) {
        pthread_kill(pthread_self(), SIGINT);
    }];

    [self test:@"NSAssert" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSAssert(0, @"NSAssert test");
    }];

    [self test:@"NSCAssert" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSCAssert(0, @"NSCAssert test");
    }];

    [self test:@"NSException" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSArray *array = @[@(1), @(2), @(3)];
        [array objectAtIndex:10];
    }];

    [self test:@"fetchAssets" tap:^(UIButton *button, NSDictionary *userInfo) {
//        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
//        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
//        NSArray<NSSortDescriptor *> *sortDescriptor = @[
//            [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:YES]
//        ];
//        fetchOptions.sortDescriptors = sortDescriptor;
//        fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeiTunesSynced;
//        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithOptions:fetchOptions];
//        NSLog(@"fetchAssetsWithOptions %@", @(result.count));
    }];
}

- (void)testRegularExpression
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *string = [path stringByAppendingPathComponent:@"abc"];
    string = [string stringByAppendingPathComponent:@"slj.ok"];
    NSString *pattern = @"(Application/)[A-Za-z0-9-]{36}(/Documents)";

    __block NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return;
    }

    __block NSInteger toIndex = 0;
    [expression enumerateMatchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        *stop = YES;
        if (result) {
            toIndex = result.range.location + result.range.length;
        }
    }];
    if (0 < toIndex && toIndex < string.length) {
        NSParameterAssert(toIndex == path.length);
        NSLog(@"string = %@", string);
        NSLog(@"result = %@", [string substringToIndex:toIndex]);
    }
}

@end
