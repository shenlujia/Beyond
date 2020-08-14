//
//  SSConverter.c
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/29.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSConverter.h"
#import <CocoaSecurity/Base64.h>
#import "SSCrypter.h"

////////////////////////////////////////////////////////////

#define SS_SHIFT_VALUE                      10
#define SS_AES_KEY                          @"hsyuntai.com"
#define SS_RSA_PUBLIC_KEY_NAME              @"publicKey.pem"
#define SS_RSA_PRIVATE_KEY_NAME             @"privateKey.pem"

#define ReturnNilIfInvalid(object) if (!object) { return nil; }

////////////////////////////////////////////////////////////

#define impl_convert_init                   ss_convert_in_i

#define impl_rsa_key_path                   ss_convert_in_k1
#define impl_rsa_public_key                 ss_convert_in_k2
#define impl_rsa_private_key                ss_convert_in_k3

#define impl_gen_ssdata                     ss_convert_in_2
#define impl_gen_nsdata                     ss_convert_in_3

#define impl_path                           ss_convert_in_4
#define impl_data_file                      ss_convert_in_30
#define impl_data_utf8_file                 ss_convert_in_20
#define impl_data_to_string                 ss_convert_in_0
#define impl_string_to_data                 ss_convert_in_1

#define impl_data_shift                     ss_convert_in_5
#define impl_data_add_random                ss_convert_in_6
#define impl_data_remove_random             ss_convert_in_7
#define impl_data_common_encrypt            ss_convert_in_8
#define impl_data_common_decrypt            ss_convert_in_9

#define impl_data_base64_encode             ss_convert_in_10
#define impl_data_base64_decode             ss_convert_in_11

#define impl_data_aes_encrypt               ss_convert_in_12
#define impl_data_aes_decrypt               ss_convert_in_13

#define impl_data_rsa_public_encrypt        ss_convert_in_21
#define impl_data_rsa_private_sign          ss_convert_in_22

#define impl_rsa_public_encrypt             ss_convert_in_23
#define impl_rsa_private_sign               ss_convert_in_24
#define impl_device_token                   ss_convert_in_25

////////////////////////////////////////////////////////////

static SSData impl_gen_ssdata(NSData *data)
{
    return SSData(data.bytes, data.length);
}

static NSData * impl_gen_nsdata(const SSData &data)
{
    return [NSData dataWithBytes:data.bytes() length:data.length()];
}

static SSRSA * impl_rsa_public_key()
{
    static SSRSA r;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *data = NSData_UTF8_File(NS_Path(SS_RSA_PUBLIC_KEY_NAME));
        r = SS_RSA(impl_gen_ssdata(data), SSData());
    });
    return &r;
}

static SSRSA * impl_rsa_private_key()
{
    static SSRSA r;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *data = NSData_UTF8_File(NS_Path(SS_RSA_PRIVATE_KEY_NAME));
        r = SS_RSA(SSData(), impl_gen_ssdata(data));
    });
    return &r;
}

#pragma mark - 辅助

static NSString * impl_path(NSString *name)
{
    return [[NSBundle mainBundle] pathForResource:name ofType:nil];
}

static NSData * impl_data_file(NSString *path)
{
    ReturnNilIfInvalid(path);
    return impl_gen_nsdata(SSData_File(path.UTF8String));
}

static NSData * impl_data_utf8_file(NSString *path)
{
    ReturnNilIfInvalid(path);
    SSData data = SSData_File(path.UTF8String);
    SSData out_data = impl_gen_ssdata(NSData_Common_Decrypt(SS_AES_KEY, impl_gen_nsdata(data)));
    out_data = SSData_UTF8(out_data);
    if (out_data.length()) {
        return impl_gen_nsdata(out_data);
    }
    return impl_gen_nsdata(data);
}

