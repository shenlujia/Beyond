//
//  ViewController.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "ViewController.h"
#import "FixExecuter.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "XIBChecker.h"
#import "SSCommon.h"

#define kProjectFolderKey @"kProjectFolderKey_1_1"
#define kCodeFolderKey @"kCodeFolderKey_1_1"

@interface ViewController () <FixExecuterDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *projectFolderLabel;
@property (nonatomic, weak) IBOutlet NSTextField *codeFolderLabel;
@property (nonatomic, weak) IBOutlet NSTextView *textView;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) FixExecuter *executer;

@end

@implementation ViewController

#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    
    self.executer = [[FixExecuter alloc] init];
    self.executer.delegate = self;
    
    [self appendLog:self.projectFolderLabel.placeholderString];
    [self appendLog:self.codeFolderLabel.placeholderString];
    [self appendLog:@"自动修复头文件引用 自动去重 自动排序 自动修复podspec引用的头文件 自动处理头文件名大小写写错的问题"];

    NSString *projectFolder = [NSUserDefaults.standardUserDefaults objectForKey:kProjectFolderKey];
    if (projectFolder.length == 0) {
        NSString *user = CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, NULL, NULL));
        NSString *path = [NSString stringWithFormat:@"/Users/%@", user];
        projectFolder = [self findPathAtPath:path name:@"haitao-ios-spring" deep:5];
    }
    self.projectFolderLabel.stringValue = projectFolder ? projectFolder : @"";
    
    NSString *codeFolder = [NSUserDefaults.standardUserDefaults objectForKey:kCodeFolderKey];
    codeFolder = [codeFolder isKindOfClass:[NSString class]] ? codeFolder : @"";
    self.codeFolderLabel.stringValue = codeFolder;
}

#pragma mark - action

- (IBAction)selectProjectAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:button.title];
    
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;

    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse code) {
        if (code == NSFileHandlingPanelOKButton) {
            NSURL *URL = openPanel.URLs.firstObject;
            NSString *name = URL.path ?: @"";
            self.projectFolderLabel.stringValue = name;
            [NSUserDefaults.standardUserDefaults setObject:name forKey:kProjectFolderKey];
        }
    }];
}

- (IBAction)selectCodeAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:button.title];
    
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse code) {
        if (code == NSFileHandlingPanelOKButton) {
            NSURL *URL = openPanel.URLs.firstObject;
            NSString *name = URL.path ?: @"";
            self.codeFolderLabel.stringValue = name;
            [NSUserDefaults.standardUserDefaults setObject:name forKey:kCodeFolderKey];
        }
    }];
}

- (IBAction)checkXibAction:(NSButton *)button
{
    static BOOL checking = NO;
    if (checking) {
        [self appendLog:@"检测中..."];
        return;
    }
    checking = YES;
    NSString *path = self.projectFolderLabel.stringValue;
    [self.queue addOperationWithBlock:^{
        [self appendLog:@"XIB 检查开始..."];
        [self checkXibfixWithProjectPath:path];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            checking = NO;
            [self appendLog:@"XIB 检查结束"];
        }];
    }];
}

- (IBAction)goAction:(NSButton *)button
{
    NSString *projectPath = self.projectFolderLabel.stringValue;
    NSString *codePath = self.codeFolderLabel.stringValue;
    [self.queue addOperationWithBlock:^{
        [self fixWithProjectPath:projectPath codePath:codePath];
    }];
}

- (IBAction)clearLogAction:(NSButton *)button
{
    self.textView.string = @"";
}

#pragma mark - FixExecuterDelegate

- (void)executer:(FixExecuter *)executer log:(NSString *)log
{
    [self appendLog:log];
}

#pragma mark - private

- (NSString *)findPathAtPath:(NSString *)path name:(NSString *)name deep:(NSInteger)deep
{
    if (path.length == 0 || name.length == 0 || deep <= 0) {
        return nil;
    }
    
    NSFileManager *manager = NSFileManager.defaultManager;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *content in contents) {
        if ([content hasPrefix:@"."]) {
            continue;
        }
        NSString *subpath = [path stringByAppendingPathComponent:content];
        if ([content isEqualToString:name]) {
            return subpath;
        }
        NSString *deeper = [self findPathAtPath:subpath name:name deep:deep - 1];
        if (deeper.length) {
            return deeper;
        }
    }
    return nil;
}

