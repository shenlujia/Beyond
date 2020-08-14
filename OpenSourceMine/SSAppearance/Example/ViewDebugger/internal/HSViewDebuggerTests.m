//
//  HSViewDebuggerTests.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import "HSViewDebuggerTests.h"

#ifdef TEST_VIEW_DEBUGGER

#import "HSViewDebugUtility.h"
#import "HSViewDebugViewPosition.h"
#import "HSViewDebugViewArrangement.h"

@interface TestView : UIView

@property (nonatomic, copy) NSString *type;

@end

@implementation TestView

@end

@implementation HSViewDebuggerTests

+ (void)load
{
    [self test__HSViewDebugUtility__isView_parentViewOfView];
    [self test__HSViewDebugUtility__commonParentViewOfView_andView];
    [self test__HSViewDebugViewArrangement];
}

+ (void)test__HSViewDebugUtility__isView_parentViewOfView
{
    TestView *rootView = [self p_createView:@"root"];
    TestView *view1 = [self p_createView:@"view1"];
    TestView *view2 = [self p_createView:@"view2"];
    TestView *view3 = [self p_createView:@"view3"];
    
    [rootView addSubview:view1];
    [view1 addSubview:view2];
    
    NSParameterAssert([HSViewDebugUtility isView:rootView parentViewOfView:view1]);
    NSParameterAssert(![HSViewDebugUtility isView:view1 parentViewOfView:rootView]);
    
    NSParameterAssert([HSViewDebugUtility isView:rootView parentViewOfView:view2]);
    NSParameterAssert(![HSViewDebugUtility isView:view2 parentViewOfView:rootView]);
    
    NSParameterAssert(![HSViewDebugUtility isView:rootView parentViewOfView:view3]);
    NSParameterAssert(![HSViewDebugUtility isView:view3 parentViewOfView:rootView]);
}

+ (void)test__HSViewDebugUtility__commonParentViewOfView_andView
{
    TestView *rootView = [self p_createView:@"root"];
    TestView *view_alone = [self p_createView:@"view_alone"];
    TestView *view = [self p_createView:@"view"];
    TestView *view1 = [self p_createView:@"view1"];
    TestView *view2 = [self p_createView:@"view2"];
    TestView *view3 = [self p_createView:@"view3"];
    TestView *view11 = [self p_createView:@"view11"];
    TestView *view12 = [self p_createView:@"view12"];
    TestView *view121 = [self p_createView:@"view121"];
    TestView *view122 = [self p_createView:@"view122"];
    TestView *view1221 = [self p_createView:@"view1221"];
    TestView *view1222 = [self p_createView:@"view1222"];
    TestView *view21 = [self p_createView:@"view21"];
    
    [rootView addSubview:view];
    [view addSubview:view1];
    [view addSubview:view2];
    [view addSubview:view3];
    [view1 addSubview:view11];
    [view1 addSubview:view12];
    [view12 addSubview:view121];
    [view12 addSubview:view122];
    [view122 addSubview:view1221];
    [view122 addSubview:view1222];
    [view2 addSubview:view21];
    
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:rootView andView:view_alone] == nil);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:rootView andView:view] == nil);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:rootView andView:view1] == nil);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:rootView andView:view12] == nil);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:rootView andView:view122] == nil);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view122 andView:rootView] == nil);
    
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view andView:view1] == rootView);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view andView:view12] == rootView);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view andView:view122] == rootView);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view122 andView:view] == rootView);
    
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view1 andView:view12] == view);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view1 andView:view122] == view);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view122 andView:view1] == view);
    
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view21 andView:view1222] == view);
    NSParameterAssert([HSViewDebugUtility commonParentViewOfView:view1222 andView:view21] == view);
}

+ (void)test__HSViewDebugViewArrangement
{
    TestView *rootView = [self p_createView:@"root"];
    rootView.frame = CGRectMake(0, 0, 500, 500);
    
    UIView *view1 = [self p_createView:@"view1"];
    view1.frame = CGRectMake(50, 5, 50, 50);
    [rootView addSubview:view1];
    
    UIView *view2 = [self p_createView:@"view2"];
    view2.frame = CGRectMake(10, 10, 10, 10);
    [rootView addSubview:view2];
    
    UIView *view3 = [self p_createView:@"view3"];
    view3.frame = CGRectMake(15, 15, 10, 10);
    [rootView addSubview:view3];
    
    HSViewDebugViewArrangement *arrangement = [[HSViewDebugViewArrangement alloc] initWithView:rootView];
    NSParameterAssert(arrangement.subviewPositions.count == 3);
    
    for (HSViewDebugViewPosition *position in arrangement.subviewPositions) {
        if (position.view == view1) {
            NSParameterAssert(position.left == 25);
            NSParameterAssert(position.leftView == view3);
        }
    }
}

+ (TestView *)p_createView:(NSString *)title
{
    TestView *view = [[TestView alloc] init];
    view.type = title;
    return view;
}

@end

#endif
