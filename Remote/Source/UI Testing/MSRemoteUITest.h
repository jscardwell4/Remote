//
// MSRemoteUITest.h
// iPhonto
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "UITestRunner.h"

typedef void (^ MSRemoteUITestRunner)(NSDictionary * parameters);
typedef void (^ MSRemoteUITestAssertions)(NSDictionary * variables);

MSKIT_EXTERN_STRING   MSRemoteUIRemoteKey;
MSKIT_EXTERN_STRING   MSRemoteUIButtonGroupKey;
MSKIT_EXTERN_STRING   MSRemoteUIButtonKey;
MSKIT_EXTERN_STRING   MSRemoteUIIterationValuesKey;
MSKIT_EXTERN_STRING   MSRemoteUIAssertionsKey;
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
- (void)logView:(RemoteElementView *)view after:(dispatch_time_t)delay message:(NSString *)message;

@end

/**
 *  ButtonGroupEditingTest
 */
@interface ButtonGroupEditingTest : MSRemoteUITest @end

/**
 *  RemoteEditingTest
 */
@interface RemoteEditingTest : MSRemoteUITest @end
