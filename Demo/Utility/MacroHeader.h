//
//  MacroHeader.h
//  Demo
//
//  Created by SLJ on 2020/5/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#ifndef MacroHeader_h
#define MacroHeader_h


#define MAIN_THREAD_SAFE_SYNC(action) \
do { \
  if (!action) { \
    break; \
  } \
  if ([NSThread.currentThread isMainThread]) { \
    action(); \
  } else { \
     dispatch_sync(dispatch_get_main_queue(), ^{ \
         action(); \
     }); \
  } \
} while (0);


#define PRINT_BLANK_LINE printf("\n");


#define SS_MAIN_DELAY(time, block) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
  block(); \
});


#define SS_GLOBAL_DELAY(time, block) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{ \
  block(); \
});


#endif /* MacroHeader_h */
