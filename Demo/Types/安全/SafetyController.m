//
//  SafetyController.m
//  Demo
//
//  Created by SLJ on 2020/6/5.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SafetyController.h"
#import <dlfcn.h>
#import <sys/types.h>

id safety_createBtn(void)
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectZero];
    [btn setFrame:CGRectMake(200, 100, 100, 100)];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.layer.cornerRadius = 7.0f;
    btn.layer.masksToBounds = YES;
    return btn;
}
 
static id static_safety_createBtn(void)
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectZero];
    [btn setFrame:CGRectMake(50, 100, 100, 100)];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.layer.cornerRadius = 7.0f;
    btn.layer.masksToBounds = YES;
    return btn;
}

typedef struct safety_util_private {
    BOOL (*isVerified)(void);
    void (*resetPassword)(NSString *password);
} safety_util_t;
 
static BOOL _isVerified(void)
{
    NSLog(@"_isVerified");
    return YES;
}

static void _resetPassword(NSString *password)
{
    NSLog(@"_resetPassword %@", password);
}
 
@interface SafetyUtilEntry : NSObject

@end

@implementation SafetyUtilEntry

+ (safety_util_t *)shared
{
    static safety_util_t *instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = malloc(sizeof(safety_util_t));
        instance->isVerified = _isVerified;
        instance->resetPassword = _resetPassword;
    });
    return instance;
}

@end

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

@interface SafetyController ()

@end

@implementation SafetyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     首先，你可以尝试使用NSFileManager判断设备是否安装了如下越狱常用工具：
     /Applications/Cydia.app
     /Library/MobileSubstrate/MobileSubstrate.dylib
     /bin/bash
     /usr/sbin/sshd
     /etc/apt
     但是不要写成BOOL开关方法，给攻击者直接锁定目标hook绕过的机会
     +(BOOL)isJailbroken{
         if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
             return YES;
         }
         // ...
     }
     攻击者可能会改变这些工具的安装路径，躲过你的判断。

     那么，你可以尝试打开cydia应用注册的URL scheme：
     if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
          NSLog(@"Device is jailbroken");
     }
     但是不是所有的工具都会注册URL scheme，而且攻击者可以修改任何应用的URL scheme。

     那么，你可以尝试读取下应用列表，看看有无权限获取：
     if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
             NSLog(@"Device is jailbroken");
             NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/User/Applications/" error:nil];
             NSLog(@"applist = %@",applist);
     }
     越了狱的设备是可以获取到的
     
     攻击者可能会hook NSFileManager 的方法，让你的想法不能如愿。
     那么，你可以回避 NSFileManager，使用stat系列函数检测Cydia等工具：
     #import <sys/stat.h>
     void checkCydia(void) {
     struct stat stat_info;
     if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        NSLog(@"Device is jailbroken");
     }
     
     攻击者可能会利用 Fishhook原理 hook了stat。
     那么，你可以看看stat是不是出自系统库，有没有被攻击者换掉：
     #import <dlfcn.h>
     void checkInject(void) {
         int ret ;
         Dl_info dylib_info;
         int    (*func_stat)(const char *, struct stat *) = stat;
         if ((ret = dladdr(func_stat, &dylib_info))) {
             NSLog(@"lib :%s", dylib_info.dli_fname);
         }
     }
     如果结果不是 /usr/lib/system/libsystem_kernel.dylib 的话，那就100%被攻击了。
     如果 libsystem_kernel.dylib 都是被攻击者替换掉的……
     
     那也没什么可防的大哥你随便吧……
     那么，你可能会想，我该检索一下自己的应用程序是否被链接了异常动态库。
     列出所有已链接的动态库：
     
     #import <mach-o/dyld.h>
     void checkDylibs(void)
     {
         uint32_t count = _dyld_image_count();
         for (uint32_t i = 0 ; i < count; ++i) {
             NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
             NSLog(@"--%@", name);
         }
     }
     通常情况下，会包含越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib 。
     攻击者可能会给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库。
     那么，你可以通过检测当前程序运行的环境变量：
     void printEnv(void) {
         char *env = getenv("DYLD_INSERT_LIBRARIES");
         NSLog(@"%s", env);
     }
     未越狱设备返回结果是null，越狱设备就各有各的精彩了，尤其是老一点的iOS版本越狱环境。
     
     */
    
    [self test:@"disable_gdb" tap:^(UIButton *button, NSDictionary *userInfo) {
        // dlopen： 当path 参数为0是,他会自动查找 $LD_LIBRARY_PATH,$DYLD_LIBRARY_PATH, $DYLD_FALLBACK_LIBRARY_PATH 和 当前工作目录中的动态链接库.
        void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
        ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, "ptrace");
        ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
        dlclose(handle);
    }];
    
    [self test:@"方法使用函数指针替换" tap:^(UIButton *button, NSDictionary *userInfo) {
        [SafetyUtilEntry shared]->isVerified();
        [SafetyUtilEntry shared]->resetPassword(@"123");
    }];
    
    [self test:@"静态方法release会被裁剪符号" tap:^(UIButton *button, NSDictionary *userInfo) {
        /*
        如果函数属性为 static ，那么编译时该函数符号就会被解析为local符号。
        在发布release程序时（用Xcode打包编译二进制）默认会strip裁掉这些函数符号，无疑给逆向者加大了工作难度。
        */
        __unused id kk1 = safety_createBtn();
        __unused id kk2 = static_safety_createBtn();
    }];
    
    [self test:@"及时擦除数据" tap:^(UIButton *button, NSDictionary *userInfo) {
        // 对于敏感数据，我们不希望长时间放在内存中，而希望使用完后立即就被释放掉。
        // 但是不管是ARC还是MRC，自动释放池也有轮循工作周期，我们都无法控制内存数据被擦除的准确时间，让hackers们有机可乘。
        {
            NSString *text = [[NSString alloc]initWithFormat:@"SLJ %@", NSDate.date];
            NSLog(@"1. text = %@, length = %@", text, @(text.length));
            char *cstring = (char *)text.UTF8String;
            memset(cstring + 2, 0, text.length - 5);
            NSLog(@"2. text = %@, length = %@", text, @(text.length));
        }
        // data区的数据能改吗？来试试 会崩溃
        {
            NSString *text = @"SLJ";
            NSLog(@"text = %@", text);
            char *cstring = (char *)text.UTF8String;
            memset(cstring, 0, text.length);
            NSLog(@"final text = %@", text);
        }
    }];
}

@end
