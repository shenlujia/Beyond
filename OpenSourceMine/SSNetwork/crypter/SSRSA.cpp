//
//  SSRSA.cpp
//  Pods
//
//  Created by shenlujia on 2017/8/25.
//
//

#import <assert.h>
#import "SSRSA.h"

////////////////////////////////////////////////////////////
#pragma mark - SSRSA

SSRSA::SSRSA()
{
    
}

SSRSA::~SSRSA()
{
    
}

void SSRSA::setPair(const SSRSAKeyPair &pair)
{
    key_pair = pair;
}

SSData SSRSA::publicEncrypt(const SSData &data, int padding) const
{
    assert(key_pair.publicKey());
    
    return RSAEncryptImpl(data, true, padding);
}

SSData SSRSA::publicDecrypt(const SSData &data, int padding) const
{
    assert(key_pair.publicKey());
    
    return RSADecryptImpl(data, true, padding);
}

bool SSRSA::publicVerify(const SSData &data, const SSData &sign, int type) const
{
    assert(key_pair.publicKey());
    
    RSA *rsa = key_pair.publicKey();
    unsigned char digest[SHA_DIGEST_LENGTH] = {'\0'};
    SHA1((const unsigned char *)data.bytes(), data.length(), digest);
    
    unsigned int m_length = (unsigned int)sizeof(digest);
    const unsigned char *sigbuf = (const unsigned char *)sign.bytes();
    int ret = RSA_verify(type, digest, m_length, sigbuf, (unsigned int)sign.length(), rsa);
    return (ret == 1);
}

SSData SSRSA::privateEncrypt(const SSData &data, int padding) const
{
    assert(key_pair.privateKey());
    
    return RSAEncryptImpl(data, false, padding);
}

SSData SSRSA::privateDecrypt(const SSData &data, int padding) const
{
    assert(key_pair.privateKey());
    
    return RSADecryptImpl(data, false, padding);
}

SSData SSRSA::privateSign(const SSData &data, int type) const
{
    assert(key_pair.privateKey());
    
    RSA *rsa = key_pair.privateKey();
    void *buf = malloc(RSA_size(rsa));
    unsigned char digest[SHA_DIGEST_LENGTH] = {'\0'};
   
    SHA1((const unsigned char *)data.bytes(), data.length(), digest);
    unsigned int len = 0;
    
    SSData result;
    if (1 == RSA_sign(type, digest, (unsigned int) sizeof(digest), (unsigned char *)buf, &len, rsa)) {
        result = SSData(buf, len);
    }
    
    free(buf);
    
    return result;
}

SSData SSRSA::RSAEncryptImpl(const SSData &data, bool is_public, int padding) const
{
    RSA *rsa =  is_public ? key_pair.publicKey() : key_pair.privateKey();
    const int rsaSize = RSA_size(rsa);
    const int bufSize = rsaSize + 1;
    
    void *fromBuf =  malloc(bufSize);
    bzero(fromBuf, bufSize);
    memcpy(fromBuf, data.bytes(), data.length());
 
    void *toBuf = malloc(bufSize);
    bzero(toBuf, bufSize);
    
    int flen = this->getFlen(rsaSize, padding);
    int len = -1;
    if (is_public) {
        len = RSA_public_encrypt(flen, (unsigned char *)fromBuf, (unsigned char *)toBuf, rsa, padding);
    } else {
        len = RSA_private_encrypt(flen, (unsigned char *)fromBuf, (unsigned char *)toBuf, rsa, padding);
    }
    
    SSData result;
    if (len >= 0) {
        result = SSData(toBuf, len);
    }
    
    free(toBuf);
    free(fromBuf);
    
    return result;
}

SSData SSRSA::RSADecryptImpl(const SSData &data, bool is_public, int padding) const
{
    SSData result;
    
    const int flen = (int)data.length();
    if (flen == 0) {
        return result;
    }
    
    RSA *rsa = is_public ? key_pair.publicKey() : key_pair.privateKey();
    void *buf = malloc(flen);
    
    int len = -1;
    if (is_public) {
        len = RSA_public_decrypt(flen, (unsigned char *)data.bytes(), (unsigned char *)buf, rsa, padding);
    } else {
        len = RSA_private_decrypt(flen, (unsigned char *)data.bytes(), (unsigned char *)buf, rsa, padding);
    }
    
    if (len >= 0) {
        result = SSData((const char *)buf, strlen((const char *)buf));
    }
    
    free(buf);
    
    return result;
}

int SSRSA::getFlen(int rsa_size, int padding) const
{
    int result = rsa_size;
    switch (padding) {
        case RSA_PKCS1_PADDING:
        case RSA_SSLV23_PADDING: {
            result -= 11;
            break;
        }
        case RSA_X931_PADDING: {
            result -= 2;
            break;
        }
        case RSA_NO_PADDING: {
            break;
        }
        case RSA_PKCS1_OAEP_PADDING: {
            result = result - 2 * SHA_DIGEST_LENGTH - 2;
            break;
        }
        default: {
            result = -1;
            break;
        }
    }
    return result;
}

////////////////////////////////////////////////////////////
#pragma mark - SSRSAHelper

#define impl_rsa_init                ss_convert_in_i
#define impl_rsa_create              ss_convert_in_0

static SSRSA impl_rsa_create(const SSData &public_data, const SSData &private_data)
{
    SSRSA rsa;
    rsa.setPair(SS_RSA_KeyPair(public_data, private_data));
    return rsa;
}

////////////////////////////////////////////////////////////
#pragma mark - SSRSAHelper init

SSRSAHelper ss_convert_h_2;

__attribute__((constructor)) static void impl_rsa_init()
{
    ss_convert_h_2._ss_rsa_create = impl_rsa_create;
}

////////////////////////////////////////////////////////////
