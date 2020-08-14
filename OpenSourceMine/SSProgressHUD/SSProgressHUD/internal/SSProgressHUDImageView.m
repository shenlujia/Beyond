//
//  SSProgressHUDImageView.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDImageView.h"

@implementation SSProgressHUDImageView

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = self.image.size;
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGSizeZero;
    }
    
    if (imageSize.width > size.width ||
        imageSize.height > size.height) {
        const CGFloat scaleX = size.width / imageSize.width;
        const CGFloat scaleY = size.height / imageSize.height;
        const CGFloat scale = MIN(scaleX, scaleY);
        imageSize.width *= scale;
        imageSize.height *= scale;
    }
    return imageSize;
}

@end
