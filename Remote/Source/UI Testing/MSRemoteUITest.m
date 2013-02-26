//
// MSRemoteUITest.m
// iPhonto
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSRemoteUITest_Private.h"
#import "RemoteElementView.h"
#import "RemoteController.h"
#import "CoreDataManager.h"

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

// static const int ddLogLevel = DefaultDDLogLevel
#pragma unused(ddLogLevel)

NSString * const   MSRemoteUIRemoteKey          = @"MSRemoteUIRemoteKey";
NSString * const   MSRemoteUIButtonGroupKey     = @"MSRemoteUIButtonGroupKey";
NSString * const   MSRemoteUIButtonKey          = @"MSRemoteUIButtonKey";
NSString * const   MSRemoteUIIterationValuesKey = @"MSRemoteUIIterationValuesKey";
NSString * const   MSRemoteUIAssertionsKey      = @"MSRemoteUIAssertionsKey";

@implementation MSRemoteUITest

+ (MSRemoteUITest *)testWithCode:(UITestCode)testCode {
    LOG_QUEUE_NAME;

    MSRemoteUITest * test = nil;

    switch ((testCode & UITestTypeMask)) {
        case UITestTypeButtonGroupEditing :
            test = [[ButtonGroupEditingTest alloc] initWithTestCode:testCode];
            break;

        case UITestTypeRemoteEditing :
            test = [[RemoteEditingTest alloc] initWithTestCode:testCode];
            break;

        default :
            MSLogWarn(DEBUG_CONTEXT, @"%@ unsupported test type: %llu",
                      ClassTagSelectorString,
                      (testCode & UITestTypeMask));
            break;
    }

    return test;
}

- (id)initWithTestCode:(UITestCode)testCode {
    if ((self = [super init])) {
        _testCode             = testCode;
        _flags.quietMode      = (((_testCode & UITestOptionsMask) >> UITestOptionsOffset) & 1);
        _flags.suppressDialog = (((_testCode & UITestOptionsMask) >> UITestOptionsOffset) & 2);
        self.objectContext    = [DataManager childContext];
        self.remoteController = [RemoteController remoteControllerInContext:_objectContext];
    }

    return self;
}

- (void)runTest {
    assert(!IsMainQueue);
    LOG_QUEUE_NAME;
    if (!_flags.quietMode) [self logTest:NO];
    [UITestRunner setSuppressDialog:_flags.suppressDialog];
}

- (void)testComplete {
    if (!_flags.quietMode) [self logTest:YES];
}

- (void)logTest:(BOOL)testComplete {
    NSString * testInfo = NSStringFromUITestCode(_testCode);
    NSString * prefix   = (testComplete ? @"  end test - " : @"begin test - ");
    NSString * leftPad  = [NSString stringFilledWithCharacter:' ' count:39 - (testInfo.length + prefix.length) / 2];
    NSString * meat     = [[NSString stringWithFormat:@"%@%@%@", leftPad, prefix, testInfo] stringByPaddingToLength:78 withString:@" " startingAtIndex:0];
    NSString * spacer   = [NSString stringFilledWithCharacter:' ' count:78];
    NSString * message  = [NSString stringWithFormat:@"\u23A7%1$@\u23AB\n\u23A8%2$@\u23AC\n\u23A9%1$@\u23AD\n", spacer, meat];

    MSLogDebug(UITESTING_F_C, @"\n%@", message);
}

- (void)logView:(RemoteElementView *)view after:(dispatch_time_t)delay message:(NSString *)message {
    dispatch_time_t   popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        MSLogDebug(DEBUG_CONTEXT, @"\n%@\n\n%@\n\n%@\n\n%@\n\n%@\n",
                   ([NSString isEmptyString:message]
                    ? @""
                    :[message dividerWithCharacterString:@"#"]),
                   [view constraintsDescription],
                   [view framesDescription],
                   [@"subelements" dividerWithCharacterString: @"#"],
                   [[view.subelementViews valueForKeyPath:@"constraintsDescription"] componentsJoinedByString:@"\n\n"]);
    });
}

@end
