//
//  MessageSendController.m
//  Beyond
//
//  Created by ZZZ on 2021/11/16.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MessageSendController.h"
#import "SSEasy.h"

@interface MessageSendClassA : NSObject

@end

@implementation MessageSendClassA

#define STRING_A(s) [NSString stringWithFormat:@"%@=%@", s, NSStringFromSelector(_cmd)]
#define STRING_B [NSString stringWithFormat:@"args=%@", args]
#define IMP_LOG(s) ss_easy_log_text([NSString stringWithFormat:@"%@\n%@\n", STRING_A(s), STRING_B])

- (void)obj_0
{
    NSString *args = [NSString stringWithFormat:@""];
    IMP_LOG(@"instanceSEL");
}

- (void)obj_a:(id)a
{
    NSString *args = [NSString stringWithFormat:@"%@", a];
    IMP_LOG(@"instanceSEL");
}

- (void)obj_a:(id)a b:(id)b
{
    NSString *args = [NSString stringWithFormat:@"%@,%@", a, b];
    IMP_LOG(@"instanceSEL");
}

- (void)obj_a:(id)a b:(id)b c:(id)c
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@", a, b, c];
    IMP_LOG(@"instanceSEL");
}

- (void)obj_a:(id)a b:(id)b c:(id)c d:(id)d
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@,%@", a, b, c, d];
    IMP_LOG(@"instanceSEL");
}

- (void)obj_a:(id)a b:(id)b c:(id)c d:(id)d e:(id)e
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@,%@,%@", a, b, c, d, e];
    IMP_LOG(@"instanceSEL");
}

+ (void)cls_0
{
    NSString *args = [NSString stringWithFormat:@""];
    IMP_LOG(@"classSEL");
}

+ (void)cls_a:(id)a
{
    NSString *args = [NSString stringWithFormat:@"%@", a];
    IMP_LOG(@"classSEL");
}

+ (void)cls_a:(id)a b:(id)b
{
    NSString *args = [NSString stringWithFormat:@"%@,%@", a, b];
    IMP_LOG(@"classSEL");
}

+ (void)cls_a:(id)a b:(id)b c:(id)c
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@", a, b, c];
    IMP_LOG(@"classSEL");
}

+ (void)cls_a:(id)a b:(id)b c:(id)c d:(id)d
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@,%@", a, b, c, d];
    IMP_LOG(@"classSEL");
}

+ (void)cls_a:(id)a b:(id)b c:(id)c d:(id)d e:(id)e
{
    NSString *args = [NSString stringWithFormat:@"%@,%@,%@,%@,%@", a, b, c, d, e];
    IMP_LOG(@"classSEL");
}

@end

@implementation MessageSendController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        MessageSendClassA *o = [[MessageSendClassA alloc] init];
        ss_easy_objc_call(o, @"obj_0", @[]);
        ss_easy_objc_call(o, @"obj_a:", @[@"a"]);
        ss_easy_objc_call(o, @"obj_a:b:", @[@"a",@"b"]);
        ss_easy_objc_call(o, @"obj_a:b:c:", @[@"a",@"b",@"c"]);
        ss_easy_objc_call(o, @"obj_a:b:c:d:", @[@"a",@"b",@"c",@"d"]);
        ss_easy_objc_call(o, @"obj_a:b:c:d:e:", @[@"a",@"b",@"c",@"d",@"e"]);
        ss_easy_objc_call(o, @"obj_a:b:c:d:e:", @[@"a",[NSNull null],@"c"]);
    }
    {
        Class o = [MessageSendClassA class];
        ss_easy_objc_call(o, @"cls_0", @[]);
        ss_easy_objc_call(o, @"cls_a:", @[@"a"]);
        ss_easy_objc_call(o, @"cls_a:b:", @[@"a",@"b"]);
        ss_easy_objc_call(o, @"cls_a:b:c:", @[@"a",@"b",@"c"]);
        ss_easy_objc_call(o, @"cls_a:b:c:d:", @[@"a",@"b",@"c",@"d"]);
        ss_easy_objc_call(o, @"cls_a:b:c:d:e:", @[@"a",@"b",@"c",@"d",@"e"]);
        ss_easy_objc_call(o, @"cls_a:b:c:d:e:", @[@"a",[NSNull null],@"c"]);
    }
}

@end
