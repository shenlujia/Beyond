//
//  AppDelegate.m
//  NameCenter
//
//  Created by ZZZ on 2022/8/14.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, weak) NSApplication *application;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.application = aNotification.object;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
