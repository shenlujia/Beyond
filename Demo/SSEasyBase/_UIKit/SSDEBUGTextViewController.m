//
//  SSDEBUGTextViewController.m — stub
//

#import "SSDEBUGTextViewController.h"

@interface SSDEBUGTextViewController ()
@property (nonatomic, copy) NSString *text;
@end

@implementation SSDEBUGTextViewController

+ (void)showText:(NSString *)text inContainer:(UIViewController *)container
{
    if (!container) return;
    SSDEBUGTextViewController *vc = [[SSDEBUGTextViewController alloc] init];
    vc.text = text;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [container presentViewController:nav animated:YES completion:nil];
}

+ (NSString *)textWithJSONObject:(id)object
{
    if (!object) return @"(nil)";
    if ([object isKindOfClass:[NSString class]]) return object;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return [NSString stringWithFormat:@"%@", object];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Debug Text";

    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.text = self.text;
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Menlo" size:12];
    [self.view addSubview:textView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction)];
}

- (void)doneAction { [self dismissViewControllerAnimated:YES completion:nil]; }

@end
