//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ArrayTest.h"
#import <iostream>
#import <stdlib.h>

@implementation ArrayTest

+ (void)run
{
    vector<int> v0 = {54, 59, 885};
    
    vector<int> v;
    v.insert(v.end(), v0.begin(), v0.end());
    sort(v.begin(), v.end());
    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }
}

LC_CLASS_END
