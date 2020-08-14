//
//  AuthLogoutRequest.m
//  Pods
//
//  Created by shenlujia on 2017/9/6.
//
//

#import "AuthLogoutRequest.h"
#import "SSNetworking.h"

@implementation AuthLogoutRequest

- (instancetype)init
{
    self = [super init];
    
    self.URLString = [NSString stringWithFormat:@"%@/r/10001/105", NET_PATH_UDB_RESOURCE];
    
    return self;
}

- (void)startWithBlock:(SSRequestDidFinish)block
{
    __weak typeof (self) weakSelf = self;
    SSRequestDidFinish impl = ^(SSBaseRequest *request, SSRequestResponse *response) {
        if (weakSelf && weakSelf == request) {
            if (!response.error) {
                SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
                [configuration clearSession];
            }
            if (block) {
                block(request, response);
            }
        }
    };
    
    [super startWithBlock:impl];
}

@end
