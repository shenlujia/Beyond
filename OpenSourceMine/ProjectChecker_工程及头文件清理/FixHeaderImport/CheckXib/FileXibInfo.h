//
//  FileXibInfo.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileXibOneItem : NSObject

@property (nonatomic, strong, readonly) NSString *file;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *xib;

@end

@interface FileXibInfo : NSObject

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, copy, readonly) NSArray<FileXibOneItem *> *xibs;

- (instancetype)initWithPath:(NSString *)path;

@end
