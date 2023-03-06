//
//  SSAssetImageGenerator.h
//  Beyond
//
//  Created by ZZZ on 2023/3/1.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SSAssetImageGenerator : NSObject

@property (nonatomic, strong, readonly) AVAssetImageGenerator *generator;

- (instancetype)initWithAsset:(AVAsset *)asset size:(CGSize)size;

- (UIImage *)generaImageWithEdgeInset:(UIEdgeInsets)edgeInset atTime:(CMTime)time;

@end
