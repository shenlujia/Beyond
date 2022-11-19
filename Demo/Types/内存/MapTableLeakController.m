//
//  MapTableLeakController.m
//  Beyond
//
//  Created by ZZZ on 2022/6/24.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import "MapTableLeakController.h"
#import "NSObject+SSJSON.h"

@interface SSTableTestObj : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong) NSHashTable *hashTable;
@property (nonatomic, strong) NSMapTable *mapTable;

@end

@implementation SSTableTestObj

- (void)dealloc
{
    printf("[%s] ~dealloc\n", _name.UTF8String);
}

+ (instancetype)createWithName:(NSString *)name
{
    printf("[%s] alloc\n", name.UTF8String);
    SSTableTestObj *ret = [[SSTableTestObj alloc] init];
    ret->_name = name;
    return ret;
}

- (NSString *)valueInfo
{
    if (self.hashTable) {
        NSInteger count = self.hashTable.count;
        NSArray *array = self.hashTable.allObjects;
        return [NSString stringWithFormat:@"hashTable count=%@ [%@]", @(count), [array componentsJoinedByString:@","]];
    }
    if (self.mapTable) {
        NSInteger count = self.mapTable.count;
        NSDictionary *dictionary = self.mapTable.dictionaryRepresentation;
        NSMutableArray *array = [NSMutableArray array];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array addObject:[NSString stringWithFormat:@"%@:%@", key, obj]];
        }];
        return [NSString stringWithFormat:@"mapTable count=%@ [%@]", @(count), [array componentsJoinedByString:@","]];
    }
    return @"";
}

- (void)printInfo
{
    printf("[%s] now: %s\n", self.name.UTF8String, [self valueInfo].UTF8String);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        printf("[%s] delay: %s\n", self.name.UTF8String, [self valueInfo].UTF8String);
    });
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<TestObject:%p>", self];
}

@end

static void test_hashTable(void)
{
    NSString *name = @"case0";
    SSTableTestObj *obj = [SSTableTestObj createWithName:name];
    obj.hashTable = [NSHashTable weakObjectsHashTable];
    [obj.hashTable addObject:obj];
    [obj printInfo];
}

static void test_mapTable(void)
{
    __block NSInteger index = 0;
    void (^test)(void (^setter)(SSTableTestObj *obj)) = ^(void (^setter)(SSTableTestObj *obj)) {
        NSString *name = [NSString stringWithFormat:@"case%@", @(++index)];
        SSTableTestObj *obj = [SSTableTestObj createWithName:name];
        if (setter) {
            setter(obj);
        }
        
        __unused NSObject *slice = [[NSClassFromString(@"NSSlice") alloc] init];
        __unused id slice_1 = [slice ss_keyValues];
        
       __unused NSValue *kk = [obj.mapTable valueForKey:@"keys"];
       __unused NSValue *vv = [obj.mapTable valueForKey:@"values"];
        
        __unused id kkk = [obj.mapTable ss_keyValues];
        
//        __unused id mm = [kk valueForKey:@"items"];
        
        [obj printInfo];
    };
    
//    test(^(SSTableTestObj *obj) {
//        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//        [obj.mapTable setObject:obj forKey:@(13)];
//    });
//
//    test(^(SSTableTestObj *obj) {
//        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//        [obj.mapTable setObject:obj forKey:@"text"];
//    });
//
//    test(^(SSTableTestObj *obj) {
//        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//        [obj.mapTable setObject:obj forKey:[[NSObject alloc] init]];
//    });
    
    test(^(SSTableTestObj *obj) {
        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
        [obj.mapTable setObject:obj forKey:[SSTableTestObj createWithName:@"weakKey1"]];
    });
    
//    test(^(SSTableTestObj *obj) {
//        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//    SSTableTestObj *other = [SSTableTestObj createWithName:@"other1"];
//        [obj.mapTable setObject:other forKey:@(13)];
//    });
    
//    test(^(SSTableTestObj *obj) {
//        obj.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//
//        SSTableTestObj *other = [SSTableTestObj createWithName:@"other2"];
//        other.mapTable = [NSMapTable weakToStrongObjectsMapTable];
//
//        SSTableTestObj *weakKey2 = [SSTableTestObj createWithName:@"weakKey2"];
//        [other.mapTable setObject:obj forKey:weakKey2];
//
//        SSTableTestObj *weakKey3 = [SSTableTestObj createWithName:@"weakKey3"];
//        [obj.mapTable setObject:other forKey:weakKey3];
//    });
}

@interface MapTableLeakController ()

@end

@implementation MapTableLeakController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"test_hashTable" tap:^(UIButton *button, NSDictionary *userInfo) {
        test_hashTable();
    }];

    [self test:@"test_mapTable" tap:^(UIButton *button, NSDictionary *userInfo) {
        test_mapTable();
    }];
}

@end
