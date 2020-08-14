//
//  EHDSecurityUtilities.h
//  EHDSecurity
//
//  Created by luohs on 2018/10/17.
//

#import <Foundation/Foundation.h>

//是否在调试
int ehd_debuged(void);
//禁止调试
void ehd_invalidGDB(void);
//是否越狱
int ehd_jailbreak(void);
//是否砸壳
int ehd_binaryEncrypted(void);
//是否重签名
int ehd_checkResign(const char *identifier);
//自定义退出
void ehd_exit(void);
