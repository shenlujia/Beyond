//
//  FixExecuter.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "FixExecuter.h"

@implementation FixExecuter

- (void)fix:(CodeModel *)codeObject pod:(PodModel *)podObject
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [podObject.pods enumerateKeysAndObjectsUsingBlock:^(NSString *name, PodItem *pod, BOOL *stop) {
        [pod.items enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString *realKey = key.lowercaseString;
            if (dictionary[realKey]) {
                NSString *log = [NSString stringWithFormat:@"重复头文件?\n%@\n%@", dictionary[realKey], obj];
                [self.delegate executer:self log:log];
            }
            dictionary[realKey] = obj;
        }];
    }];
    [codeObject updateWithHeaders:dictionary];
}

@end
