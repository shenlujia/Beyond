//
//  TFLinearScrollView.h
//  Pods
//
//  Created by shenlujia on 16/5/5.
//
//

#import <UIKit/UIKit.h>
#import "TFLinearLayoutView.h"

typedef NS_ENUM(NSInteger, TFLinearViewScrollPosition) {
    TFLinearViewScrollPositionNone,
    TFLinearViewScrollPositionTop,
    TFLinearViewScrollPositionMiddle,
    TFLinearViewScrollPositionBottom
};

typedef NS_ENUM(NSInteger, TFLinearScrollViewPlaceContentType) {
    TFLinearScrollViewPlaceContentTypeMiddle = 0, // default
    TFLinearScrollViewPlaceContentTypeTop
};

@interface TFLinearScrollView : UIScrollView <TFLinearLayout>

@property (nonatomic, assign) TFLinearScrollViewPlaceContentType placeType;

- (instancetype)initWithType:(TFLinearLayoutType)type;

- (void)reloadData;

- (void)scrollToIndex:(NSInteger)index
           atPosition:(TFLinearViewScrollPosition)position
             animated:(BOOL)animated;

- (void)scrollToView:(UIView *)view
          atPosition:(TFLinearViewScrollPosition)position
            animated:(BOOL)animated;

@end
