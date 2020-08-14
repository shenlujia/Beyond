//
//  NSObject+HSKVO.h
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Key provided in the change dictionary of HSKVONotificationBlock that's value represents the key-path being observed
 */
extern NSString *const HSKVONotificationKeyPathKey;

/**
 @abstract Block called on key-value change notification.
 @param observer The observer of the change.
 @param object The object changed.
 @param change The change dictionary which also includes HSKVONotificationKeyPathKey
 */
typedef void (^HSKVONotificationBlock)(id observer, id object, NSDictionary *change);

///--------------------------------------
#pragma mark - HSKVO <NSObject>
///--------------------------------------

@protocol HSKVO <NSObject>

@required

///--------------------------------------
#pragma mark - Observe
///--------------------------------------

/**
 @abstract Registers observer for key-value change notification.
 @param object The object to observe.
 @param keyPath The key path to observe.
 @param options The NSKeyValueObservingOptions to use for observation.
 @param block The block to execute on notification.
 @discussion On key-value change, the specified block is called.
 */
- (void)observe:(id)object
        keyPath:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(HSKVONotificationBlock)block;

/**
 @abstract Registers observer for key-value change notification.
 @param object The object to observe.
 @param keyPaths The key paths to observe.
 @param options The NSKeyValueObservingOptions to use for observation.
 @param block The block to execute on notification.
 @discussion On key-value change, the specified block is called. Inorder to avoid retain loops, the block must avoid referencing the KVO or an owner thereof.
 */
- (void)observe:(id)object
       keyPaths:(NSArray<NSString *> *)keyPaths
        options:(NSKeyValueObservingOptions)options
          block:(HSKVONotificationBlock)block;

///--------------------------------------
#pragma mark - Unobserve
///--------------------------------------

/**
 @abstract Unobserve object key path.
 @param object The object to unobserve.
 @param keyPath The key path to observe.
 @discussion If not observing object key path, or unobserving nil, this method results in no operation.
 */
- (void)unobserve:(id)object keyPath:(NSString *)keyPath;

/**
 @abstract Unobserve all object key paths.
 @param object The object to unobserve.
 @discussion If not observing object, or unobserving nil, this method results in no operation.
 */
- (void)unobserve:(id)object;

/**
 @abstract Unobserve all objects.
 @discussion If not observing any objects, this method results in no operation.
 */
- (void)unobserveAll;

@end

///--------------------------------------
#pragma mark - NSObject (HSKVO)
///--------------------------------------

@interface NSObject (HSKVO)

/**
 @abstract Lazy-loaded HSKVO for use with any object
 @return HSKVO associated with this object, creating one if necessary
 @discussion This makes it convenient to simply create and forget a HSKVO.
 */
@property (nonatomic, strong) id <HSKVO> HSKVO;

@end

NS_ASSUME_NONNULL_END
