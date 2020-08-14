//
//  TFLoadingStyle.h
//  Pods
//
//  Created by shenlujia on 16/10/14.
//
//

#import <TFAppearance/TFAppearance.h>

@interface TFLoadingStyle : TFBaseObject

@property (nonatomic, assign) UIControlContentVerticalAlignment verticalAlignment;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, assign) CGFloat itemHorizontalMargin;
@property (nonatomic, assign) CGFloat itemVerticalMargin;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, copy) void (^buttonTapBlock)(void);
@property (nonatomic, strong) TFAppearanceButtonStyle *buttonStyle;
@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, assign) CGFloat buttonCornerRadius;
@property (nonatomic, copy) NSString *buttonNormalTitle;
@property (nonatomic, copy) NSString *buttonHighlightedTitle;

@end
