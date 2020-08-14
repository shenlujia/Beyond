//
//  SSAES.cpp
//  Pods
//
//  Created by shenlujia on 2017/8/25.
//
//

#import <CommonCrypto/CommonCrypto.h>
#import <assert.h>
#import "SSAES.h"

#define AES_KEY_LEN 32
#define AES_IV_LEN  16

////////////////////////////////////////////////////////////
#pragma mark - SSAES

SSAES::SSAES()
{
    
}

SSAES::~SSAES()
{
    
}

void SSAES::setSecret(const SSData &data)
{
    if (data.empty()) {
        aes_iv = SSData();
        aes_key = SSData();
        return;
    }
    
    unsigned char *digest = (unsigned char *)malloc(CC_SHA384_DIGEST_LENGTH);
    CC_SHA384(data.bytes(), (CC_LONG)data.length(), (unsigned char *)digest);
    
    aes_key = SSData(digest, AES_KEY_LEN);
    aes_iv = SSData(digest + AES_KEY_LEN, AES_IV_LEN);
    
    free(digest);
}

SSData SSAES::AESEncrypt(const SSData &data) const
{
    assert(!aes_key.empty() && !aes_iv.empty());
    return cryptImpl(data, true);
}

SSData SSAES::AESDecrypt(const SSData &data) const
{
    assert(!aes_key.empty() && !aes_iv.empty());
    return cryptImpl(data, false);
}

SSData SSAES::cryptImpl(const SSData &data, bool encrypt) const
{
    if (data.empty()) {
        return data;
    }
    
    const size_t len = data.length();
    size_t bufferSize = len + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(encrypt ? kCCEncrypt : kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          aes_key.bytes(),
                                          AES_KEY_LEN,
                                          aes_iv.bytes(),
                                          data.bytes(),
                                          len,
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    
    SSData result;
    if (cryptStatus == kCCSuccess) {
        result = SSData(buffer, encryptedSize);
    }
    
    free(buffer);
    
    return result;
}

////////////////////////////////////////////////////////////
#pragma mark - SSAESHelper

#define impl_aes_init                 ss_convert_in_i
#define impl_aes_encrypt              ss_convert_in_0
#define impl_aes_decrypt              ss_convert_in_1

static SSData impl_aes_encrypt(const SSData &key, const SSData &data)
{
    SSAES c;
    c.setSecret(key);
    return c.AESEncrypt(data);
}

static SSData impl_aes_decrypt(const SSData &key, const SSData &data)
{
    SSAES c;
    c.setSecret(key);
    return c.AESDecrypt(data);
}

////////////////////////////////////////////////////////////
#pragma mark - SSAESHelper init

SSAESHelper ss_convert_h_0;

__attribute__((constructor)) static void impl_aes_init()
{
    ss_convert_h_0._ss_aes_encrypt = impl_aes_encrypt;
    ss_convert_h_0._ss_aes_decrypt = impl_aes_decrypt;
}

////////////////////////////////////////////////////////////
