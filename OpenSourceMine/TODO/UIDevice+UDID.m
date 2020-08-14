//
//  UIDevice+UDID.m
//  Pods-Demo
//
//  Created by admin on 2018/6/5.
//

#import "UIDevice+UDID.h"
#import <objc/runtime.h>
#import <SAMKeychain/SAMKeychainQuery.h>

@implementation UIDevice (UDID)

- (NSString *)tf_UDID
{
    const void * key = @selector(tf_UDID);
    NSString *UDID = objc_getAssociatedObject(self, key);
    if (![UDID isKindOfClass:[NSString class]]) {
        NSString *identifier = NSBundle.mainBundle.bundleIdentifier;
        UDID = [self tf_keychain_objectForKey:identifier];
        if (![UDID isKindOfClass:[NSString class]]) {
            NSUUID *temp = [NSUUID UUID];
            UDID = temp.UUIDString;
            [self tf_keychain_setObject:UDID forKey:identifier];
        }
        objc_setAssociatedObject(self, key, UDID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return UDID;
}

- (NSString *)tf_keychain_objectForKey:(NSString *)key
{
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = key;
    query.account = key;
    [query fetch:&error];
    
    NSString *text = (id)query.passwordObject;
    return [text isKindOfClass:[NSString class]] ? text : nil;
}

- (void)tf_keychain_setObject:(NSString *)object forKey:(NSString *)key
{
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = key;
    query.account = key;
    query.passwordObject = object;
    [query save:&error];
}

@end
