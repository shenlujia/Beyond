//
//  SSCrypto.m
//  NameCenter
//
//  Created by ZZZ on 2022/9/17.
//

#import "SSCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation SSCrypto

+ (NSString *)AES_en:(NSString *)string key:(NSString *)key
{
    if (string.length == 0 || key.length == 0) {
        return nil;
    }
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = data.length;
    
    size_t bufferSize = length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytes = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, data.bytes, length, buffer, bufferSize, &numBytes);
    
    NSString *ret = nil;
    if (status == kCCSuccess) {
        NSData *newData = [NSData dataWithBytes:buffer length:numBytes];
        ret = [newData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(buffer);
    return ret;
}

+ (NSString *)AES_de:(NSString *)string key:(NSString *)key
{
    if (string.length == 0 || key.length == 0) {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger length = data.length;
    size_t bufferSize = length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytes = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, data.bytes, length, buffer, bufferSize, &numBytes);
    
    NSString *ret = nil;
    if (status == kCCSuccess) {
        NSData *newData = [NSData dataWithBytes:buffer length:numBytes];
        ret = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return ret;
}

@end
