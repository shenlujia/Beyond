//
//  ViewController.m
//  NameCenter
//
//  Created by ZZZ on 2022/8/14.
//

#import "ViewController.h"

static NSString *kScanPathKey = @"kScanPathKey";
static NSString *kTargetPathKey = @"kTargetPathKey";
static NSString *kTargetFileKey = @"names";

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *scanFolderField;
@property (nonatomic, weak) IBOutlet NSTextField *targetFolderField;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSTextView *textView;

@property (nonatomic, strong) NSMutableSet<NSString *> *values;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameField.editable = YES;
    self.textView.editable = NO;
    
    [self p_setupPath];
    [self p_checkPath];
    [self p_setupValues];
}

#pragma mark - action

- (IBAction)selectScanAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:button.title];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    __weak ViewController *host = self;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse code) {
        if (code == NSModalResponseOK) {
            NSURL *URL = openPanel.URLs.firstObject;
            [NSUserDefaults.standardUserDefaults setObject:URL.path forKey:kScanPathKey];
            [host p_setupPath];
        }
    }];
}

- (IBAction)selectTargetAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:button.title];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    __weak ViewController *host = self;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse code) {
        if (code == NSModalResponseOK) {
            NSURL *URL = openPanel.URLs.firstObject;
            [NSUserDefaults.standardUserDefaults setObject:URL.path forKey:kTargetPathKey];
            [host p_setupPath];
        }
    }];
}

- (IBAction)saveAction:(NSButton *)button
{
    if (![self p_checkPath]) {
        return;
    }
    
    NSString *text = self.nameField.stringValue;
    if (text.length == 0) {
        [self p_appendLog:@"请输入文件名"];
        return;
    }
    [self.values addObject:text];
    [self p_synchronize];
}

- (IBAction)scanAction:(NSButton *)button
{
    if (![self p_checkPath]) {
        return;
    }
    
    [self p_synchronize];
}

- (IBAction)clearAction:(NSButton *)button
{
    self.textView.string = @"";
}

#pragma private

- (BOOL)p_checkPath
{
    if (self.scanFolderField.stringValue.length == 0) {
        [self p_appendLog:@"扫描目录不存在"];
        return NO;
    }
    if (self.targetFolderField.stringValue.length == 0) {
        [self p_appendLog:@"记忆目录不存在"];
        return NO;
    }
    return YES;
}

- (void)p_setupPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *scanPath = [NSUserDefaults.standardUserDefaults objectForKey:kScanPathKey];
    NSString *targetPath = [NSUserDefaults.standardUserDefaults objectForKey:kTargetPathKey];
    
    if (scanPath.length && [manager fileExistsAtPath:scanPath]) {
        self.scanFolderField.stringValue = scanPath;
    } else {
        self.scanFolderField.stringValue = @"";
    }
    if (targetPath.length && [manager fileExistsAtPath:targetPath]) {
        self.targetFolderField.stringValue = targetPath;
    } else {
        self.targetFolderField.stringValue = @"";
    }
}

- (void)p_setupValues
{
    NSMutableSet *values = [NSMutableSet set];
    if (self.values.count) {
        [values setByAddingObjectsFromSet:self.values];
    }
    
    NSString *folder = self.targetFolderField.stringValue;
    if (folder.length) {
        NSString *path = [folder stringByAppendingPathComponent:kTargetFileKey];
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            NSError *error = nil;
            NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                [self p_appendLog:error.description];
            }
            if (content.length) {
                NSArray *components = [content componentsSeparatedByString:@"\n"];
                [values addObjectsFromArray:components];
            }
        }
    }
    self.values = values;
}

- (void)p_synchronize
{
    NSString *folder = self.targetFolderField.stringValue;
    if (folder.length) {
        NSString *path = [folder stringByAppendingPathComponent:kTargetFileKey];
        NSArray *array = self.values.allObjects;
        array = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [b compare:a];
        }];
        NSString *text = [array componentsJoinedByString:@"\n"];
        NSError *error = nil;
        [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [self p_appendLog:error.description];
        }
    }
}

- (void)p_appendLog:(NSString *)text
{
    if (!text) {
        return;
    }
    
    NSString *full = self.textView.string;
    if (!full) {
        self.textView.string = text;
        return;
    }
    
    self.textView.string = [text stringByAppendingFormat:@"\n%@", full];
}

@end
