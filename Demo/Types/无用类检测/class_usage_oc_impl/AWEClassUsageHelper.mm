//
//  AWEClassUsageHelper.m
//  AWEAppConfigurations
//
//  Created by JinyDu on 2020/6/2.
//
#import "objc_class_detail.h"
#import "AWEClassUsageHelper.h"
#import <objc/runtime.h>
#import <sys/time.h>

extern uint64_t KVAGetCurrentTime(void);
#define TIK(__salt) CFTimeInterval __salt##startTime = (CFTimeInterval)KVAGetCurrentTime();

#define TOK(__salt) ({\
CFTimeInterval __salt##endTime = (CFTimeInterval)KVAGetCurrentTime(); \
CFTimeInterval dur = (__salt##endTime - __salt##startTime);\
dur;\
})

uint64_t KVAGetCurrentTime()
{
    struct timeval current;
    int ret;
    ret = gettimeofday(&current, nullptr);
    return (uint64_t)(ret == 0 ? current.tv_sec * 1000000 + current.tv_usec : 0);
}


@interface AWEClassUsageHelper()
@property (nonatomic, assign, getter=isFlashing) BOOL flashing;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) dispatch_queue_t serialqueue;
@end

@implementation AWEClassUsageHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static AWEClassUsageHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[AWEClassUsageHelper alloc] init];
    });
    return helper;
}


- (dispatch_queue_t)serialqueue
{
    if (!_serialqueue) {
        _serialqueue = dispatch_queue_create("com.aweme.classusage", DISPATCH_QUEUE_SERIAL);
    }
    return _serialqueue;
}

- (void)flashAllClass
{
    dispatch_async(self.serialqueue, ^{
        if (self.isFlashing) {return;}
        [self p_flashAllClass];
    });
}

- (void)p_flashAllClass
{
    _flashing = YES;
    TIK(Class_FLash)//打点时间统计
    const char *imageName = class_getImageName([AWEClassUsageHelper class]);
    unsigned int count = 0;
    const char **classes  = objc_copyClassNamesForImage(imageName, &count);
    self.count = count;
    NSLog(@"Amount of classes: %d", self.count);
    NSMutableDictionary *m_clzes_info = @{}.mutableCopy;
    int initCnt = 0;
    for (int i = 0; i < self.count; i++) {
        V_Class clz = (__bridge V_Class)objc_getClass(classes[i]);
        NSString *clzName = [NSString stringWithUTF8String:classes[i]];
        NSMutableArray *inherit_lst = @[].mutableCopy;
        V_Class sup = clz->superclass;
        while(sup){
            NSString *sup_cls_name = NSStringFromClass((__bridge Class) sup);
            if (sup_cls_name){
                [inherit_lst addObject:sup_cls_name];
            }
            sup = sup->superclass;
        }
        bool isInit = clz->isInitialized();
        int32_t flags = clz->meta_flag();
        m_clzes_info[clzName] = @{
            @"isInit":@(isInit),
            @"inherit_lst":inherit_lst.copy,
            @"meta_flags":@((unsigned long)flags),
        };
        if(isInit){ ++initCnt; }
    }
    free(classes);
    NSTimeInterval tm_µs =  TOK(Class_FLash);
    _allClassInfo = @{
        @"classes":m_clzes_info.copy,
        @"class_cnt":@(self.count),
        @"interval_µs":@(tm_µs),
        @"init_cnt":@(initCnt)
    };
    _flashing = NO;
    [self dumpToFile];
}

+ (NSString *)defaultDumpPath
{
    static NSString *p_folder_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *pathDocuments =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory =[pathDocuments objectAtIndex:0];

        //目标存储的目录
        p_folder_path = [documentsDirectory stringByAppendingPathComponent:@"class_info"];
    });
    
    return p_folder_path;
}

- (void)dumpToFile
{
    NSError *error;
    if (!self.allClassInfo){
        NSLog(@"Please flash all class first");
        return;
    }

    //创建文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:[AWEClassUsageHelper defaultDumpPath]
                             withIntermediateDirectories:YES
                                              attributes:@{NSFileProtectionKey : NSFileProtectionNone}
                                                   error:&error];
    if (error != nil) {
      NSLog(@"error creating directory: %@", error);
      [[NSFileManager defaultManager] removeItemAtPath:[AWEClassUsageHelper defaultDumpPath] error:nil];
    }
    
    //设置一些文件夹额外控制项，防止iOS系统在写入时候出现问题
    NSURL *folderURL = [NSURL fileURLWithPath:[AWEClassUsageHelper defaultDumpPath]];
    [folderURL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
    
    unsigned long long timstamp = [[NSDate date] timeIntervalSince1970]* 1000;
    NSString *fileName = [NSString stringWithFormat:@"class_info_%@.json", @(timstamp).stringValue];
    NSString *jsonFilePath = [[AWEClassUsageHelper defaultDumpPath] stringByAppendingPathComponent:fileName];
    NSData *data = [AWEClassUsageHelper p_jsonDataWithDict:self.allClassInfo prettyPrint:YES];
    if (data){
        [data writeToFile:jsonFilePath atomically:YES];
    }
}

+ (NSData *)p_jsonDataWithDict:(NSDictionary *)dic prettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                  options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                    error:&error];
    return jsonData;
}


@end
