//
//  main.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSString *appDelegateClassName;
    @autoreleasepool
    {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
