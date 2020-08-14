//
//  SSRSAKeyPair.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/28.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <openssl/pem.h>
#import "SSData.h"

////////////////////////////////////////////////////////////

#define SSRSAKeyPair                ss_convert_c_3
#define SSRSAKeyPairHelper          ss_convert_s_3

#define publicKey                   ss_convert_f_0
#define privateKey                  ss_convert_f_1
#define resetKey                    ss_convert_f_2
#define resetKeys                   ss_convert_f_3
#define public_rsa                  ss_convert_f_4
#define private_rsa                 ss_convert_f_5

#define _ss_rsa_key_pair_create     ss_convert_f_0

////////////////////////////////////////////////////////////

class SSRSAKeyPair
{
public:
    SSRSAKeyPair();
    SSRSAKeyPair(const SSRSAKeyPair &other);
    ~SSRSAKeyPair();
    
    SSRSAKeyPair & operator=(const SSRSAKeyPair &other);
    
    RSA * publicKey() const;
    RSA * privateKey() const;
    
    void resetKey(int key_size); // 随机生成密钥
    void resetKey(const SSData &data, bool is_public);
    
private:
    void resetKeys(RSA *public_key, RSA *private_key);
    
private:
    RSA *public_rsa;
    RSA *private_rsa;
};

////////////////////////////////////////////////////////////

struct SSRSAKeyPairHelper
{
    SSRSAKeyPair (*_ss_rsa_key_pair_create)(const SSData &public_data, const SSData &private_data);
};

extern struct SSRSAKeyPairHelper ss_convert_h_3;

////////////////////////////////////////////////////////////

#define SS_RSA_KeyPair(pub_data, pri_data) ss_convert_h_3._ss_rsa_key_pair_create(pub_data, pri_data)

////////////////////////////////////////////////////////////
