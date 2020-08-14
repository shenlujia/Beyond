//
//  HSKVOObserver.h
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSKVOObserver;

@protocol HSKVOObserverDelegate <NSObject>
@required
- (void)observer:(HSKVOObserver *)observer
      didObserve:(NSString *)keyPath
        ofObject:(id)object
          change:(NSDictionary *)change
           block:(id)block;
- (void)observerObjectWillDealloc:(HSKVOObserver *)observer;
@end

@interface HSKVOObserver : NSObject

@property (nonatomic, weak) id <HSKVOObserverDelegate> delegate;

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

- (void)observe:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(id)block;

- (void)unobserve:(NSString *)keyPath;
- (void)unobserveAll;

@end
