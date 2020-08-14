//
//  TFLinearLayoutView.m
//  Pods
//
//  Created by shenlujia on 15/11/18.
//
//

#import "TFLinearLayoutView.h"

//TFLinearLayoutView *layoutView = [[TFLinearLayoutView alloc] initWithFrame:self.view.bounds];
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
//horLayoutView.isVerticalLinearLayout = NO;
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

#ifdef DEBUG
//#define DEBUG_LINEAR_LAYOUT_VIEW
#endif

#pragma mark - TFLinearLayoutItem

@implementation TFLinearLayoutItem

- (instancetype)init
{
    self = [super init];
    
    self.view = nil;
    self.size = CGSizeZero;
    self.minimumWidth = 5;
    self.minimumHeight = 5;
    self.edgeInsets = UIEdgeInsetsZero;
    self.contentMode = TFLinearLayoutContentModeLeft;
    
    return self;
}

@end

#pragma mark - TFLinearLayoutView

@interface TFLinearLayoutView ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation TFLinearLayoutView

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.layoutType = TFLinearLayoutTypeVertical;
    
    return self;
}

- (void)layoutSubviews
{
    CGSize viewSize = self.bounds.size;
    [self reloadItemsWithLimit:(self.layoutType == TFLinearLayoutTypeVertical ? viewSize.width : viewSize.height)];
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self reloadItemsWithLimit:(self.layoutType == TFLinearLayoutTypeVertical ? size.width : size.height)];
    return self.contentSize;
}

#pragma mark - public

- (void)reloadItemsWithLimit:(CGFloat)viewLimit
{
    CGSize contentSize = CGSizeZero;
    if (self.layoutType == TFLinearLayoutTypeVertical) {
        contentSize.width = viewLimit;
    } else {
        contentSize.height = viewLimit;
    }
    for (TFLinearLayoutItem *item in self.items) {
        [self addSubviewWithItem:item contentSize:&contentSize];
    }
    _contentSize = contentSize;
}

#pragma mark - TFLinearLayout

- (void)addItem:(void (^)(TFLinearLayoutItem *item))block
{
    TFLinearLayoutItem *item = [[TFLinearLayoutItem alloc] init];
    if (block) {
        block(item);
    }
    if (!self.items) {
        self.items = [NSMutableArray array];
    }
    if (item.view) {
        [self.items addObject:item];
    }
}

- (void)editItemAtIndex:(NSInteger)index item:(void (^)(TFLinearLayoutItem *item))block
{
    TFLinearLayoutItem *item = nil;
    if (0 <= index && index < self.items.count) {
        item = self.items[index];
    }
    if (block) {
        block(item);
    }
}

- (void)cleanup
{
    for (TFLinearLayoutItem *item in self.items) {
        [item.view removeFromSuperview];
    }
    [self.items removeAllObjects];
}

- (NSUInteger)numberOfItems
{
    return self.items.count;
}

- (NSArray<TFLinearLayoutItem *> *)allItems
{
    return [self.items copy];
}

#pragma mark - private

#ifdef DEBUG_LINEAR_LAYOUT_VIEW

+ (UIColor *)randomColor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand((unsigned int)time(NULL));
    });
    CGFloat red = (arc4random() % 256) / 256.0;
    CGFloat green = (arc4random() % 256) / 256.0;
    CGFloat blue = (arc4random() % 256) / 256.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:0.8];
}

#endif

