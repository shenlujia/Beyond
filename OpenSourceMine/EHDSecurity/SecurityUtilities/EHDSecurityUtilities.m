//
//  EHDSecurityUtilities.m
//  EHDSecurity
//
//  Created by luohs on 2018/10/17.
//

#import "EHDSecurityUtilities.h"
#include <dlfcn.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/stat.h>
#include <string.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>

#pragma mark - anti 调试
int ehd_debuged(void)
{
    int name[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc kproc;
    size_t kproc_size = sizeof(kproc);
    memset((void*)&kproc, 0, kproc_size);
    if (sysctl(name, 4, &kproc, &kproc_size, NULL, 0) == -1) {
        exit(-1);
    }
    return ((kproc.kp_proc.p_flag & P_TRACED) != 0);
}

void ehd_invalidGDB(void)
{
    void *handle;
    typedef int (*ptrace_ptr)(int request, pid_t pid, caddr_t addr, int data);
    handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr p_ptr = dlsym(handle, "ptrace");
    p_ptr(31, 0, 0, 0);
    dlclose(handle);
}

#pragma mark - anti 越狱&注入
int ehd_checkEnv(void)
{
    //检测当前程序运行的环境变量,如果返回不为NULL,则可能被越狱
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    if (env != NULL) {
        return 1;
    }
    return 0;
}

int ehd_checkInject(void)
{
    int ret ;
    Dl_info dylib_info;
    int    (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSLog(@"lib :%s", dylib_info.dli_fname);
        if (strcmp("/usr/lib/system/libsystem_kernel.dylib", dylib_info.dli_fname) != 0){
            return 1;
        }
    }
    
    return 0;
}


const char* jailbreak_tools[] = {
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    "/Applications/Absinthe.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt",
    "/private/var/lib/apt/",
    NULL,
};

int ehd_checkCydia(void)
{
    struct stat stat_info;
    for (int i=0; i<sizeof(jailbreak_tools)/sizeof(jailbreak_tools[0]); i++) {
        if (0 == stat(jailbreak_tools[i], &stat_info)) {
            NSLog(@"Device is installed with %s", jailbreak_tools[i]);
            return 1;
        }
    }
    return 0;
}

int ehd_jailbreak(void)
{
    if (ehd_checkCydia() !=0) return 1;
    if (ehd_checkInject() !=0) return 1;
    if (ehd_checkEnv() !=0) return 1;
    return 0;
}

#pragma mark - anti 砸壳
int ehd_binaryEncrypted(void)
{
    // checking current binary's LC_ENCRYPTION_INFO
    const void *binaryBase = NULL;
    struct load_command *machoCmd = NULL;
    const struct mach_header *machoHeader = NULL;

    NSString *path = [[NSBundle mainBundle] executablePath];
    NSData *filedata = [NSData dataWithContentsOfFile:path];
    binaryBase = (char *)[filedata bytes];
    machoHeader = (const struct mach_header *)binaryBase;
    
    if(machoHeader->magic == FAT_CIGAM)
    {
        unsigned int offset = 0;
        struct fat_arch *fatArch = (struct fat_arch *)((struct fat_header *)machoHeader + 1);
        struct fat_header *fatHeader = (struct fat_header *)machoHeader;
        for(uint32_t i = 0; i < ntohl(fatHeader->nfat_arch); i++)
        {
            if(sizeof(int *) == 4 && !(ntohl(fatArch->cputype) & CPU_ARCH_ABI64)) // check 32bit section for 32bit architecture
            {
                offset = ntohl(fatArch->offset);
                break;
            }
            else if(sizeof(int *) == 8 && (ntohl(fatArch->cputype) & CPU_ARCH_ABI64)) // and 64bit section for 64bit architecture
            {
                offset = ntohl(fatArch->offset);
                break;
            }
            fatArch = (struct fat_arch *)((uint8_t *)fatArch + sizeof(struct fat_arch));
        }
        machoHeader = (const struct mach_header *)((uint8_t *)machoHeader + offset);
    }
    
    if(machoHeader->magic == MH_MAGIC)    // 32bit
    {
        machoCmd = (struct load_command *)((struct mach_header *)machoHeader + 1);
    }
    else if(machoHeader->magic == MH_MAGIC_64)   // 64bit
    {
        machoCmd = (struct load_command *)((struct mach_header_64 *)machoHeader + 1);
    }
    
    for(uint32_t i=0; i < machoHeader->ncmds && machoCmd != NULL; i++)
    {
        if(machoCmd->cmd == LC_ENCRYPTION_INFO)
        {
            struct encryption_info_command *cryptCmd = (struct encryption_info_command *) machoCmd;
            return cryptCmd->cryptid;
        }
        if(machoCmd->cmd == LC_ENCRYPTION_INFO_64)
        {
            struct encryption_info_command_64 *cryptCmd = (struct encryption_info_command_64 *) machoCmd;
            return cryptCmd->cryptid;
        }
        /*从mach-o中读取签名信息
        if(machoCmd->cmd == LC_CODE_SIGNATURE)
        {
            struct linkedit_data_command *signatureCmd = (struct linkedit_data_command *) machoCmd;
            return signatureCmd->cmd;
        }
        */
        machoCmd = (struct load_command *)((uint8_t *)machoCmd + machoCmd->cmdsize);
    }
    
    return 0; // couldn't find cryptcmd
}

#pragma mark - anti 重签名
int ehd_checkResign(const char *identifier)
{
    // 描述文件路径
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    // 读取application-identifier  注意描述文件的编码要使用:NSASCIIStringEncoding
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i = 0; i < embeddedProvisioningLines.count; i++)
    {
        if ([embeddedProvisioningLines[i] rangeOfString:@"application-identifier"].location != NSNotFound) {
            NSInteger fromPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"<string>"].location+8;
            NSInteger toPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"</string>"].location;
            NSRange range;
            range.location = fromPosition;
            range.length = toPosition-fromPosition;
            NSString *fullIdentifier = [embeddedProvisioningLines[i+1] substringWithRange:range];
            NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
            NSString *appIdentifier = [identifierComponents firstObject];
            // 对比签名ID
            if(strcmp([appIdentifier cStringUsingEncoding:NSUTF8StringEncoding], identifier) !=0) return 1;
        }
    }
    return 0;
}

#pragma mark - 自定义退出
inline __attribute__((always_inline)) void ehd_exit(void)
{
#ifdef __arm64__
    __asm__("mov X0, #1 \t\n"
            "mov w16, #1 \t\n" // ip1 指针。
            "svc #0x80");
#elif __arm__
    __asm__("mov r0, #1 \t\n"
            "mov ip, #1 \t\n"
            "svc #0x80");
#else
    exit(-1);
#endif
    return;
}