- (void)fixWithProjectPath:(NSString *)projectPath codePath:(NSString *)codePath
{
    [self appendLog:@"fix 开始..."];
    
    if (projectPath.length == 0) {
        [self appendLog:self.projectFolderLabel.placeholderString];
        return;
    }
    
    if (codePath.length == 0) {
        [self appendLog:self.codeFolderLabel.placeholderString];
        return;
    }
    
    PodModel *pod = [[PodModel alloc] initWithPath:projectPath];
    if (pod.error) {
        [self appendLog:pod.error.description];
        return;
    }
    
    CodeModel *code = [[CodeModel alloc] initWithPath:codePath];
    [self.executer fix:code pod:pod];
    
    [self appendLog:@"fix 结束"];
}

- (void)checkXibfixWithProjectPath:(NSString *)path
{
    NSMutableArray *checkers = [NSMutableArray array];
    
    PBXMain *main = [[PBXMain alloc] initWithPath:path];
    XIBChecker *mainChecker = [[XIBChecker alloc] initWithObject:main group:nil];
    [mainChecker check];
    [checkers addObject:mainChecker];
    
    PBXMain *pod = [[PBXMain alloc] initWithPath:[path stringByAppendingPathComponent:@"Pods"]];
    PBXGroup *podGroup = nil;
    for (PBXGroup *group in pod.groupSection.groups.allValues) {
        if ([group.name isEqualToString:@"Pods"]) {
            podGroup = group;
            break;
        }
    }
    if (!podGroup) {
        PBXLogging(@"Pods解析失败");
    }
    NSArray *names = podGroup.children.allKeys;
    names = [names sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSString *name in names) {
        PBXGroup *one = podGroup.children[name];
        XIBChecker *podChecker = [[XIBChecker alloc] initWithObject:pod group:one];
        [podChecker check];
        [checkers addObject:podChecker];
    }
    
    // 检查目录内重复
    NSSet *allXibsSet = [SSCommon contentsAtPath:path extensions:[NSSet setWithArray:@[@"xib", @"storyboard"]]];
    NSMutableDictionary *allXibs = [NSMutableDictionary dictionary];
    for (NSString *path in allXibsSet) {
        NSString *name = path.lastPathComponent;
        if (name.length) {
            if (allXibs[name]) {
                NSMutableArray *logs = [NSMutableArray array];
                [logs addObject:[NSString stringWithFormat:@"目录内XIB重复:"]];
                [logs addObject:name];
                [logs addObject:allXibs[name]];
                [logs addObject:path];
                [self appendLog:[logs componentsJoinedByString:@"\n"]];
            }
            allXibs[name] = path;
        }
    }
    
    // 检查引用重复
    NSMutableDictionary *allRefXibs = [NSMutableDictionary dictionary];
    for (XIBChecker *checker in checkers) {
        [[checker allXibReferences] enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *path, BOOL *stop) {
            if (allRefXibs[name]) {
                NSMutableArray *logs = [NSMutableArray array];
                [logs addObject:[NSString stringWithFormat:@"引用XIB重复:"]];
                [logs addObject:name];
                [logs addObject:allXibs[name]];
                [logs addObject:path];
                [self appendLog:[logs componentsJoinedByString:@"\n"]];
            } else {
                allRefXibs[name] = path;
            }
        }];
    }
    
    // 检查目录内未被使用
    NSSet *refXibs = [NSSet setWithArray:allRefXibs.allKeys];
    NSMutableArray *unrefXibs = [NSMutableArray array];
    for (NSString *name in allXibs.allKeys) {
        if (![refXibs containsObject:name]) {
            [unrefXibs addObject:allXibs[name]];
        }
    }
    NSMutableArray *logs = [NSMutableArray array];
    [logs addObject:[NSString stringWithFormat:@"目录内未被使用XIB:"]];
    [unrefXibs sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    [logs addObject:[unrefXibs componentsJoinedByString:@"\n"]];
    [self appendLog:[logs componentsJoinedByString:@"\n"]];
}

- (void)appendLog:(NSString *)text
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        if (text.length == 0) {
            return;
        }
        
        NSString *ret = self.textView.string;
        ret = [ret isKindOfClass:[NSString class]] ? ret : @"";
        NSLog(@"%@", ret);
        
        self.textView.string = [ret stringByAppendingFormat:@"\n\n%@", text];
    }];
}

@end
