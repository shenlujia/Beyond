//
//  TFBaseStorage.h
//  EHD
//
//  Created by admin on 2018/5/22.
//

#import <Foundation/Foundation.h>

@protocol TFBaseStorageProtocol <NSObject>
@required
- (NSString *)storagePath;
- (NSString *)storageIdentifier;
@end

@interface TFBaseStorage : NSObject

- (NSMutableDictionary *)_storage;

@end