static NSString * impl_data_to_string(NSData *data)
{
    ReturnNilIfInvalid(data);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

static NSData * impl_string_to_data(NSString *string)
{
    ReturnNilIfInvalid(string);
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 简单加解密

static NSData * impl_data_shift(NSData *data, NSInteger shift)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(SSData_Shift(impl_gen_ssdata(data), shift));
}

static NSData * impl_data_add_random(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(SSData_Add_Random(impl_gen_ssdata(data)));
}

static NSData * impl_data_remove_random(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(SSData_Remove_Random(impl_gen_ssdata(data)));
}

static NSData * impl_data_common_encrypt(NSString *key, NSData *data)
{
    ReturnNilIfInvalid(data);
    
    SSData out_data = impl_gen_ssdata(data);
    out_data = SS_AES_Encrypt(SSData(key.UTF8String, key.length), out_data);
    return impl_gen_nsdata(SSData_Add_Random(SSData_Shift(out_data, SS_SHIFT_VALUE)));
}

static NSData * impl_data_common_decrypt(NSString *key, NSData *data)
{
    ReturnNilIfInvalid(data);
    
    SSData out_data = impl_gen_ssdata(data);
    out_data = SSData_Shift(SSData_Remove_Random(out_data), -SS_SHIFT_VALUE);
    out_data = SS_AES_Decrypt(SSData(key.UTF8String, key.length), out_data);
    return impl_gen_nsdata(out_data);
}

#pragma mark - Base64

static NSData * impl_data_base64_encode(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(SSData_Base64_Encode(impl_gen_ssdata(data)));
}

static NSData * impl_data_base64_decode(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(SSData_Base64_Decode(impl_gen_ssdata(data)));
}

#pragma mark - AES

static NSData * impl_data_aes_encrypt(NSString *key, NSData *data)
{
    ReturnNilIfInvalid(key && data);
    return impl_gen_nsdata(SS_AES_Encrypt(SSData(key.UTF8String, key.length), impl_gen_ssdata(data)));
}

static NSData * impl_data_aes_decrypt(NSString *key, NSData *data)
{
    ReturnNilIfInvalid(key && data);
    return impl_gen_nsdata(SS_AES_Decrypt(SSData(key.UTF8String, key.length), impl_gen_ssdata(data)));
}

#pragma mark - RSA

static NSData * impl_data_rsa_public_encrypt(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(impl_rsa_public_key()->publicEncrypt(impl_gen_ssdata(data)));
}

static NSData * impl_data_rsa_private_sign(NSData *data)
{
    ReturnNilIfInvalid(data);
    return impl_gen_nsdata(impl_rsa_private_key()->privateSign(impl_gen_ssdata(data)));
}

static NSString * impl_rsa_public_encrypt(NSString *string)
{
    ReturnNilIfInvalid(string);
    return NSData_to_NSString(NSData_Base64_Encode(NSData_RSA_Public_Encrypt(NSString_to_NSData(string))));
}

static NSString * impl_rsa_private_sign(NSString *string)
{
    ReturnNilIfInvalid(string);
    return NSData_to_NSString(NSData_Base64_Encode(NSData_RSA_Private_Sign(NSString_to_NSData(string))));
}

static NSString * impl_device_token()
{
    return nil;
}

////////////////////////////////////////////////////////////
#pragma mark - 初始化

SSConvert ss_convert_h_4;

__attribute__((constructor)) static void impl_convert_init()
{
    ss_convert_h_4._ns_path = impl_path;
    ss_convert_h_4._ns_data_file = impl_data_file;
    ss_convert_h_4._ns_data_utf8_file = impl_data_utf8_file;
    ss_convert_h_4._ns_data_to_string = impl_data_to_string;
    ss_convert_h_4._ns_string_to_data = impl_string_to_data;
    
    ss_convert_h_4._ns_data_shift = impl_data_shift;
    ss_convert_h_4._ns_data_add_random = impl_data_add_random;
    ss_convert_h_4._ns_data_remove_random = impl_data_remove_random;
    ss_convert_h_4._ns_data_common_encrypt = impl_data_common_encrypt;
    ss_convert_h_4._ns_data_common_decrypt = impl_data_common_decrypt;
    
    ss_convert_h_4._ns_data_base64_encode = impl_data_base64_encode;
    ss_convert_h_4._ns_data_base64_decode = impl_data_base64_decode;
    
    ss_convert_h_4._ns_data_aes_encrypt = impl_data_aes_encrypt;
    ss_convert_h_4._ns_data_aes_decrypt = impl_data_aes_decrypt;
    
    ss_convert_h_4._ns_data_rsa_public_encrypt = impl_data_rsa_public_encrypt;
    ss_convert_h_4._ns_data_rsa_private_sign = impl_data_rsa_private_sign;
    
    ss_convert_h_4._ns_rsa_public_encrypt = impl_rsa_public_encrypt;
    ss_convert_h_4._ns_rsa_private_sign = impl_rsa_private_sign;
    ss_convert_h_4._device_token = impl_device_token;
}
