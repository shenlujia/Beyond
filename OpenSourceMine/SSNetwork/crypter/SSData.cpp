//
//  SSData.cpp
//  Pods
//
//  Created by shenlujia on 2017/9/6.
//
//

#import "SSData.h"
#import "utf8/checked.h"
#import <string>
#import <openssl/evp.h>
#import <openssl/buffer.h>

////////////////////////////////////////////////////////////
#pragma mark - SSData

SSData::SSData()
{
    this->m_data = nullptr;
    this->m_len = 0;
}

SSData::SSData(const SSData &other)
{
    this->m_data = nullptr;
    this->m_len = 0;
    
    reset(other.bytes(), other.length());
}

SSData::SSData(const void *data, size_t len, bool transfer_memory)
{
    this->m_data = nullptr;
    this->m_len = 0;
    
    if (transfer_memory) {
        this->m_data = (void *)data;
        this->m_len = len;
    } else {
        reset(data, len);
    }
}

SSData::~SSData()
{
    if (m_data) {
        free(m_data);
    }
    m_data = nullptr;
    m_len = 0;
}

SSData & SSData::operator=(const SSData &other)
{
    if (this != &other) {
        reset(other.bytes(), other.length());
    }
    return *this;
}

SSData SSData::operator+(const SSData &other) const
{
    if (other.empty()) {
        return *this;
    }
    
    size_t len = this->length() + other.length();

    void *buf = malloc(len);
    memcpy(buf, this->bytes(), this->length());
    memcpy((char *)buf + this->length(), other.bytes(), other.length());

    // buf内存由data管理
    return SSData(buf, len, true);
}

bool SSData::operator==(const SSData &other) const
{
    // 都为空
    if (this->bytes() == nullptr && other.bytes() == nullptr) {
        return true;
    }
    // 其中之一为空
    if (this->bytes() == nullptr || other.bytes() == nullptr) {
        return false;
    }
    // 长度不等
    if (this->length() != other.length()) {
        return false;
    }
    return memcmp(this->bytes(), other.bytes(), this->length()) == 0;
}

const void * SSData::bytes() const
{
    return m_data;
}

size_t SSData::length() const
{
    return m_len;
}

bool SSData::SSData::empty() const
{
    return m_len <= 0 || !m_data;
}

void SSData::reset(const void *data, size_t len)
{
    void *memory = this->m_data;
    this->m_data = nullptr;
    this->m_len = 0;
    
    if (data && len > 0) {
        this->m_data = malloc(len);
        this->m_len = len;
        memcpy(this->m_data, data, len);
    }
    
    // data可能和当前内存有重叠 先复制 再释放内存
    if (memory) {
        free(memory);
    }
}

////////////////////////////////////////////////////////////
#pragma mark - SSDataHelper

#define impl_data_init                ss_convert_in_i

#define impl_data_file                ss_convert_in_0

#define impl_data_utf8                ss_convert_in_1

#define impl_data_base64_encode       ss_convert_in_2
#define impl_data_base64_decode       ss_convert_in_3

#define impl_data_shift               ss_convert_in_4
#define impl_data_add_random          ss_convert_in_5
#define impl_data_remove_random       ss_convert_in_6

SSData impl_data_file(const char *path)
{
    FILE *file = fopen(path, "r");
    if (!file) {
        return SSData();
    }
    
    fseek(file, 0, SEEK_END);
    long len = ftell(file);
    void *buf = malloc(len);
    
    rewind(file);
    fread(buf, 1, len, file);
    fclose(file);
    
    // buf内存由data管理
    return SSData(buf, len, true);
}

SSData impl_data_utf8(const SSData &data)
{
    std::string text = std::string((char *)data.bytes(), data.length());
    if (utf8::is_valid(text.begin(), text.end())) {
        return data;
    }
    return SSData();
}

SSData impl_data_shift(const SSData &data, long shift)
{
    if (data.empty()) {
        return data;
    }
    
    const size_t len = data.length();
    unsigned char *buf = (unsigned char *)malloc(len);
    for (int i = 0; i < len; ++i) {
        unsigned char c = ((unsigned char *)data.bytes())[i] + shift;
        buf[i] = c;
    }
    // buf内存由data管理
    return SSData(buf, len, true);
}

SSData impl_data_add_random(const SSData &data)
{
    if (data.empty()) {
        return data;
    }
    
    const int randomMax = '~' - '!';
    const size_t len = data.length() * 2;
    void *buf = malloc(len);
    srand((unsigned)time(nullptr));
    for (int i = 0; i < len / 2; ++i) {
        ((unsigned char *)buf)[i * 2] = ((unsigned char *)data.bytes())[i];
        ((unsigned char *)buf)[i * 2 + 1] = random() % randomMax + '!';
    }
    // buf内存由data管理
    return SSData(buf, len, true);
}

SSData impl_data_remove_random(const SSData &data)
{
    if (data.empty()) {
        return data;
    }
    
    const size_t len = (data.length() + 1) / 2;
    void *buf = malloc(len);
    for (int i = 0; i < len; ++i) {
        ((char *)buf)[i] = ((char *)data.bytes())[i * 2];
    }
    // buf内存由data管理
    return SSData(buf, len, true);
}

SSData impl_data_base64_encode(const SSData &data)
{
    SSData result;
    if (data.empty()) {
        return data;
    }
    
    BIO *b64 = BIO_new(BIO_f_base64());
    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    BIO *bmem = BIO_new(BIO_s_mem());
    b64 = BIO_push(b64, bmem);
    BIO_write(b64, data.bytes(), (int)data.length());
    BIO_flush(b64);
    
    BUF_MEM *buf = nullptr;
    BIO_get_mem_ptr(b64, &buf);
    if (buf) {
        result = SSData(buf->data, buf->length);
    }
    
    BIO_free_all(b64);
    // 已经释放 无需调用
    //BIO_free_all(bmem);
    //BUF_MEM_free(buf);
    
    return result;
}

SSData impl_data_base64_decode(const SSData &data)
{
    SSData result;
    if (data.empty()) {
        return data;
    }
    
    BIO *b64 = BIO_new(BIO_f_base64());
    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    BIO *bmem = BIO_new_mem_buf((void *)data.bytes(), (int)data.length());
    bmem = BIO_push(b64, bmem);
    
    void *buf = malloc(data.length());
    int len = BIO_read(bmem, buf, (int)data.length());
    if (len >= 0) {
        result = SSData(buf, len);
    }
    
    BIO_free_all(b64);
    // 已经释放 无需调用
    //BIO_free_all(bmem);
    //BUF_MEM_free(buf);
    
    free(buf);
    
    return result;
}

////////////////////////////////////////////////////////////
#pragma mark - SSDataHelper init

SSDataHelper ss_convert_h_1;

__attribute__((constructor)) static void impl_data_init()
{
    ss_convert_h_1._ss_data_file = impl_data_file;
    
    ss_convert_h_1._ss_data_utf8 = impl_data_utf8;
    
    ss_convert_h_1._ss_data_base64_encode = impl_data_base64_encode;
    ss_convert_h_1._ss_data_base64_decode = impl_data_base64_decode;
    
    ss_convert_h_1._ss_data_shift = impl_data_shift;
    ss_convert_h_1._ss_data_add_random = impl_data_add_random;
    ss_convert_h_1._ss_data_remove_random = impl_data_remove_random;
}

////////////////////////////////////////////////////////////
