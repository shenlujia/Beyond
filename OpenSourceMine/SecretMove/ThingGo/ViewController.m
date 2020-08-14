//
//  ViewController.m
//  ThingGo
//
//  Created by SLJ on 2019/12/18.
//  Copyright © 2019 KLA. All rights reserved.
//

#import "ViewController.h"

NSString *const kFolderKey = @"kProjectFolderKey_1_1";
static const CGFloat kFileSizeOffset = 100000;
NSString *const kFileSizeEnd = @"EEEEEEEEEEE";
NSString *const kOutPrefix = @"out_slj_";
static const CGFloat kFileContentOffset = 200000;

#define IfErrorThenLogAndReturn(error) \
if (error) { \
NSLog(@"%@", error); \
return; \
}

#define IfErrorThenLogAndBreak(error) \
if (error) { \
NSLog(@"%@", error); \
break; \
}

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *folderLabel;

@property (nonatomic, copy, readonly) NSString *zipPath;
@property (nonatomic, copy, readonly) NSString *mkvPath;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetWithPath:[NSUserDefaults.standardUserDefaults objectForKey:kFolderKey]];
}

#pragma mark - action

- (IBAction)selectPathAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:button.title];
    
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse code) {
        if (code == NSModalResponseOK) {
            NSURL *URL = openPanel.URLs.firstObject;
            [self resetWithPath:URL.path];
        }
    }];
}

- (IBAction)setAction:(NSButton *)button
{
    if (self.zipPath.length == 0 || self.mkvPath.length == 0) {
        return;
    }
    
    NSError *error = nil;
    NSFileHandle *fromHandle = nil;
    NSFileHandle *writeHandle = nil;
    
    do {
        fromHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:self.zipPath] error:&error];
        IfErrorThenLogAndBreak(error);
        
        unsigned long long fromSize = 0;
        [fromHandle seekToEndReturningOffset:&fromSize error:&error];
        IfErrorThenLogAndBreak(error);
        
        [fromHandle seekToOffset:0 error:&error];
        IfErrorThenLogAndBreak(error);
        
        writeHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:self.mkvPath] error:&error];
        IfErrorThenLogAndBreak(error);
        
        [writeHandle seekToOffset:kFileSizeOffset error:&error];
        IfErrorThenLogAndBreak(error);
        
        NSString *sizeString = [NSString stringWithFormat:@"%@%@", @(fromSize), kFileSizeEnd];
        NSData *sizeData = [sizeString dataUsingEncoding:NSUTF8StringEncoding];
        [writeHandle writeData:sizeData error:&error];
        IfErrorThenLogAndBreak(error);
        
        [writeHandle seekToOffset:kFileContentOffset error:&error];
        IfErrorThenLogAndBreak(error);
        
        [self handle:fromHandle writeToHandle:writeHandle length:NSIntegerMax];
        IfErrorThenLogAndBreak(error);
        
    } while (NO);
    
    [fromHandle closeFile];
    [writeHandle closeFile];
}

- (IBAction)getAction:(NSButton *)button
{
    if (self.mkvPath.length == 0) {
        return;
    }
    
    NSError *error = nil;
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:self.mkvPath] error:&error];
    IfErrorThenLogAndReturn(error);
    
    do {
        [handle seekToOffset:kFileSizeOffset error:&error];
        IfErrorThenLogAndBreak(error);
        
        NSData *endData = [kFileSizeEnd dataUsingEncoding:NSUTF8StringEncoding];
        NSData *sizeData = [handle readDataUpToLength:endData.length error:&error];
        IfErrorThenLogAndBreak(error);
        
        NSString *sizeString = [[NSString alloc] initWithData:sizeData encoding:NSUTF8StringEncoding];
        sizeString = [sizeString componentsSeparatedByString:[kFileSizeEnd substringToIndex:1]].firstObject;
        
        [handle seekToOffset:kFileContentOffset error:&error];
        IfErrorThenLogAndBreak(error);
        
        NSString *toName = [NSString stringWithFormat:@"%@%@.zip", kOutPrefix, NSDate.date];
        NSString *toPath = [[self.mkvPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:toName];
        [self handle:handle writeToPath:toPath length:sizeString.integerValue];
        
        IfErrorThenLogAndBreak(error);
        
    } while (NO);
    
    [handle closeFile];
}

#pragma private

- (void)resetWithPath:(NSString *)path
{
    path = path ?: @"";
    self.folderLabel.stringValue = path;
    [NSUserDefaults.standardUserDefaults setObject:path forKey:kFolderKey];
    
    for (NSString *content in [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil]) {
        NSString *file = [path stringByAppendingPathComponent:content];
        if ([content hasPrefix:kOutPrefix]) {
            continue;
        }
        NSString *extension = file.pathExtension;
        if ([extension isEqualToString:@"mp4"] ||
            [extension isEqualToString:@"mkv"]) {
            _mkvPath = file;
        } else if ([extension isEqualToString:@"zip"]) {
            _zipPath = file;
        }
    }
}

- (void)handle:(NSFileHandle *)handle writeToPath:(NSString *)path length:(NSInteger)length
{
    NSError *error = nil;
    [NSFileManager.defaultManager createFileAtPath:path contents:nil attributes:nil];
    
    NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:path] error:&error];
    IfErrorThenLogAndReturn(error);
    
    [self handle:handle writeToHandle:writeHandle length:length];
    
    [writeHandle closeFile];
}

- (void)handle:(NSFileHandle *)fromHandle writeToHandle:(NSFileHandle *)writeHandle length:(NSInteger)length
{
    NSError *error = nil;
    
    const NSInteger kMax = 64 * 1024;
    NSData *data = [fromHandle readDataUpToLength:MIN(kMax, length) error:&error];
    while (data.length > 0 && !error && length > 0) {
        @autoreleasepool {
            [writeHandle writeData:data error:&error];
            IfErrorThenLogAndBreak(error);
            
            length -= kMax;
            data = [fromHandle readDataUpToLength:MIN(kMax, length) error:&error];
        }
    }
}

@end
