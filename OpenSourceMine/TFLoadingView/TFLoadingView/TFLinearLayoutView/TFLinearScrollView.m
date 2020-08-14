//
//  TFLinearScrollView.m
//  Pods
//
//  Created by shenlujia on 16/5/5.
//
//

#import "TFLinearScrollView.h"

//TFLinearScrollView *layoutView = [TFLinearScrollView viewWithType:TFLinearLayoutTypeVertical];
//layoutView.frame = self.view.bounds;
//layoutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//layoutView.backgroundColor = [UIColor darkGrayColor];
//[layoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"asflknwelkjnewlvnjkrnvflnfklwnjvklwlnefrwewerfwernwefvwr";
//    item.view = label;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[layoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"asflknwelkjnewlvnjkrnvkfwenlkjnlejkrvnelknwkncwknckenwkencknckwcewncdflnfklwnjvklwlnefrwewerfwernwefvwr";
//    item.view = label;
//    label.numberOfLines = 0;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[layoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"222";
//    item.view = label;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//TFLinearLayoutView *horLayoutView = [[TFLinearLayoutView alloc] init];
//horLayoutView.layoutType = TFLinearLayoutTypeHorizontal;
//
//[horLayoutView addItem:^(TFLinearLayoutItem *item) {
//    UIView *view = [[UIView alloc] init];
//    item.size = CGSizeMake(50, 50);
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[horLayoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"111";
//    item.view = label;
//    item.contentMode = TFLinearLayoutContentModeCenter;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[horLayoutView addItem:^(TFLinearLayoutItem *item) {
//    UIView *view = [[UIView alloc] init];
//    item.view = view;
//    item.size = CGSizeMake(50, 50);
//    item.contentMode = TFLinearLayoutContentModeCenter;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//TFLinearLayoutView *subLayoutView = [[TFLinearLayoutView alloc] init];
//[subLayoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"1";
//    item.view = label;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//[subLayoutView addItem:^(TFLinearLayoutItem *item) {
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"2";
//    item.view = label;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[subLayoutView reloadItemsWithLimit:100];
//CGSize contentSize = subLayoutView.contentSize;
//
//[horLayoutView addItem:^(TFLinearLayoutItem *item) {
//    item.view = subLayoutView;
//    item.size = contentSize;
//    item.contentMode = TFLinearLayoutContentModeCenter;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[horLayoutView reloadItemsWithLimit:200];
//contentSize = horLayoutView.contentSize;
//
//[layoutView addItem:^(TFLinearLayoutItem *item) {
//    item.view = horLayoutView;
//    item.size = contentSize;
//    item.contentMode = TFLinearLayoutContentModeCenter;
//    item.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//}];
//
//[self.view addSubview:layoutView];

@interface TFLinearScrollView ()

@property (nonatomic, assign) CGSize viewSize;
@property (nonatomic, strong, readonly) TFLinearLayoutView *linearView;

@end

@implementation TFLinearScrollView

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _linearView = [[TFLinearLayoutView alloc] init];
    _placeType = TFLinearScrollViewPlaceContentTypeMiddle;
    [self addSubview:self.linearView];
    
    return self;
}

- (instancetype)initWithType:(TFLinearLayoutType)type
{
    self = [self init];
    self.linearView.layoutType = type;
    return self;
}

- (void)layoutSubviews
{
    if (!CGSizeEqualToSize(self.viewSize, self.bounds.size)) {
        self.viewSize = self.bounds.size;
        [self reloadData];
    }
    [super layoutSubviews];
}

#pragma mark - public

- (void)reloadData
{
    const CGSize size = self.bounds.size;
    TFLinearLayoutType type = self.linearView.layoutType;
    CGFloat limit = (type == TFLinearLayoutTypeVertical) ? size.width : size.height;
    [self.linearView reloadItemsWithLimit:limit];
    
    const CGSize linearSize = self.linearView.contentSize;
    CGSize contentSize = linearSize;
    CGRect frame = CGRectMake(0, 0, linearSize.width, linearSize.height);
    
    switch (self.placeType) {
        case TFLinearScrollViewPlaceContentTypeMiddle: {
            
            if (type == TFLinearLayoutTypeVertical) {
                frame.origin.x = (size.width - linearSize.width) / 2;
                frame.origin.y = MAX((size.height - linearSize.height) / 2, 0);
                contentSize.width = size.width;
            } else {
                frame.origin.x = MAX((size.width - linearSize.width) / 2, 0);
                frame.origin.y = (size.height - linearSize.height) / 2;
                contentSize.height = size.height;
            }
            
            break;
        }
        case TFLinearScrollViewPlaceContentTypeTop: {
            
            if (type == TFLinearLayoutTypeVertical) {
                frame.origin.x = (size.width - linearSize.width) / 2;
                frame.origin.y = 0;
                contentSize.width = size.width;
            } else {
                frame.origin.x = 0;
                frame.origin.y = (size.height - linearSize.height) / 2;
                contentSize.height = size.height;
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
    self.linearView.frame = frame;
    self.contentSize = contentSize;
}

- (void)scrollToIndex:(NSInteger)index
           atPosition:(TFLinearViewScrollPosition)position
             animated:(BOOL)animated
{
    UIView *view = nil;
    NSArray *items = [self allItems];
    if (0 <= index && index < items.count) {
        TFLinearLayoutItem *item = items[index];
        view = item.view;
    }
    [self scrollToView:view atPosition:position animated:animated];
}

- (void)scrollToView:(UIView *)view
          atPosition:(TFLinearViewScrollPosition)position
            animated:(BOOL)animated
{
    const CGRect rect = [self convertRect:view.frame fromView:view.superview];
    const CGFloat selfHeight = CGRectGetHeight(self.bounds);
    
    CGPoint offset = CGPointZero;
    switch (position) {
        case TFLinearViewScrollPositionMiddle: {
            offset.y = CGRectGetMidY(rect) - selfHeight;
            break;
        }
        case TFLinearViewScrollPositionBottom: {
            offset.y = CGRectGetMaxY(rect) - selfHeight;
            break;
        }
        default: {
            offset.y = rect.origin.y;
            break;
        }
    }

    // 先MIN 再MAX
    offset.y = MIN(offset.y, self.contentSize.height - selfHeight);
    offset.y = MAX(offset.y, 0);
    
    [self setContentOffset:offset animated:animated];
}

#pragma mark - TFLinearLayout

- (void)addItem:(void (^)(TFLinearLayoutItem *item))block
{
    [self.linearView addItem:block];
}

- (void)editItemAtIndex:(NSInteger)index item:(void (^)(TFLinearLayoutItem *item))block
{
    [self.linearView editItemAtIndex:index item:block];
}

- (NSUInteger)numberOfItems
{
    return [self.linearView numberOfItems];
}

- (NSArray<TFLinearLayoutItem *> *)allItems
{
    return [self.linearView allItems];
}

- (void)cleanup
{
    [self.linearView cleanup];
    self.contentSize = CGSizeZero;
}

@end
