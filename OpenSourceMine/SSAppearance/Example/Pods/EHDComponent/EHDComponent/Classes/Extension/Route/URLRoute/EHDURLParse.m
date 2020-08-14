//
//  EHDURLParse.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDURLParse.h"

/**
 *  URL列表
 */
static NSMutableDictionary<NSString *, NSDictionary *> *URLRouteTable_;

NSString *const EHDURL = @"EHDURL";
NSString *const EHDURLPATH = @"EHDURLPATH";

@implementation EHDURLParse
#pragma mark - routes
+ (NSMutableDictionary *)routes
{
    if (URLRouteTable_ == nil) {
        URLRouteTable_ = [NSMutableDictionary dictionary];
    }
    return URLRouteTable_;
}

#pragma mark - URL Register
+ (void)addURLPattern:(NSString *)URLPattern handler:(id (^)(NSDictionary *parameters))handler
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (handler && subRoutes) {
        subRoutes[@"_"] = [handler copy];
    }
}

+ (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern
{
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    NSMutableDictionary *subRoutes = [self routes];
    NSUInteger index = 0;
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (!subRoutes[pathComponent]) {
            subRoutes[pathComponent] = [NSMutableDictionary dictionary];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    return subRoutes;
}

#pragma mark - URL Deregister
+ (void)deregisterURLPattern:(NSString *)URLPattern
{
    [self removeURLPattern:URLPattern];
}

+ (void)removeURLPattern:(NSString *)URL
{
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[self pathComponentsFromURL:URL]];
    /* 只删除 pattern 的最后一级 */
    if (pathComponents.count) {
        NSString *component = [pathComponents componentsJoinedByString:@"."];
        NSMutableDictionary *subRoutes = [self.routes valueForKeyPath:component];
        if (subRoutes.count) {
            NSString *lastComponent = pathComponents.lastObject;
            [pathComponents removeLastObject];
            subRoutes = self.routes;
            if (pathComponents.count) {
                NSString *componentWithOutLast = [pathComponents componentsJoinedByString:@"."];
                subRoutes = [self.routes valueForKeyPath:componentWithOutLast];
            }
            [subRoutes removeObjectForKey:lastComponent];
        }
    }
}

#pragma mark - Utils
+ (NSMutableDictionary *)extractParametersFromURL:(NSString *)URL
{
    NSMutableDictionary *parameters = @{}.mutableCopy;
    parameters[EHDURL] = URL;
    parameters[EHDURLPATH] = [self pathFromURL:URL];
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromURL:URL];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = [subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSString *key in subRoutesKeys) {
            if ([pathComponent isEqualToString:key] ||
                [key isEqualToString:@"~"]) {
                found = YES;
                subRoutes = subRoutes[key];
                break;
            }
        }
        //未找到时直接匹配第一方法作为URL的fallback
        if (!found && !subRoutes[@"_"]) {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:pathComponents.firstObject];
            [array addObject:@"~"];
            [array addObject:@"_"];
            NSString *key = [array componentsJoinedByString:@"."];
            parameters[@"block"] = [[self.routes valueForKeyPath:key] copy];
            return parameters;
        }
    }

    [parameters addEntriesFromDictionary:[self paramsFromURL:URL]];
    
    if (subRoutes[@"_"]) {
        parameters[@"block"] = [subRoutes[@"_"] copy];
    }
    return parameters;
}

+ (NSArray *)pathComponentsFromURL:(NSString *)URL
{
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *pathComponents = @[].mutableCopy;
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        [pathComponents addObject:pathSegments[0]];
        URL = pathSegments.lastObject;
        if (!URL.length) {
            [pathComponents addObject:@"~"];
        }
    }
    
    for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    return [NSArray arrayWithArray:pathComponents];
}

+ (NSDictionary *)paramsFromURL:(NSString *)URL
{
    // Extract Params From Query.
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray<NSURLQueryItem *> *queryItems = [NSURLComponents componentsWithURL:[NSURL URLWithString:URL] resolvingAgainstBaseURL:NO].queryItems;
    for (NSURLQueryItem *item in queryItems) {
        parameters[item.name] = item.value;
    }
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

+ (NSString *)pathFromURL:(NSString *)URL
{
    NSArray<NSString *> *urlComponents = [URL componentsSeparatedByString:@"?"];
    if (urlComponents && urlComponents.count) {
        return urlComponents[0];
    }
    return URL;
}

+ (NSString *)lastPathComponentForURL:(NSString *)URL
{
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:URL];
    NSString *lastComp = url.lastPathComponent;
    if ([lastComp isEqualToString:@""]) {
        lastComp = url.host;
    }
    return lastComp;
}
@end
