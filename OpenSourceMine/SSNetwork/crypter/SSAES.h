//
//  SSAES.h
//  Pods
//
//  Created by shenlujia on 2017/8/25.
//
//

#import "SSData.h"

////////////////////////////////////////////////////////////

#define SSAES               ss_convert_c_0
#define SSAESHelper         ss_convert_s_0

#define setSecret           ss_convert_f_0
#define AESEncrypt          ss_convert_f_1
#define AESDecrypt          ss_convert_f_2
#define cryptImpl           ss_convert_f_3
#define aes_iv              ss_convert_f_4
#define aes_key             ss_convert_f_5

#define _ss_aes_encrypt     ss_convert_f_0
#define _ss_aes_decrypt     ss_convert_f_1

////////////////////////////////////////////////////////////

class SSAES
{
public:
    SSAES();
    ~SSAES();
    
    void setSecret(const SSData &data);
    
    SSData AESEncrypt(const SSData &data) const;
    SSData AESDecrypt(const SSData &data) const;
    
private:
//    SSAES(const SSAES &other); // 无指针变量 无需实现
//    SSAES & operator=(const SSAES &other); // 无指针变量 无需实现
    
private:
    SSData cryptImpl(const SSData &data, bool encrypt) const;
    
private:
    SSData aes_iv;
    SSData aes_key;
};

////////////////////////////////////////////////////////////

struct SSAESHelper
{
    SSData (*_ss_aes_encrypt)(const SSData &key, const SSData &data);
    SSData (*_ss_aes_decrypt)(const SSData &key, const SSData &data);
};

extern struct SSAESHelper ss_convert_h_0;

////////////////////////////////////////////////////////////

#define SS_AES_Encrypt(key, data)      ss_convert_h_0._ss_aes_encrypt(key, data)
#define SS_AES_Decrypt(key, data)      ss_convert_h_0._ss_aes_decrypt(key, data)

////////////////////////////////////////////////////////////
