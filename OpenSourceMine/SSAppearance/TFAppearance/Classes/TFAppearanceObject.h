//
//  TFAppearanceObject.h
//  TFAppearance
//
//  Created by shenlujia on 2018/6/8.
//

#import <TFBaseObject/TFBaseObject.h>

@interface TFAppearanceObject : TFBaseObject

- (__kindof TFAppearanceObject *)createFollower;
- (__kindof TFAppearanceObject *)master;

- (BOOL)isFollower;

- (void)updateWithAppearanceObject:(TFAppearanceObject *)object;

@property (nonatomic, assign) BOOL needsUpdateAppearance;

@end
