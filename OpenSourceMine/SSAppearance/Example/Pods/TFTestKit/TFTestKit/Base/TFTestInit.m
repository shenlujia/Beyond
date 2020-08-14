//
//  TFTestInit.m
//  EHDComponent
//
//  Created by admin on 2018/7/19.
//

#import "TFTestInit.h"
#import <EHDComponent/EHDComponentConfig.h>

@implementation TFTestInit

+ (void)load
{
    [TFTestInit instance];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self
                   selector:@selector(applicationDidFinishLaunching:)
                       name:UIApplicationDidFinishLaunchingNotification
                     object:nil];
    }
    
    return self;
}

+ (instancetype)instance
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self p_initComponents];
}

- (void)p_initComponents
{
    NSString *path = [NSBundle.mainBundle pathForResource:@"TFTestKit" ofType:@"bundle"];
    if (path.length == 0) {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    path = [bundle pathForResource:@"component" ofType:@"json"];
    if (path.length == 0) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) {
        return;
    }
    
    NSArray *object = ({
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:nil];
    });
    if (![object isKindOfClass:[NSArray class]]) {
        return;
    }
    
    [[EHDComponentConfig defaultConfig] registerComponentStructs:object];
}

@end
