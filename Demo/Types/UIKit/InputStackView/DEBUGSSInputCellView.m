//
//  DEBUGSSInputCellView.m
//  ZZZ
//
//  Created by ZZZ on 2025/6/13.
//  Copyright © 2025 SLJ. All rights reserved.
//

#import "DEBUGSSInputCellView.h"

static const CGFloat kStartX = 15;
static const CGFloat kButtonWidth = 60;
static const CGFloat kButtonHeight = 40;

@interface DEBUGSSInputCellView ()

@property (nonatomic, strong, readonly) UITextField *textField;

@end

@implementation DEBUGSSInputCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CGRect fieldFrame = CGRectMake(kStartX, 0, frame.size.width - 2 * kStartX - kButtonWidth, frame.size.height);
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = @"请输入素材地址";
//    textField.pl
    
    return self;
}

- (CGFloat)viewHeight
{
    return 44;
}

@end

@interface DEBUGSSInputTitleView ()

@property (nonatomic, strong, readonly) UILabel *label;

@end

@implementation DEBUGSSInputTitleView

- (CGFloat)viewHeight
{
    return 44;
}

@end

@interface DEBUGSSInputCategoryView ()

@property (nonatomic, strong) DEBUGSSInputCategoryView *titleView;
@property (nonatomic, strong) NSMutableArray *cells;

@end

@implementation DEBUGSSInputCategoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _titleView = [[DEBUGSSInputCategoryView alloc] initWithFrame:frame];
    [self addSubview:_titleView];
    _titleView.frame = CGRectMake(0, 0, frame.size.width, [_titleView viewHeight]);
    _titleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    
    _cells = [NSMutableArray array];
    
    return self;
}

- (void)insertItemWithText:(NSString *)text
{
    DEBUGSSInputCellView *cell = [[DEBUGSSInputCellView alloc] init];
//    cell.inputText = text;
    
    [self.cells addObject:cell];
    [self p_layoutCells];
}

- (void)removeItem:(DEBUGSSInputCellView *)cell
{
    if (!cell) {
        return;
    }
    
    [self.cells removeObject:cell];
    [self p_layoutCells];
}

- (void)p_layoutCells
{
    __block CGRect frame = CGRectMake(0, [self.titleView viewHeight], self.bounds.size.width, 0);
    [[self.cells copy] enumerateObjectsUsingBlock:^(DEBUGSSInputCellView *item, NSUInteger idx, BOOL *stop) {
        frame.size.height = [item viewHeight];
        item.frame = frame;
        item.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        frame.origin.y += frame.size.height;
    }];
    
    [self.delegate inputCategoryViewShouldLayout:self];
}

- (CGFloat)viewHeight
{
    UIView *lastCell = self.cells.lastObject;
    if (!lastCell) {
        return self.titleView.frame.size.height;
    }
    return CGRectGetMaxY(lastCell.frame);
}

@end
