//
// MSRemoteUITest.m
// Remote
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSRemoteUITest_Private.h"
#import "REView.h"
#import "RERemoteController.h"
#import "CoreDataManager.h"

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = UITESTING_F;
// static const int ddLogLevel = DefaultDDLogLevel
#pragma unused(ddLogLevel)

MSKIT_STRING_CONST   MSRemoteUIRemoteKey          = @"MSRemoteUIRemoteKey";
MSKIT_STRING_CONST   MSRemoteUIButtonGroupKey     = @"MSRemoteUIButtonGroupKey";
MSKIT_STRING_CONST   MSRemoteUIButtonKey          = @"MSRemoteUIButtonKey";
MSKIT_STRING_CONST   MSRemoteUIIterationValuesKey = @"MSRemoteUIIterationValuesKey";
MSKIT_STRING_CONST   MSRemoteUIAssertionsKey      = @"MSRemoteUIAssertionsKey";
MSKIT_STRING_CONST   MSRemoteUILogSubviewsKey     = @"MSRemoteUILogSubviewsKey";

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
            MSLogWarn(@"%@ unsupported test type: %llu",
                      ClassTagSelectorString,
                      (testCode & UITestTypeMask));
            break;
    }

    return test;
}

- (id)initWithTestCode:(UITestCode)testCode {
    if (self = [super init]) {
        _testCode             = testCode;
        _flags.quietMode      = (((_testCode & UITestOptionsMask) >> UITestOptionsOffset) & 1);
        _flags.suppressDialog = (((_testCode & UITestOptionsMask) >> UITestOptionsOffset) & 2);
        self.objectContext    = [CoreDataManager childContextForContext:nil
                                                        concurrencyType:NSMainQueueConcurrencyType
                                                            undoSupport:NO
                                                                nametag:@"uitesting"];
        self.remoteController = [RERemoteController remoteControllerInContext:_objectContext];
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
    MSLogDebug(@"%@%@", prefix, testInfo);
//    NSString * leftPad  = [NSString stringFilledWithCharacter:' '
//                                                        count:39 - (testInfo.length + prefix.length) / 2];
//    NSString * meat     = [$(@"%@%@%@", leftPad, prefix, testInfo) stringByPaddingToLength:78
//                                                                                withString:@" "
//                                                                           startingAtIndex:0];
//    NSString * spacer   = [NSString stringFilledWithCharacter:' ' count:78];
//    NSString * message  = $(@"\u23A7%1$@\u23AB\n\u23A8%2$@\u23AC\n\u23A9%1$@\u23AD\n", spacer, meat);

//    MSLogDebug(@"\n%@", message);
//    MSLogDebug(@"%@", meat);
}

- (void)logRemoteElementView:(REView *)view
    includingSubelementViews:(NSArray *)subelementViews
                       after:(dispatch_time_t)delay
                     message:(NSString *)message
{
//    assert(OnMainQueue);
    dispatch_time_t   popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));

    NSString * messageString = ([NSString isEmptyString:message]
                                ? @""
                                :message /*[message dividerWithCharacterString:@"#"]*/);
    NSString * viewString = $(@"%@%@\n%@\n\n%@",
                              [$(@"%@", view.displayName) singleBarMessageBox],
                              [view modelConstraintsDescription],
                              [view viewConstraintsDescription],
                              [view framesDescription]);
    NSString * subelementsString = @"";
    if (subelementViews.count) {
        subelementsString = $(@"%@\n\n%@\n",
                              [@"subelements" dividerWithCharacterString: @"#"],
                              [[subelementViews
                               arrayByMappingToBlock:^NSString *(NSString * key, NSUInteger idx) {
                                   return $(@"%@%@\n%@",
                                            [$(@"%@", view[key].displayName) singleBarMessageBox],
                                            [view[key] modelConstraintsDescription],
                                            [view[key] viewConstraintsDescription]);
                               }] componentsJoinedByString:@"\n\n"]);
    }

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        MSLogDebug(@"%@\n\n%@\n\n%@\f",
                   messageString,
                   viewString,
                   subelementsString);
    });
}

@end
