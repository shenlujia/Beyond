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
static NSString *kOldFileKey = @"!README.txt";

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
    
    // 设置目录
    [self p_setupPath];
    // 校验目录
    BOOL OK = [self p_checkPath];
    // 读取缓存的配置
    [self p_setupValues];
    if (OK) {
        // 修复文件名
        [self fixFiles];
        // 进入时默认扫描一次
        [self scanAction:nil];
    }
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

- (IBAction)checkNameAction:(NSButton *)button
{
    [self p_appendLog:@""];
    if (![self p_checkPath]) {
        return;
    }
    
    NSString *text = self.nameField.stringValue;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [self p_appendLog:@"请输入文件名"];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *value in self.values) {
        if ([value.lowercaseString containsString:text.lowercaseString]) {
            [items addObject:value];
        }
    }
    [items sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [a compare:b];
    }];
    if (items.count) {
        [self p_appendLog:[items componentsJoinedByString:@"\n"]];
    } else {
        [self p_appendLog:[NSString stringWithFormat:@"未检测到 %@", text]];
    }
}

- (IBAction)saveNameAction:(NSButton *)button
{
    [self p_appendLog:@""];
    if (![self p_checkPath]) {
        return;
    }
    
    NSString *text = self.nameField.stringValue;
    if (text.length == 0) {
        [self p_appendLog:@"请输入文件名"];
        return;
    }
    [self p_addValue:text];
    [self p_synchronize];
    [self p_appendLog:@"记录成功"];
}

- (IBAction)checkDuplicateAction:(NSButton *)button
{
    [self p_appendLog:@"\n检测开始"];
    
    [self p_appendLog:@"检测结束"];
}

- (IBAction)scanAction:(NSButton *)button
{
    [self p_appendLog:@"\n扫描开始"];
    if (![self p_checkPath]) {
        return;
    }
    NSString *folder = self.scanFolderField.stringValue;
    NSArray *contents = [self contentsAtPath:folder];
    for (NSString *content in contents) {
        NSString *name = [content stringByReplacingOccurrencesOfString:folder withString:@""];
        [self p_addValue:name];
    }
    
    NSString *oldPath = [folder stringByAppendingPathComponent:kOldFileKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:oldPath encoding:NSUTF8StringEncoding error:&error];
        [self p_appendLog:error.description];
        NSArray *components = [content componentsSeparatedByString:@"\n"];
        for (NSString *component in components) {
            [self p_addValue:component];
        }
    }
    
    [self p_synchronize];
    [self p_appendLog:@"扫描结束"];
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
    self.values = values;
    
    NSString *folder = self.targetFolderField.stringValue;
    if (folder.length) {
        NSString *path = [folder stringByAppendingPathComponent:kTargetFileKey];
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            NSError *error = nil;
            NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            [self p_appendLog:error.description];
            NSArray *components = [content componentsSeparatedByString:@"\n"];
            for (NSString *component in components) {
                [self p_addValue:component];
            }
        }
    }
    
    if (self.values.count == 0) {
        [self p_appendLog:@"本地无缓存"];
    }
}

- (void)fixFiles
{
    NSString *folder = self.scanFolderField.stringValue;
    if (folder.length == 0) {
        return;
    }
    
    NSFileManager *manager = NSFileManager.defaultManager;
    NSError *error = nil;
    NSArray *contents = [self contentsAtPath:folder];
    for (NSString *path in contents) {
        NSString *name = path.lastPathComponent;
        NSString *toName = [self p_fixName:name];
        if (![name isEqualToString:toName]) {
            [self p_appendLog:[NSString stringWithFormat:@"文件重命名 %@ -> %@", name, toName]];
            NSString *toPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:toName];
            if ([manager fileExistsAtPath:toPath]) {
                [self p_appendLog:[NSString stringWithFormat:@"文件重命名失败 目标目录已存在 %@", toPath]];
            } else {
                [manager moveItemAtPath:path toPath:toPath error:&error];
                [self p_appendLog:error.description];
            }
        }
    }
}

