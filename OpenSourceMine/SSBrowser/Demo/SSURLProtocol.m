//
//  SSURLProtocol.m
//  Demo
//
//  Created by ZZZ on 2020/10/27.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SSURLProtocol.h"

static NSString * const SSURLHandleKey = @"SSURLHandleKey";

@interface SSURLProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;

@end

@implementation SSURLProtocol

+ (void)load
{
//    Class cls = NSClassFromString(@"WKBrowsingContextController");
//    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
//    if ([cls respondsToSelector:sel]) {
//        [cls performSelector:sel withObject:@"http"];
//        [cls performSelector:sel withObject:@"https"];
//    }
//    [NSURLProtocol registerClass:[SSURLProtocol class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([self propertyForKey:SSURLHandleKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{


    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [newRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15" forHTTPHeaderField:@"User-Agent"];
    [NSURLProtocol setProperty:@(YES) forKey:SSURLHandleKey inRequest:newRequest];

    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    self.mutableData = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];

    [self.mutableData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
