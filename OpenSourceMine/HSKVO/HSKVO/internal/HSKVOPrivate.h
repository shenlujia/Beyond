//
//  HSKVOPrivate.h
//  HSKVO
//
//  Created by shenlujia on 2016/1/9.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#ifndef HSKVOPrivate_h
#define HSKVOPrivate_h


//#define KVO_RAII_USE_DEALLOC
//#define KVO_RAII_USE_SWIZZLE


#ifdef DEBUG
#define DEBUG_HSKVO
#endif


#ifdef DEBUG_HSKVO
#define HSKVOLog(...) NSLog(__VA_ARGS__)
#else
#define HSKVOLog(...)
#endif


#endif /* HSKVOPrivate_h */
