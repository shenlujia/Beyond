//
//  TFAppearanceStorage.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceStorage.h"
#import "TFAppearance.h"

@implementation TFAppearanceStorage

+ (TFAppearanceStorage *)storage
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (TFAppearance *)defaultAppearance
{
    NSString *path = [NSBundle.mainBundle pathForResource:@"appearance_normal" ofType:@"json"];
    TFAppearance *object = [TFAppearance appearanceWithContentsOfFile:path];
    if (object) {
        return object;
    }
    
    NSString *bundlePath = [NSBundle.mainBundle pathForResource:@"TFAppearance"
                                                         ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    path = [bundle pathForResource:@"appearance_default" ofType:@"json"];
  
    return [TFAppearance appearanceWithContentsOfFile:path];
}

- (BOOL)write:(TFAppearance *)appearance toFile:(NSString *)path
{
    NSDictionary *dictionary = [appearance ss_keyValues];
    if (!dictionary) {
        return NO;
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        return NO;
    }
    
    return [data writeToFile:path atomically:YES];
}

@end
