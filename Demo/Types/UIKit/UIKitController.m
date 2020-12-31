//
//  UIKitController.m
//  Demo
//
//  Created by SLJ on 2020/7/30.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "UIKitController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wdivision-by-zero"
#pragma clang diagnostic ignored "-Wunreachable-code"

@interface UIKitController ()

@end

@implementation UIKitController

- (void)viewDidLoad
{
    [super viewDidLoad];

    printf("0 / 0 = %f    Division by zero is undefined \n", (float)(0 / 0));
    printf("0.0 / 0.0 = %f \n", 0.0 / 0.0);
    printf("0 / 0.0 = %f \n", 0 / 0.0);
    printf("0.0 / 0 = %f \n", 0.0 / 0);
    printf("1 / 0 = %f    Division by zero is undefined \n", (float)(1 / 0));
    printf("1.0 / 0 = %f \n", 1.0 / 0);
    printf("-1.0 / 0 = %f \n", -1.0 / 0);
    printf("======\n");
    printf("INFINITY * 0 = %f \n", INFINITY * 0);
    printf("INFINITY * 0.0 = %f \n", INFINITY * 0.0);
    printf("INFINITY * 0.1 = %f \n", INFINITY * 0.1);
    printf("0.0 / INFINITY = %f \n", 0.0 / INFINITY);
    printf("1.0 / INFINITY = %f \n", 1.0 / INFINITY);
    printf("INFINITY - INFINITY = %f \n", INFINITY - INFINITY);
    printf("INFINITY + INFINITY = %f \n", INFINITY + INFINITY);
    printf("INFINITY / 0 = %f \n", INFINITY / 0);
    printf("INFINITY / 0.0 = %f \n", INFINITY / 0.0);
    printf("INFINITY + 1.0 = %f \n", INFINITY + 1.0);
    printf("INFINITY / INFINITY = %f \n", INFINITY / INFINITY);
    printf("INFINITY > 1: %s \n", INFINITY > 1 ? "true" : "false");
    printf("INFINITY < 1: %s \n", INFINITY < 1 ? "true" : "false");
    printf("======\n");
    printf("0 / NAN = %f \n", 0 / NAN);
    printf("0.0 / NAN = %f \n", 0.0 / NAN);
    printf("0.1 / NAN = %f \n", 0.1 / NAN);
    printf("NAN / 0 = %f \n", NAN / 0);
    printf("NAN / 0.0 = %f \n", NAN / 0.0);
    printf("NAN / 1.0 = %f \n", NAN / 1.0);
    printf("NAN / NAN = %f \n", NAN / NAN);
    printf("NAN * 0 = %f \n", NAN * 0);
    printf("NAN * 0.0 = %f \n", NAN * 0.0);
    printf("NAN * 0.1 = %f \n", NAN * 0.1);
    printf("NAN - NAN = %f \n", NAN - NAN);
    printf("NAN > 1: %s \n", NAN > 1 ? "true" : "false");
    printf("NAN < 1: %s \n", NAN < 1 ? "true" : "false");
    printf("======\n");
    printf("sizeof(int) = %d    sizeof(float) = %d \n", (int)sizeof(int), (int)sizeof(float));
    printf("sizeof(NAN) = %d    sizeof(INFI) = %d \n", (int)sizeof(NAN), (int)sizeof(INFINITY));

    [self test_c:@"HorizontalCollectionView"];

    [self test_c:@"Gesture"];
    
    [self test_c:@"Appearance"];
    
    [self test_c:@"Control"];
}

@end

#pragma clang diagnostic pop
