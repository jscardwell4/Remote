//
// MSRemoteUITest.h
// Remote
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "UITestRunner.h"

@class REEditingViewController;

typedef void (^ MSRemoteUITestRunner)(NSDictionary * parameters);
typedef void (^ MSRemoteUITestAssertions)(REEditingViewController * editor);

MSKIT_EXTERN_STRING   MSRemoteUIRemoteKey;
MSKIT_EXTERN_STRING   MSRemoteUIButtonGroupKey;
MSKIT_EXTERN_STRING   MSRemoteUIButtonKey;
MSKIT_EXTERN_STRING   MSRemoteUIIterationValuesKey;
MSKIT_EXTERN_STRING   MSRemoteUIAssertionsKey;
MSKIT_EXTERN_STRING   MSRemoteUILogSubviewsKey;
@class                REView;

/**
 *  MSRemoteUITest
 */
@interface MSRemoteUITest : NSObject

@property (nonatomic, assign, getter = shouldSuppressDialog) BOOL   suppressDialog;
@property (nonatomic, assign, readonly) UITestCode                  testCode;

/**
 *  testWithCode:
 */
+ (MSRemoteUITest *)testWithCode:(UITestCode)testCode;

/**
 *  runTest
 */
- (void)runTest;

/**
 *  logTest:
 */
- (void)logTest:(BOOL)testComplete;

/**
 *  logView:after:message:
 */
- (void)logRemoteElementView:(REView *)view
    includingSubelementViews:(NSArray *)subelementViews
                       after:(dispatch_time_t)delay
                     message:(NSString *)message;

@end

/**
 *  ButtonGroupEditingTest
 */
@interface ButtonGroupEditingTest : MSRemoteUITest @end

/**
 *  RemoteEditingTest
 */
@interface RemoteEditingTest : MSRemoteUITest @end
