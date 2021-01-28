//
//  HorizontalCollectionViewCell.m
//  Beyond
//
//  Created by ZZZ on 2020/12/31.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "HorizontalCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface HorizontalCollectionViewCell ()

@property (nonatomic, strong) UIView *roundView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation HorizontalCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    UIView *contentView = self.contentView;

    contentView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
    contentView.layer.cornerRadius = 5;
    contentView.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
    contentView.layer.borderColor = UIColor.whiteColor.CGColor;

    _roundView = ({
        UIView *view = [[UIView alloc] init];
        [contentView addSubview:view];
        view.layer.cornerRadius = 5;
        view.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];

        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(contentView);
            make.width.equalTo(contentView).offset(4);
            make.height.equalTo(contentView).offset(4);
        }];

        view;
    });

    _label = ({
        UILabel *view = [[UILabel alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:view];
        view.textColor = UIColor.darkGrayColor;
        view.backgroundColor = UIColor.redColor;
        view.font = [UIFont systemFontOfSize:13];

        [view.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:10].active = YES;
        [view.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:-10].active = YES;
        [view.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:5].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-5].active = YES;
        [view.widthAnchor constraintGreaterThanOrEqualToConstant:10].active = YES;

        view;
    });

    return self;
}

- (void)updateWithTitle:(NSString *)title selected:(BOOL)selected
{
    self.label.text = title;
    self.roundView.hidden = !selected;
}

@end
