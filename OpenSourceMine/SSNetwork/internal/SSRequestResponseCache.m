//
//  SSRequestResponseCache.m
//  Pods
//
//  Created by shenlujia on 2017/8/16.
//
//

#import "SSRequestResponseCache.h"

@implementation SSRequestResponseCache
{
    NSLock *memoryCacheLock;
    NSMutableDictionary *memoryCache;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    
    memoryCacheLock = [[NSLock alloc] init];
    memoryCache = [NSMutableDictionary dictionary];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidReceiveMemoryWarning)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    
    return self;
}

+ (nonnull instancetype)sharedCache
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)cacheForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    id object = nil;
    [memoryCacheLock lock];
    object = memoryCache[key];
    [memoryCacheLock unlock];
    return object;
}

- (void)setCache:(id)cache forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    
    [memoryCacheLock lock];
    memoryCache[key] = cache;
    [memoryCacheLock unlock];
}

- (void)cleanup
{
    [memoryCacheLock lock];
    [memoryCache removeAllObjects];
    [memoryCacheLock unlock];
}

- (void)applicationDidReceiveMemoryWarning
{
    [self cleanup];
}

@end
