//
//  TFNavigationBarBackButtonItem.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/21.
//

#import "TFNavigationBarBackButtonItem.h"

#pragma mark - TFNavigationBarBackButton

@interface TFNavigationBarBackButton : UIButton

@end

@implementation TFNavigationBarBackButton

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(64, 44);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGSize size = self.bounds.size;
    const CGSize imageSize = self.imageView.image.size;
    
    const CGFloat scaleX = imageSize.width / MAX(size.width, 1);
    const CGFloat scaleY = imageSize.height / MAX(size.height, 1);
    const CGFloat imageScale = MAX(scaleX, scaleY);
    const CGFloat scale = MAX(imageScale, 1);
    
    CGRect frame = CGRectMake(0, 0, imageSize.width / scale, imageSize.height / scale);
    frame.origin.y = (size.height - frame.size.height) / 2;
    self.imageView.frame = frame;
}

@end

#pragma mark - TFNavigationBarBackButtonItem

@implementation TFNavigationBarBackButtonItem

- (UIButton *)button
{
    if (!self.image) {
        return nil;
    }
    
    TFNavigationBarBackButton *view = ({
        [TFNavigationBarBackButton buttonWithType:UIButtonTypeCustom];
    });
    [view setImage:self.image forState:UIControlStateNormal];
    
    return view;
}

- (UIButton *)defaultButton
{
    TFNavigationBarBackButton *view = ({
        [TFNavigationBarBackButton buttonWithType:UIButtonTypeCustom];
    });
    [view setImage:[self p_imageWithName:@"Group"]
          forState:UIControlStateNormal];
    [view setImage:[self p_imageWithName:@"Grouppress"]
          forState:UIControlStateHighlighted];
    return view;
}

- (UIImage *)p_imageWithName:(NSString *)name
{
    NSString *bundleName = @"TFBaseViewController.bundle";
    
    NSString *bundlePath = NSBundle.mainBundle.resourcePath;
    bundlePath = [bundlePath stringByAppendingPathComponent:bundleName];
    if (bundlePath.length == 0) {
        return nil;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (!bundle) {
        return nil;
    }
    
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
