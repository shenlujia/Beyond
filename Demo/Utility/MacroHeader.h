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


#endif /* MacroHeader_h */
