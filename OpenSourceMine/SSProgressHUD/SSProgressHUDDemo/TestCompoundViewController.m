//
//  TestCompoundViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestCompoundViewController.h"
#import "SSProgressHUDCompoundView.h"
#import "SSProgressHUDLabel.h"

@interface TestCompoundViewController ()

@end

@implementation TestCompoundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    item = [[UIBarButtonItem alloc] initWithTitle:@"更多4"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(more4Test)];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithTitle:@"更多3"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(more3Test)];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithTitle:@"更多2"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(more2Test)];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithTitle:@"更多1"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(more1Test)];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithTitle:@"一列"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(verticalTest)];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithTitle:@"一行"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(horizontalTest)];
    [items addObject:item];
    self.navigationItem.rightBarButtonItems = items;
    
    [self horizontalTest];
}

- (void)horizontalTest
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:nil other:view1 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:nil vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.6);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (void)verticalTest
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.8);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (void)more1Test
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.8);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (void)more2Test
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.8);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (void)more3Test
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.8);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:NO space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:NO space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (void)more4Test
{
    for (UIView *view in [self.view.subviews copy]) {
        [view removeFromSuperview];
    }
    
    const CGSize size = self.view.bounds.size;
    CGRect frame = CGRectZero;
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = result;
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 0.8, result.height);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width, result.height * 0.8);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
    
    {
        UIView *view = ({
            UILabel *view0 = [self createTestLabel0];
            UILabel *view1 = [self createTestLabel1];
            UILabel *view2 = [self createTestLabel1];
            UIView *view = [[SSProgressHUDCompoundView alloc] initWithView:view0 other:view1 vertical:YES space:5];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view other:view2 vertical:YES space:5];
            view.backgroundColor = [UIColor greenColor];
            [self.view addSubview:view];
            view;
        });
        
        CGSize result = [view sizeThatFits:size];
        frame.size = CGSizeMake(result.width * 1.2, result.height * 1.5);
        view.frame = frame;
        
        frame.origin.y += frame.size.height + 15;
    }
}

- (UILabel *)createTestLabel0
{
    UILabel *view0 = ({
        UILabel *view = [[SSProgressHUDLabel alloc] init];
        view.font = [UIFont systemFontOfSize:20];
        view.backgroundColor = [UIColor brownColor];
        view.text = @"1234567890";
        view;
    });
    return view0;
}

- (UILabel *)createTestLabel1
{
    UILabel *view0 = ({
        UILabel *view = [[SSProgressHUDLabel alloc] init];
        view.font = [UIFont systemFontOfSize:12];
        view.backgroundColor = [UIColor lightGrayColor];
        view.text = @"1234567890";
        view;
    });
    return view0;
}

@end
