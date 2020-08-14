//
//  NSObject+SSHUD.h
//  Pods
//
//  Created by shenlujia on 2017/9/6.
//
//

#import <Foundation/Foundation.h>

@interface SSHUDManager : NSObject

- (void)show;
- (void)showAndIgnoreInteraction;

- (void)dismiss;
- (void)dismissWithText:(NSString *)text;

@end

@interface NSObject (SSHUD)

@property (nonatomic, strong) SSHUDManager *ss_HUD;

@end
