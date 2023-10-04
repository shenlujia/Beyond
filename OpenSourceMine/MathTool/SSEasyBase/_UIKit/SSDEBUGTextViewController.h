//
//  Created by ZZZ on 2021/11/16.
//

#import <UIKit/UIKit.h>

@interface SSDEBUGTextViewController : UIViewController

@property (nonatomic, strong, readonly) UITextView *textView;

+ (void)showText:(NSString *)text inContainer:(UIViewController *)container;

+ (NSString *)textWithJSONObject:(id)JSONObject;

@end
