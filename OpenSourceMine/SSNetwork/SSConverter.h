//
//  SSConverter.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/29.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////

#define SSConvert                            ss_convert_s_4

#define _ns_path                             ss_convert_f_20
#define _ns_data_file                        ss_convert_f_2
#define _ns_data_utf8_file                   ss_convert_f_12
#define _ns_data_to_string                   ss_convert_f_0
#define _ns_string_to_data                   ss_convert_f_1

#define _ns_data_shift                       ss_convert_f_3
#define _ns_data_add_random                  ss_convert_f_4
#define _ns_data_remove_random               ss_convert_f_5
#define _ns_data_common_encrypt              ss_convert_f_6
#define _ns_data_common_decrypt              ss_convert_f_7

#define _ns_data_base64_encode               ss_convert_f_8
#define _ns_data_base64_decode               ss_convert_f_9

#define _ns_data_aes_encrypt                 ss_convert_f_10
#define _ns_data_aes_decrypt                 ss_convert_f_11

#define _ns_data_rsa_public_encrypt          ss_convert_f_13
#define _ns_data_rsa_private_sign            ss_convert_f_14

#define _ns_rsa_public_encrypt               ss_convert_f_15
#define _ns_rsa_private_sign                 ss_convert_f_16
#define _device_token                        ss_convert_f_17

////////////////////////////////////////////////////////////

struct SSConvert
{
    NSString * (*_ns_path)(NSString *name);
    NSData * (*_ns_data_file)(NSString *path);
    NSData * (*_ns_data_utf8_file)(NSString *path);
    NSString * (*_ns_data_to_string)(NSData *data);
    NSData * (*_ns_string_to_data)(NSString *string);
    
    NSData * (*_ns_data_shift)(NSData *data, NSInteger shift);
    NSData * (*_ns_data_add_random)(NSData *data);
    NSData * (*_ns_data_remove_random)(NSData *data);
    NSData * (*_ns_data_common_encrypt)(NSString *key, NSData *data);
    NSData * (*_ns_data_common_decrypt)(NSString *key, NSData *data);
    
    NSData * (*_ns_data_base64_encode)(NSData *data);
    NSData * (*_ns_data_base64_decode)(NSData *data);
    
    NSData * (*_ns_data_aes_encrypt)(NSString *key, NSData *data);
    NSData * (*_ns_data_aes_decrypt)(NSString *key, NSData *data);
    
    NSData * (*_ns_data_rsa_public_encrypt)(NSData *data);
    NSData * (*_ns_data_rsa_private_sign)(NSData *data);

    NSString * (*_ns_rsa_public_encrypt)(NSString *string);
    NSString * (*_ns_rsa_private_sign)(NSString *string);
    NSString * (*_device_token)(void);
};

extern struct SSConvert ss_convert_h_4;

////////////////////////////////////////////////////////////

// 辅助
#define NS_Path(name)                    ss_convert_h_4._ns_path(name) // 文件路径
#define NSData_File(path)                ss_convert_h_4._ns_data_file(path) // 文件data
#define NSData_UTF8_File(path)           ss_convert_h_4._ns_data_utf8_file(path) // 文件data utf8
#define NSData_to_NSString(data)         ss_convert_h_4._ns_data_to_string(data) // NSData -> NSString
#define NSString_to_NSData(string)       ss_convert_h_4._ns_string_to_data(string) // NSString -> NSData

// 简单加解密
#define NSData_Shift(data, shift)        ss_convert_h_4._ns_data_shift(data, shift)
#define NSData_Add_Random(data)          ss_convert_h_4._ns_data_add_random(data)
#define NSData_Remove_Random(data)       ss_convert_h_4._ns_data_remove_random(data)
#define NSData_Common_Encrypt(key, data) ss_convert_h_4._ns_data_common_encrypt(key, data)
#define NSData_Common_Decrypt(key, data) ss_convert_h_4._ns_data_common_decrypt(key, data)

// Base64编码
#define NSData_Base64_Encode(data)       ss_convert_h_4._ns_data_base64_encode(data)
#define NSData_Base64_Decode(data)       ss_convert_h_4._ns_data_base64_decode(data)

// AES加解密
#define NSData_AES_Encrypt(key, data)    ss_convert_h_4._ns_data_aes_encrypt(key, data)
#define NSData_AES_Decrypt(key, data)    ss_convert_h_4._ns_data_aes_decrypt(key, data)

// RSA加解密
#define NSData_RSA_Public_Encrypt(data)  ss_convert_h_4._ns_data_rsa_public_encrypt(data)
#define NSData_RSA_Private_Sign(data)    ss_convert_h_4._ns_data_rsa_private_sign(data)

// 方便上层调用 输入NSString 返回加密之后base64编码的NSString
#define SS_RSA_Public_Encrypt(string)    ss_convert_h_4._ns_rsa_public_encrypt(string)
#define SS_RSA_Private_Sign(string)      ss_convert_h_4._ns_rsa_private_sign(string)
#define SS_Device_Token                  ss_convert_h_4._device_token()

////////////////////////////////////////////////////////////
