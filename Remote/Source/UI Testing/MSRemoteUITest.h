//
// MSRemoteUITest.h
// Remote
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "UITestRunner.h"

@class RemoteElementEditingViewController;

typedef void (^ MSRemoteUITestRunner)(NSDictionary * parameters);
typedef void (^ MSRemoteUITestAssertions)(RemoteElementEditingViewController * editor);

MSEXTERN_STRING   MSRemoteUIRemoteKey;
MSEXTERN_STRING   MSRemoteUIButtonGroupKey;
MSEXTERN_STRING   MSRemoteUIButtonKey;
MSEXTERN_STRING   MSRemoteUIIterationValuesKey;
MSEXTERN_STRING   MSRemoteUIAssertionsKey;
MSEXTERN_STRING   MSRemoteUILogSubviewsKey;
@class                RemoteElementView;

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
- (void)logRemoteElementView:(RemoteElementView *)view
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