- (void)p_synchronize
{
    NSString *folder = self.targetFolderField.stringValue;
    if (folder.length) {
        NSString *path = [folder stringByAppendingPathComponent:kTargetFileKey];
        NSArray *array = self.values.allObjects;
        array = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a compare:b];
        }];
        NSString *text = [array componentsJoinedByString:@"\n"];
        NSError *error = nil;
        [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [self p_appendLog:error.description];
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

- (NSArray *)contentsAtPath:(NSString *)path
{
    NSMutableArray *ret = [NSMutableArray array];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (path.length == 0) {
        [self p_appendLog:@"目录为空"];
        return ret;
    }
    
    NSError *error = nil;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        [self p_appendLog:error.description];
        return ret;
    }
    
    NSMutableArray *paths = [NSMutableArray array];
    for (NSString *name in contents) {
        if ([name isEqualToString:@".DS_Store"]) {
            continue;
        }
        NSString *item = [path stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        if (![manager fileExistsAtPath:item isDirectory:&isDirectory]) {
            continue;
        }
        if (isDirectory) {
            NSArray *items = [self contentsAtPath:item];
            if (items.count) {
                [paths addObjectsFromArray:items];
            }
        } else {
            [paths addObject:item];
        }
    }
    
    for (NSString *item in [paths copy]) {
        if ([item hasSuffix:kOldFileKey]) {
            continue;
        }
        if ([item.pathExtension isEqualToString:@"mp4"] ||
            [item.pathExtension isEqualToString:@"mov"] ||
            [item.pathExtension isEqualToString:@"wmv"]) {
            [ret addObject:item];
        } else if ([item.pathExtension isEqualToString:@"jpg"] ||
                   [item.pathExtension isEqualToString:@"jpeg"]) {
            [ret addObject:item];
        } else {
            [self p_appendLog:[NSString stringWithFormat:@"非法文件: %@", item]];
        }
    }
    return ret;
}

- (void)p_addValue:(NSString *)value
{
    value = [self p_fixName:value];
    if (value.length) {
        [self.values addObject:value];
    }
}

// 统一修复 FC2PPV-XXXXXX
// fc2ppv-XXXXXX fc2-ppv-XXXXXX fc2-ppv_XXXXXX FC2-ppv_XXXXXX
- (NSString *)p_fixName:(NSString *)name
{
    if (name.length == 0) {
        return name;
    }
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lowercase = name.lowercaseString;
    if (![lowercase hasPrefix:@"fc2"]) {
        return name;
    }
    
    NSString *fc2ppv = @"fc2ppv";
    NSString *toName = name;
    if ([lowercase hasPrefix:@"fc2-ppv"] ||
        [lowercase hasPrefix:@"fc2_ppv"]) {
        toName = [toName stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:fc2ppv];
    } else if ([lowercase hasPrefix:fc2ppv]) {
        toName = [toName stringByReplacingCharactersInRange:NSMakeRange(0, fc2ppv.length) withString:fc2ppv];
    }
    
    if ([toName hasPrefix:fc2ppv] && toName.length > fc2ppv.length) {
        NSRange range = NSMakeRange(fc2ppv.length, 1);
        NSString *seperator = [toName substringWithRange:range];
        if ([seperator isEqualToString:@"-"]) {
            // 正确
        } else if ([seperator isEqualToString:@"_"] ||
                   [seperator isEqualToString:@" "]) {
            toName = [toName stringByReplacingCharactersInRange:range withString:@"-"];
        } else {
            [self p_appendLog:[NSString stringWithFormat:@"%@ 异常错误: %@", NSStringFromSelector(_cmd), name]];
            return name;
        }
    }
    
    NSString *fc2ppv_ = @"fc2ppv-";
    if ([toName hasPrefix:fc2ppv_]) {
        NSRange range = NSMakeRange(0, fc2ppv_.length);
        toName = [toName stringByReplacingCharactersInRange:range withString:@"FC2PPV-"];
    }
    
    return toName;
}

@end
