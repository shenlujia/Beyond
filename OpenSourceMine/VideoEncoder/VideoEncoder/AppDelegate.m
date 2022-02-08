//
//  AppDelegate.m
//  VideoEncoder
//
//  Created by SLJ on 2019/12/18.
//  Copyright © 2019 KLA. All rights reserved.
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

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Menu"];
    [menu addItem:({
        NSMenuItem *ret = nil;
        ret = [[NSMenuItem alloc] initWithTitle:@"合并文件夹内所有txt文件"
                                         action:@selector(action_mergeAllTxts:)
                                  keyEquivalent:@""];
        ret.target = self;
        ret;
    })];
    return menu;
}

- (void)action_mergeAllTxts:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:@"合并"];
    
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    [openPanel beginSheetModalForWindow:self.application.mainWindow completionHandler:^(NSModalResponse code) {
        if (code == NSModalResponseOK) {
            NSURL *URL = openPanel.URLs.firstObject;
            [self p_mergeAllTxtsInPath:URL.path];
        }
    }];
}

- (void)p_mergeAllTxtsInPath:(NSString *)path
{
    if (path.length == 0) {
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *contents = [NSMutableArray array];
    for (NSString *item in [manager contentsOfDirectoryAtPath:path error:nil]) {
        if ([item hasSuffix:@".txt"]) {
            [contents addObject:[path stringByAppendingPathComponent:item]];
        }
    }
    [contents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *text = [NSMutableString string];
    for (NSInteger idx = 0; idx < contents.count; ++idx) {
        NSString *info = [[NSString alloc] initWithContentsOfFile:contents[idx] encoding:NSUTF8StringEncoding error:nil];
        if (info.length) {
            [text appendString:info];
            if (idx != contents.count - 1) {
                [text appendString:@"\n"];
            }
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    NSString *toPath = [path stringByAppendingPathComponent:time];
    [text writeToFile:toPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
