//
//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasyFixBeyond.h"
#import <fishhook/fishhook.h>
#import "_Foundation.h"

@implementation FBRetainCycleDetector (SSEasyFixBeyond)

- (NSSet<NSArray<FBObjectiveCGraphElement *> *> *)findRetainCyclesWithMaxCycleLength:(NSUInteger)maxCycleLength maxTraversedNodeNumber:(NSUInteger)maxTraversedNodeNumber maxCycleNum:(NSUInteger)maxCycleNum
{
    return [self findRetainCyclesWithMaxCycleLength:maxCycleLength];
}

@end

NSString * beyond_entryClassName(void)
{
    NSString *name = nil;
    name = @"ViewController";
//    name = @"DEBUGPanelController";
//    name = @"SSFoundationController";
//    name = @"UIKitController";
//    name = @"MapTableLeakController";
    return name;
}

void open_bdfishhook(void)
{
    
}

int bd_rebind_symbols(struct rebinding array[], size_t n)
{
    return rebind_symbols(array, n);
}
