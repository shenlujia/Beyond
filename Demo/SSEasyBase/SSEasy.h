//
//  SSEasy.h — stub header
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SSEasyAlert.h"
#import "SSEasyHook.h"

// MARK: - Logging

FOUNDATION_EXTERN void ss_easy_log(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
FOUNDATION_EXTERN void ss_easy_log_text(NSString *text);
#define PRINT_BLANK_LINE NSLog(@"————————————————");

// MARK: - Lifecycle

FOUNDATION_EXTERN void ss_easy_install(void);

// MARK: - Method Swizzling

FOUNDATION_EXTERN IMP ss_method_swizzle(Class cls, SEL selector, id block);
FOUNDATION_EXTERN void ss_method_ignore(NSString *clsName, NSString *selectorName);

// MARK: - Assertions

FOUNDATION_EXTERN void ss_easy_assert_once_for_key(NSString *key);

// MARK: - Memory

FOUNDATION_EXTERN NSArray *ss_memory_retainedObjects(id object);

// MARK: - ObjC Runtime helper

/// Invoke an ObjC selector on an object with arguments from an array.
FOUNDATION_EXTERN id ss_easy_objc_call(id target, NSString *selectorName, NSArray *arguments);
