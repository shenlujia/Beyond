//
//  RichTextView.h
//  RichText
//
//  Created by SLJ on 2020/7/24.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RichTextView : UIView

@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIFont *font;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat space;

@property (nonatomic, strong) UIImage *image;

- (void)reloadData;

@end
