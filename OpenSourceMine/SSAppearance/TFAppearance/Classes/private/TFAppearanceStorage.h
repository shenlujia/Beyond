//
//  TFAppearanceStorage.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import <Foundation/Foundation.h>

@class TFAppearance;

@interface TFAppearanceStorage : NSObject

@property (class, strong, readonly) TFAppearanceStorage *storage;

- (TFAppearance *)defaultAppearance;

- (BOOL)write:(TFAppearance *)appearance toFile:(NSString *)path;

@end
