//
//  TFBaseStorage.m
//  EHD
//
//  Created by admin on 2018/5/22.
//

#import "TFBaseStorage.h"

@interface TFBaseStorage ()

@property (nonatomic, weak) id <TFBaseStorageProtocol> protocol;

@property (nonatomic, strong, readonly) NSMutableDictionary *data;

@end

@implementation TFBaseStorage

#pragma mark - lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    
    self.protocol = (id)self;
    NSParameterAssert([self.protocol conformsToProtocol:@protocol(TFBaseStorageProtocol)]);
    
    [self p_load];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(notification_applicationWillResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(notification_applicationWillTerminate:)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
    
    return self;
}

- (NSMutableDictionary *)_storage
{
    NSString *identifier = [self.protocol storageIdentifier];
    if (identifier.length == 0) {
        identifier = @"COMMON";
    }
    NSMutableDictionary *ret = self.data[identifier];
    if (![ret isKindOfClass:[NSMutableDictionary class]]) {
        ret = [NSMutableDictionary dictionary];
        self.data[identifier] = ret;
    }
    return ret;
}

#pragma mark - notification

- (void)notification_applicationWillResignActive:(NSNotification *)notification
{
    [self p_synchronize];
}

- (void)notification_applicationWillTerminate:(NSNotification *)notification
{
    [self p_synchronize];
}

#pragma mark - private

- (void)p_load
{
    NSString *path = [self.protocol storagePath];

    @try {
        if (path.length) {
            _data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
    } @catch (NSException *exception) {
        // 可能app更新，解析失败
    }
    if (![_data isKindOfClass:[NSMutableDictionary class]]) {
        NSFileManager *manager = [[NSFileManager alloc] init];
        [manager removeItemAtPath:path error:nil];
        _data = [NSMutableDictionary dictionary];
    }
}

- (void)p_synchronize
{
    NSString *path = [self.protocol storagePath];
    
    if (path.length) {
        [NSKeyedArchiver archiveRootObject:self.data toFile:path];
    }
}

@end
