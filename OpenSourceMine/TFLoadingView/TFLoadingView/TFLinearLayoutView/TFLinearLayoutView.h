//
//  TFLinearLayoutView.h
//  Pods
//
//  Created by shenlujia on 15/11/18.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TFLinearLayoutType) {
    TFLinearLayoutTypeVertical = 0,
    TFLinearLayoutTypeHorizontal
};

typedef NS_ENUM(NSInteger, TFLinearLayoutContentMode) {
    TFLinearLayoutContentModeLeft = 0,
    TFLinearLayoutContentModeRight,
    TFLinearLayoutContentModeCenter,
    
    TFLinearLayoutContentModeTop = TFLinearLayoutContentModeLeft,
    TFLinearLayoutContentModeBottom = TFLinearLayoutContentModeRight
};

@interface TFLinearLayoutItem : NSObject

@property (nonatomic, strong) __kindof UIView *view;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat minimumWidth; // vertical 时忽略此参数，default 5
@property (nonatomic, assign) CGFloat minimumHeight; // horizontal 时忽略此参数，default 5
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) TFLinearLayoutContentMode contentMode; // default TFLinearLayoutContentModeLeft

@end

@protocol TFLinearLayout <NSObject>
@required
- (void)addItem:(void (^)(TFLinearLayoutItem *item))block;
- (void)editItemAtIndex:(NSInteger)index item:(void (^)(TFLinearLayoutItem *item))block;
- (NSUInteger)numberOfItems;
- (NSArray<TFLinearLayoutItem *> *)allItems;
- (void)cleanup;
@end

@interface TFLinearLayoutView : UIView <TFLinearLayout>

@property (nonatomic, assign) TFLinearLayoutType layoutType;
@property (nonatomic, assign, readonly) CGSize contentSize;

- (void)reloadItemsWithLimit:(CGFloat)viewLimit; // vertical 时为 view 的宽度，horizontal 时为 view 的高度

@end
