//
// RemoteEditingTest.m
// iPhonto
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSRemoteUITest_Private.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "RemoteConstruction.h"
#import "RemoteElementEditingViewController_Private.h"
#import "RemoteEditingViewController.h"
#import "ButtonGroupView.h"
#import "UITestRunner.h"

// #define DEBUG_CONTEXT  UITESTING_F
#define DEPTH NSUIntegerMax

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

// static const int ddLogLevel = DefaultDDLogLevel
#pragma unused(ddLogLevel)

@implementation RemoteEditingTest
- (void)runTest {
    LOG_QUEUE_NAME;

    uint64_t   testFocus   = (self.testCode & UITestFocusMask);
    uint64_t   testNumber  = (self.testCode & UITestNumberMask) >> UITestNumberOffset;
    uint64_t   testOptions = (self.testCode & UITestOptionsMask) >> UITestOptionsOffset;
    BOOL       quietMode   = (testOptions & 1 ? YES : NO);

    switch (testFocus) {
        case UITestFocusScale :
            switch (testNumber) {
                case 0 : {
                    NSOperationQueue            * queue   = [NSOperationQueue new];
                    RemoteEditingViewController * rEditor = [StoryboardProxy remoteEditingViewController];

                    assert(rEditor);

                    Remote * r = [[RemoteController remoteController] currentRemote];

                    assert(r);
                    rEditor.mockParentSize = MainScreen.bounds.size;
                    rEditor.remoteElement  = r;
                    [AppController.window setRootViewController:rEditor];

                    RemoteView * rv = (RemoteView *)rEditor.sourceView;

                    assert(rv);

                    ButtonGroupView * bgv = (ButtonGroupView *)rv[@"activityButtons"];

                    assert(bgv);
                    [rEditor selectView:bgv];
                    assert([rEditor.selectedViews containsObject:bgv]);

                    NSArray * scales = @[@0.5, @2.0, @1.5, @0.25, @1.0, @4.0];

                    [queue addOperationWithBlock:^{
                               int depth = 0;

                               for (NSNumber * scale in scales) {
                               if (!quietMode)
                               MSLogDebug(DEBUG_CONTEXT, @"%@ scale: %.2f\nbefore scaling button group...\n\n%@\n\n%@\n",
                                       ClassTagSelectorString,
                                       [scale floatValue],
                                       [bgv constraintsDescription],
                                       [bgv framesDescription]);

                               MSRunSyncOnMain (^{
                                [rEditor willScaleSelectedViews];
                               }

                                         );
                               sleep(1);
                               __block CGFloat appliedScale;
                               MSRunSyncOnMain (^{
                                appliedScale = [rEditor scaleSelectedViews:[scale floatValue]
                                                validation:nil];
                               }

                                         );
                               sleep(1);
                               MSRunSyncOnMain (^{
                                [rEditor didScaleSelectedViews];
                               }

                                         );
                               sleep(2);

                               if (!quietMode)
                               MSLogDebug(DEBUG_CONTEXT, @"%@ scale: %.2f\nafter scaling button group...\n\n%@\n\n%@\n",
                                       ClassTagSelectorString,
                                       appliedScale,
                                       [bgv constraintsDescription],
                                       [bgv framesDescription]);

                               if (++depth > DEPTH) break;
                               }
                           }

                    ];
                }
                break;

                default :
                    DDLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, (self.testCode & UITestNumberMask));
                    break;
            }  /* switch */
            break;

        case UITestFocusInfo :
            switch (testNumber) {
                case 0 : {
                    NSOperationQueue            * queue   = [NSOperationQueue new];
                    RemoteEditingViewController * rEditor = [StoryboardProxy remoteEditingViewController];

                    assert(rEditor);

                    Remote * r = [[RemoteController remoteController] currentRemote];

                    assert(r);
                    rEditor.mockParentSize = MainScreen.bounds.size;
                    rEditor.remoteElement  = r;
                    [AppController.window setRootViewController:rEditor];

                    if (quietMode) break;

                    [queue addOperationWithBlock:^{
                               sleep(2);
                               MSLogDebug(DEBUG_CONTEXT, @"%@ autolayout trace...\n%@", ClassTagSelectorString, AutolayoutTraceDescription());
                               sleep(2);
                               MSLogDebug(DEBUG_CONTEXT, @"%@\nbutton group...\n\n%@\n%@\n\n %@\n\\n%@\\n%@",
                               ClassTagSelectorString,
                               [rEditor.sourceView modelConstraintsDescription],
                               [rEditor.sourceView viewConstraintsDescription],
                               [@"subelements" dividerWithCharacterString: @"#"],
                               [[rEditor.sourceView.subelementViews
                                 valueForKeyPath:@"modelConstraintsDescription"] componentsJoinedByString:@"\n\n"],
                               [[rEditor.sourceView.subelementViews
                                 valueForKeyPath:@"viewConstraintsDescription"] componentsJoinedByString:@"\n\n"]);
                           }

                    ];
                }
                break;

                case 1 : {
                    NSOperationQueue            * queue   = [NSOperationQueue new];
                    RemoteEditingViewController * rEditor = [StoryboardProxy remoteEditingViewController];

                    assert(rEditor);

                    Remote * r = [[RemoteController remoteController] remoteWithKey:@"activity1"];

                    assert(r);
                    rEditor.mockParentSize = MainScreen.bounds.size;
                    rEditor.remoteElement  = r;
                    [AppController.window setRootViewController:rEditor];

                    if (quietMode) break;

                    [queue addOperationWithBlock:^{
                               sleep(2);
                               MSLogDebug(DEBUG_CONTEXT, @"%@ autolayout trace...\n%@", ClassTagSelectorString, AutolayoutTraceDescription());
                               sleep(2);
                               MSLogDebug(DEBUG_CONTEXT, @"%@\nbutton group...\n\n%@\n%@\n\n %@\n\n\n%@\n\n%@",
                               ClassTagSelectorString,
                               [rEditor.sourceView modelConstraintsDescription],
                               [rEditor.sourceView viewConstraintsDescription],
                               [@"subelements" dividerWithCharacterString: @"#"],
                               [[rEditor.sourceView.subelementViews
                                 valueForKeyPath:@"modelConstraintsDescription"] componentsJoinedByString:@"\n\n"],
                               [[rEditor.sourceView.subelementViews
                                 valueForKeyPath:@"viewConstraintsDescription"] componentsJoinedByString:@"\n\n"]);
                           }

                    ];
                }
                break;

                default :
                    DDLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, testNumber);
                    break;
            } /* switch */
            break;

        default :
                    DDLogWarn(@"%@ unsupported test focus: %llu", ClassTagSelectorString, testFocus);
            break;
    }         /* switch */
}             /* runRemoteEditorTest */

@end
