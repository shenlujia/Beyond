//
//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasyFixBeyond.h"
#import <fishhook/fishhook.h>

NSString * beyond_entryClassName(void)
{
    NSString *name = nil;
    name = @"ViewController";
    name = @"DEBUGPanelController";
    name = @"SSFoundationController";
//    name = @"UIKitController";
    return name;
}

void open_bdfishhook(void)
{
    
}

int bd_rebind_symbols(struct rebinding array[], size_t n)
{
    return rebind_symbols(array, n);
}
