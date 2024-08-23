//
//  SSDictionaryDiffUtil.m
//  Beyond
//
//  Created by ZZZ on 2024/8/23.
//  Copyright © 2024 SLJ. All rights reserved.
//

#import "SSDictionaryDiffUtil.h"
#import "NSArray+SS.h"
#import "NSDictionary+SS.h"
#import <Mantle/Mantle.h>

@interface KKKTestDiffModel : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *string_1;
@property (nonatomic) NSString *string2;
@property (nonatomic) NSNumber *number1;
@property (nonatomic) KKKTestDiffModel *obj_1;
@property (nonatomic) NSArray *array_1;

@end

@implementation KKKTestDiffModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"string_1"] = @"string_1";
    ret[@"string2"] = @"string_2";
    ret[@"number1"] = @"number_1";
    ret[@"obj_1"] = @"obj_1";
    ret[@"array_1"] = @"array_1";
    return ret;
}

+ (NSValueTransformer *)obj_1JSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[KKKTestDiffModel class]];
}

+ (NSValueTransformer *)array_1JSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[KKKTestDiffModel class]];
}

@end

@implementation SSDictionaryDiffUtil

+ (void)load
{
    // [self test];
}

+ (void)test
{
    {
        NSMutableDictionary *root = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"root_string_1";
            temp[@"string_2"] = @"root_string_2";
            temp;
        });
        NSMutableDictionary *obj_1 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_1_string_1";
            temp[@"string_2"] = @"obj_1_string_2";
            temp[@"number_1"] = @(11);
            temp;
        });
        NSMutableDictionary *obj_2 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_2_string_1";
            temp[@"string_2"] = @"obj_2_string_2";
            temp[@"number_1"] = @(12);
            temp;
        });
        NSMutableDictionary *obj_3 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_3_string_1";
            temp[@"string_2"] = @"obj_3_string_2";
            temp[@"number_1"] = @(13);
            temp;
        });
        root[@"obj_1"] = obj_1;
        root[@"array_1"] = @[obj_2, obj_3];
        
        KKKTestDiffModel *out_obj = [MTLJSONAdapter modelOfClass:[KKKTestDiffModel class] fromJSONDictionary:root error:nil];
        NSDictionary *out_dictionary = [MTLJSONAdapter JSONDictionaryFromModel:out_obj error:nil];
        NSArray *diffs = [self diff_keys:root other:out_dictionary];
        printf("case2: %ld", diffs.count);
    }
    
    {
        NSMutableDictionary *root = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"root_string_1";
            temp[@"string_2"] = @"root_string_2";
            temp[@"number_11"] = @(111111);
            temp;
        });
        NSMutableDictionary *obj_1 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_1_string_1";
            temp[@"string2errorkey"] = @"obj_1_string_2";
            temp[@"number_1"] = @(11);
            temp;
        });
        NSMutableDictionary *obj_2 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_2_string_1";
            temp[@"string_2"] = @"obj_2_string_2";
            temp[@"number_1"] = @(12);
            temp;
        });
        NSMutableDictionary *obj_3 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_3_string_1";
            temp[@"string_2"] = @"obj_3_string_2";
            temp[@"number1errorkey"] = @(13);
            temp;
        });
        NSMutableDictionary *obj_4 = ({
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            temp[@"string_1"] = @"obj_4_string_1";
            temp[@"string_2"] = @"obj_4_string_2";
            temp[@"number_1"] = @(14);
            temp;
        });
        root[@"obj_1"] = obj_1;
        root[@"array_1"] = @[obj_2, obj_3, obj_4];
        
        NSError *error1 = nil;
        KKKTestDiffModel *out_obj = [MTLJSONAdapter modelOfClass:[KKKTestDiffModel class] fromJSONDictionary:root error:&error1];
        NSError *error2 = nil;
        NSDictionary *out_dictionary = [MTLJSONAdapter JSONDictionaryFromModel:out_obj error:&error2];
        NSArray *diffs = [self diff_keys:root other:out_dictionary];
        printf("case2: %ld", diffs.count);
    }
}

+ (NSArray *)diff_keys:(NSDictionary *)original other:(NSDictionary *)other
{
    NSMutableArray *result = [NSMutableArray array];
    [self p_diff_keys:original other:other prefixes:@[] result:result];
    return result;
}

+ (void)p_diff_keys:(id)original other:(id)other prefixes:(NSArray *)prefixes result:(NSMutableArray *)result
{
    NSMutableArray *nonnull_prefixes = [NSMutableArray array];
    if (prefixes) {
        [nonnull_prefixes addObjectsFromArray:prefixes];
    }
    
    if (original != nil && other == nil) {
        NSString *full = [prefixes componentsJoinedByString:@"."];
        [result btd_addObject:full];
    } else if ([original isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic_1 = original;
        NSDictionary *dic_2 = [other isKindOfClass:[NSDictionary class]] ? other : nil;
        [dic_1 enumerateKeysAndObjectsUsingBlock:^(id key, id sub_value, BOOL *stop) {
            id other_value = [dic_2 btd_objectForKey:key];
            NSMutableArray *sub_prefixes = [nonnull_prefixes mutableCopy];
            [sub_prefixes btd_addObject:key];
            [self p_diff_keys:sub_value other:other_value prefixes:sub_prefixes result:result];
        }];
    } else if ([original isKindOfClass:[NSArray class]]) {
        NSArray *array_1 = original;
        NSArray *array_2 = [other isKindOfClass:[NSArray class]] ? other : nil;
        
        [array_1 enumerateObjectsUsingBlock:^(id sub_value, NSUInteger idx, BOOL *stop) {
            id other_value = [array_2 btd_objectAtIndex:idx];
            NSMutableArray *sub_prefixes = [nonnull_prefixes mutableCopy];
            [sub_prefixes btd_addObject:[NSString stringWithFormat:@"[%@]", @(idx)]];
            [self p_diff_keys:sub_value other:other_value prefixes:sub_prefixes result:result];
        }];
    }
}

@end