- (void)addSubviewWithItem:(TFLinearLayoutItem *)item contentSize:(CGSize *)contentSize
{
    // validate
    {
        item.minimumWidth = MAX(item.minimumWidth, 0);
        item.minimumHeight = MAX(item.minimumHeight, 0);
        
        if (item.view.superview != self) {
            [item.view removeFromSuperview];
            [self addSubview:item.view];
        }
#ifdef DEBUG_LINEAR_LAYOUT_VIEW
        item.view.backgroundColor = [TFLinearLayoutView randomColor];
#endif
    }
    
    if (item.view.hidden) {
        return;
    }
    
    UIEdgeInsets insets = item.edgeInsets;
    CGRect itemFrame = CGRectZero;
    itemFrame.size = item.size;
    
    CGFloat maxSize = 0;
    if (self.layoutType == TFLinearLayoutTypeVertical) {
        maxSize = contentSize->width - insets.left - insets.right;
    } else {
        maxSize = contentSize->height - insets.top - insets.bottom;
    }
    
    // sizeThatFits
    if (item.size.width <= 0 || item.size.height <= 0) {
        CGSize fitSize = item.size;
        if (self.layoutType == TFLinearLayoutTypeVertical) {
            fitSize.width = maxSize;
        } else {
            fitSize.height = maxSize;
        }
        if (fitSize.width <= 0) {
            fitSize.width = CGFLOAT_MAX;
        }
        if (fitSize.height <= 0) {
            fitSize.height = CGFLOAT_MAX;
        }
        fitSize = [item.view sizeThatFits:fitSize];
        CGFloat scale = [[UIScreen mainScreen] scale];
        itemFrame.size.width = ceil(fitSize.width * scale) / scale;
        itemFrame.size.height = ceil(fitSize.height * scale) / scale;
    }
    
    if (self.layoutType == TFLinearLayoutTypeVertical) {
        // width
        if (itemFrame.size.width <= 1) {
            // 阈值为1，不要用0，可能有零点几的情况
            itemFrame.size.width = maxSize;
        } else {
            itemFrame.size.width = MIN(itemFrame.size.width, maxSize);
        }
        itemFrame.size.width = MAX(itemFrame.size.width, 0);
        
        // height
        itemFrame.size.height = MAX(itemFrame.size.height, item.minimumHeight);
        
        // x
        switch (item.contentMode) {
            case TFLinearLayoutContentModeLeft: {
                
                itemFrame.origin.x = insets.left;
                
                break;
            }
            case TFLinearLayoutContentModeCenter: {
                
                CGFloat widthRemain = contentSize->width - insets.left - insets.right;
                itemFrame.origin.x = insets.left + (widthRemain - itemFrame.size.width) / 2;
                
                break;
            }
            case TFLinearLayoutContentModeRight: {
                
                itemFrame.origin.x = contentSize->width - itemFrame.size.width - insets.right;
                
                break;
            }
            default: {
                break;
            }
        }
        
        // y
        itemFrame.origin.y = contentSize->height + insets.top;
        contentSize->height = itemFrame.origin.y + itemFrame.size.height + insets.bottom;
        
    } else {
        // height
        if (itemFrame.size.height <= 1) {
            // 阈值为1，不要用0，可能有零点几的情况
            itemFrame.size.height = maxSize;
        } else {
            itemFrame.size.height = MIN(itemFrame.size.height, maxSize);
        }
        itemFrame.size.height = MAX(itemFrame.size.height, 0);
        
        // width
        itemFrame.size.width = MAX(itemFrame.size.width, item.minimumWidth);
        
        // y
        switch (item.contentMode) {
            case TFLinearLayoutContentModeTop: {
                
                itemFrame.origin.y = insets.top;
                
                break;
            }
            case TFLinearLayoutContentModeCenter: {
                
                CGFloat heightRemain = contentSize->height - insets.top - insets.bottom;
                itemFrame.origin.y = insets.top + (heightRemain - itemFrame.size.height) / 2;
                
                break;
            }
            case TFLinearLayoutContentModeBottom: {
                
                itemFrame.origin.y = contentSize->height - itemFrame.size.height - insets.bottom;
                
                break;
            }
            default: {
                break;
            }
        }
        
        // x
        itemFrame.origin.x = contentSize->width + insets.left;
        contentSize->width = itemFrame.origin.x + itemFrame.size.width + insets.right;
    }

    item.view.frame = itemFrame;
    [item.view setNeedsLayout];
    [item.view setNeedsDisplay];
}

@end
