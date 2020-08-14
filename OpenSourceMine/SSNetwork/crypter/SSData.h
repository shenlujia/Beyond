//
//  SSData.h
//  Pods
//
//  Created by shenlujia on 2017/9/6.
//
//

#import <stdio.h>

////////////////////////////////////////////////////////////

#define SSData                       ss_convert_c_1
#define SSDataHelper                 ss_convert_s_1

// 这两个会和NSData冲突 就不做混淆了 也没什么必要
//#define ss_bytes                   ss_convert_f_0
//#define ss_length                  ss_convert_f_1
#define empty                        ss_convert_f_2
#define reset                        ss_convert_f_3
#define m_data                       ss_convert_v_4
#define m_len                        ss_convert_v_5

#define _ss_data_file                ss_convert_f_0
#define _ss_data_utf8                ss_convert_f_1
#define _ss_data_base64_encode       ss_convert_f_2
#define _ss_data_base64_decode       ss_convert_f_3
#define _ss_data_shift               ss_convert_f_4
#define _ss_data_add_random          ss_convert_f_5
#define _ss_data_remove_random       ss_convert_f_6

////////////////////////////////////////////////////////////

class SSData
{
public:
    SSData();
    SSData(const SSData &other);
    SSData(const void *data, size_t len, bool transfer_memory = false);
    ~SSData();
    
    SSData & operator=(const SSData &other);
    SSData operator+(const SSData &other) const;
    bool operator==(const SSData &other) const;
    
    const void * bytes() const;
    size_t length() const;
    bool empty() const;
    
private:
    void reset(const void *data, size_t len);
    
private:
    void *m_data;
    size_t m_len;
};

////////////////////////////////////////////////////////////

struct SSDataHelper
{
    SSData (*_ss_data_file)(const char *path);
    
    SSData (*_ss_data_utf8)(const SSData &data);
    
    SSData (*_ss_data_base64_encode)(const SSData &data);
    SSData (*_ss_data_base64_decode)(const SSData &data);
    
    SSData (*_ss_data_shift)(const SSData &data, long shift);
    SSData (*_ss_data_add_random)(const SSData &data);
    SSData (*_ss_data_remove_random)(const SSData &data);
};

extern struct SSDataHelper ss_convert_h_1;

////////////////////////////////////////////////////////////

#define SSData_File(path)               ss_convert_h_1._ss_data_file(path)

#define SSData_UTF8(data)               ss_convert_h_1._ss_data_utf8(data)

#define SSData_Base64_Encode(data)      ss_convert_h_1._ss_data_base64_encode(data)
#define SSData_Base64_Decode(data)      ss_convert_h_1._ss_data_base64_decode(data)

#define SSData_Shift(data, shift)       ss_convert_h_1._ss_data_shift(data, shift)
#define SSData_Add_Random(data)         ss_convert_h_1._ss_data_add_random(data)
#define SSData_Remove_Random(data)      ss_convert_h_1._ss_data_remove_random(data)

////////////////////////////////////////////////////////////
