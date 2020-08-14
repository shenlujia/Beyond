//
//  SSRSA.h
//  Pods
//
//  Created by shenlujia on 2017/8/25.
//
//

#import <string>
#import <openssl/rsa.h>
#import <openssl/obj_mac.h>

#import "SSRSAKeyPair.h"
#import "SSData.h"

////////////////////////////////////////////////////////////

#define SSRSA                 ss_convert_c_2
#define SSRSAHelper           ss_convert_s_2

#define publicEncrypt         ss_convert_f_0
#define publicDecrypt         ss_convert_f_1
#define publicVerify          ss_convert_f_2

#define privateEncrypt        ss_convert_f_3
#define privateDecrypt        ss_convert_f_4
#define privateSign           ss_convert_f_5

#define RSAEncryptImpl        ss_convert_f_6
#define RSADecryptImpl        ss_convert_f_7
#define getFlen               ss_convert_f_8
#define key_pair              ss_convert_f_9

#define _ss_rsa_create        ss_convert_f_0

////////////////////////////////////////////////////////////

class SSRSA
{
public:
    SSRSA();
    ~SSRSA();
    
    void setPair(const SSRSAKeyPair &pair);
    
    SSData publicEncrypt(const SSData &data, int padding = RSA_PKCS1_PADDING) const;
    SSData publicDecrypt(const SSData &data, int padding = RSA_PKCS1_PADDING) const;
    bool publicVerify(const SSData &data, const SSData &sign, int type = NID_sha1) const;
    
    SSData privateEncrypt(const SSData &data, int padding = RSA_PKCS1_PADDING) const;
    SSData privateDecrypt(const SSData &data, int padding = RSA_PKCS1_PADDING) const;
    SSData privateSign(const SSData &data, int type = NID_sha1) const;
    
private:
//    SSRSA(const SSRSA &other); // 无指针变量 无需实现
//    SSRSA & operator=(const SSRSA &other); // 无指针变量 无需实现
    
private:
    SSData RSAEncryptImpl(const SSData &data, bool is_public, int padding) const;
    SSData RSADecryptImpl(const SSData &data, bool is_public, int padding) const;
    int getFlen(int rsa_size, int padding) const;
    
private:
    SSRSAKeyPair key_pair;
};

////////////////////////////////////////////////////////////

struct SSRSAHelper
{
    SSRSA (*_ss_rsa_create)(const SSData &public_key, const SSData &private_key);
};

extern struct SSRSAHelper ss_convert_h_2;

////////////////////////////////////////////////////////////

#define SS_RSA(public_key, private_key)    ss_convert_h_2._ss_rsa_create(public_key, private_key)

////////////////////////////////////////////////////////////
