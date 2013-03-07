//
// ButtonGroupEditingTest.m
// iPhonto
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSRemoteUITest_Private.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "RemoteElement_Private.h"
#import "RemoteElementLayoutConstraint.h"
#import "RemoteConstruction.h"
#import "RemoteElementEditingViewController_Private.h"
#import "ButtonGroupEditingViewController.h"
#import "ButtonGroupView.h"
#import "UITestRunner.h"

// #define DEBUG_CONTEXT  UITESTING_F
#define DEPTH 1 //NSUIntegerMax

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = UITESTING_F_C;

// static const int ddLogLevel = DefaultDDLogLevel
#pragma unused(ddLogLevel)

@implementation ButtonGroupEditingTest

- (void)runTest {
    [super runTest];
    uint64_t   testFocus   = (self.testCode & UITestFocusMask);
    uint64_t   testNumber  = (self.testCode & UITestNumberMask) >> UITestNumberOffset;
    uint64_t   testOptions = (self.testCode & UITestOptionsMask) >> UITestOptionsOffset;

    switch (testFocus) {
        case UITestFocusTranslation :
            [self runTranslationTestNumber:testNumber options:testOptions]; break;
        case UITestFocusFocus :
            [self runFocusTestNumber:testNumber options:testOptions];       break;
        case UITestFocusAlignment :
            [self runAlignmentTestNumber:testNumber options:testOptions];   break;
        case UITestFocusInfo :
            [self runInfoTestNumber:testNumber options:testOptions];        break;
        case UITestFocusDialog :
            [self runDialogTestNumber:testNumber options:testOptions];      break;
        case UITestFocusScale :
            [self runScaleTestNumber:testNumber options:testOptions];       break;
        default : MSLogWarn(@"%@ unsupported test focus: %llu", ClassTagSelectorString, testFocus);
    }  /* switch */
    sleep(SLEEP_DURATION);
    [self testComplete];
}

- (void)runTranslationTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    LOG_QUEUE_NAME;

    MSRemoteUITestRunner   performTranslations = ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;
        __block ButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSString * buttonKey      = parameters[MSRemoteUIButtonKey];
        NSArray  * translations   = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];

        [MainQueue addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                                  assert(bgEditor && !bgEditor.sourceView);
                                                  bg = self.remoteController[remoteKey][buttonGroupKey];
                                                  assert(bg);
                                                  bgEditor.mockParentSize = MainScreen.bounds.size;
                                                  bgEditor.remoteElement = bg;
                                                  [AppController.window setRootViewController:bgEditor];
                                                  bgv = (ButtonGroupView *)bgEditor.sourceView;
                                                  assert(bgv);
                                                  bv = (ButtonView *)bgv[buttonKey];
                                                  assert(bv);
                                                  [bgEditor selectView:bv];
                                                  assert([bgEditor.selectedViews containsObject:bv]);)]
               waitUntilFinished:YES];

        int   depth = 0;

        for (NSValue * translation in translations) {
            if (!depth && !_flags.quietMode)
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"before translation: %@", NSStringFromCGPoint(Point(translation))]];

            [MainQueue addOperations:@[BlockOperation([bgEditor willMoveSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation([bgEditor moveSelectedViewsWithTranslation:Point(translation)];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation([bgEditor didMoveSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            if (!_flags.quietMode)
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"after translation: %@", NSStringFromCGPoint(Point(translation))]];

            if (++depth > DEPTH) break;
        }
    };

    switch (testNumber) {
        case 0 :
            performTranslations(@{
                                    MSRemoteUIRemoteKey : MSRemoteControllerHomeRemoteKeyName,
                                    MSRemoteUIButtonGroupKey : @"activityButtons",
                                    MSRemoteUIButtonKey : @"activity1",
                                    MSRemoteUIIterationValuesKey : @[
                                                                     PointValue(CGPointMake(0, -48)),
                                                                     PointValue(CGPointMake(0, 248)),
                                                                     PointValue(CGPointMake(0, -200)),
                                                                     PointValue(CGPointMake(-9, -32)),
                                                                     PointValue(CGPointMake(32.5, 72)),
                                                                     PointValue(CGPointMake(1, 146)),
                                                                     PointValue(CGPointMake(-24.5, -186))
                                    ]
                                });
            break;

        case 1 :
            performTranslations(@{
                                    MSRemoteUIRemoteKey : @"activity1",
                                    MSRemoteUIButtonGroupKey : kTopPanelOneKey,
                                    MSRemoteUIButtonKey : kDigitFourButtonKey,
                                    MSRemoteUIIterationValuesKey : @[
                                                                     PointValue(CGPointMake(20, 60)),
                                                                     PointValue(CGPointMake(5, 5)),
                                                                     PointValue(CGPointMake(-25, -65))
                                    ]
                                });
            break;

        case 2 :
            performTranslations(@{
                                    MSRemoteUIRemoteKey : MSRemoteControllerHomeRemoteKeyName,
                                    MSRemoteUIButtonGroupKey : @"activityButtons",
                                    MSRemoteUIButtonKey : @"activity1",
                                    MSRemoteUIIterationValuesKey : @[
                                                                     PointValue(CGPointMake(8.5, 46)),
                                                                     PointValue(CGPointMake(0.5, 122))
                                    ]
                                });
            break;

        default :
            MSLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, testNumber);
            break;
    } /* switch */
}

- (void)runFocusTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    MSRemoteUITestRunner   performFocus = ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;
        __block ButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSArray  * buttonKeys     = parameters[MSRemoteUIIterationValuesKey];

        [MainQueue addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                                      assert(bgEditor && !bgEditor.sourceView);
                                                  bg = self.remoteController[remoteKey][buttonGroupKey];
                                                      assert(bg);
                                                  bgEditor.mockParentSize = MainScreen.bounds.size;
                                                  bgEditor.remoteElement = bg;
                                                  [AppController.window
                                                   setRootViewController:bgEditor];
                                                  bgv = (ButtonGroupView *)bgEditor.sourceView;
                                                      assert(bgv);
                                                  for (NSString * buttonKey in buttonKeys) {
                                                      bv = (ButtonView *)bgv[buttonKey];
                                                      assert(bv);
                                                      [bgEditor selectView:bv];
                                                      assert([bgEditor.selectedViews
                                                              containsObject:bv]);
                                                  }
                                                  bgEditor.focusView = bv;
                                                      assert(bgEditor.focusView == bv);)]
               waitUntilFinished:YES];
    };

    switch (testNumber) {
        case 0 :
            performFocus(@{
                             MSRemoteUIRemoteKey : MSRemoteControllerHomeRemoteKeyName,
                             MSRemoteUIButtonGroupKey : @"activityButtons",
                             MSRemoteUIIterationValuesKey : @[@"activity1", @"activity3"]
                         });
            break;

        default :
            MSLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, testNumber);
    }
}

- (void)runAlignmentTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    static dispatch_once_t      onceToken;
    static NSDictionary const * kAlignmentSelectors;
    static NSSet const        * kSizeAlignmentAttributes;

    dispatch_once(&onceToken, ^{
        kAlignmentSelectors = @{
            @"left"       : NSStringFromSelector(@selector(alignLeftEdges:)),
            @"top"        : NSStringFromSelector(@selector(alignTopEdges:)),
            @"right"      : NSStringFromSelector(@selector(alignRightEdges:)),
            @"bottom"     : NSStringFromSelector(@selector(alignBottomEdges:)),
            @"centerX"    : NSStringFromSelector(@selector(alignHorizontalCenters:)),
            @"centerY"    : NSStringFromSelector(@selector(alignVerticalCenters:)),
            @"horizontal" : NSStringFromSelector(@selector(resizeHorizontallyFromFocusView:)),
            @"vertical"   : NSStringFromSelector(@selector(resizeVerticallyFromFocusView:)),
            @"both"       : NSStringFromSelector(@selector(resizeFromFocusView:))
        };
        kSizeAlignmentAttributes = [@[@"horizontal",@"vertical",@"both"] set];
    });

    MSRemoteUITestRunner   performAlignments = ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;
        __block ButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSArray  * alignments     = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * assertions     = parameters[MSRemoteUIAssertionsKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];

        [MainQueue
         addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                        assert(bgEditor && !bgEditor.sourceView);
                                        bg = self.remoteController[remoteKey][buttonGroupKey];
                                        assert(bg);
                                        bgEditor.mockParentSize = MainScreen.bounds.size;
                                        bgEditor.remoteElement = bg;
                                        [AppController.window
                                         setRootViewController:bgEditor];
                                        bgv = (ButtonGroupView *)bgEditor.sourceView;
                                        assert(bgv);)
                         ]
         waitUntilFinished:YES];

        int   depth = 0;

        for (NSString * alignment in alignments) {
            NSArray * keys             = [alignment componentsSeparatedByString:@":"];
            NSArray * selectedViewKeys = [[keys[0]
                                           componentsSeparatedByString:@","]
                                          objectsPassingTest:^BOOL (NSString * obj, NSUInteger idx, BOOL * stop) {
                return [NSString isNotEmptyString:obj];
            }];
            SEL   selector = NSSelectorFromString(kAlignmentSelectors[keys[2]]);
            assert(selector);
            BOOL isSizeAlignment = [kSizeAlignmentAttributes containsObject:alignment];

            [MainQueue
             addOperations:@[BlockOperation(bgEditor.focusView = nil;
                                            assert(!bgEditor.focusView);
                                            [bgEditor deselectAll];
                                            assert(bgEditor.selectedViews.count == 0);
                                            for (NSString * key in selectedViewKeys) {
                                                bv = (ButtonView *)bgv[key];
                                                assert(bv);
                                                [bgEditor selectView:bv];
                                                assert([bgEditor.selectedViews containsObject:bv]);
                                            }
                                            bv = (ButtonView *)bgv[keys[1]];
                                            assert(bv);
                                            [bgEditor selectView:bv];
                                            assert([bgEditor.selectedViews containsObject:bv]);
                                            bgEditor.focusView = bv;
                                            assert(bgEditor.focusView == bv);)
                             ]
             waitUntilFinished:YES];


            [MainQueue addOperations:@[BlockOperation(
                                                      if (!depth && !_flags.quietMode)
                                                          [self logRemoteElementView:bgv
                                                            includingSubelementViews:subelements
                                                                               after:0
                                                                             message:[NSString stringWithFormat:@"before any alignment"]];

                                                      (  isSizeAlignment
                                                       ? [bgEditor willResizeSelectedViews]
                                                       : [bgEditor willAlignSelectedViews]);)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            SuppressWarning("-Warc-performSelector-leaks",
                            [MainQueue
                             addOperations:@[BlockOperation([bgEditor performSelector:selector
                                                                           withObject:nil];)]
                             waitUntilFinished:YES];)

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation((  isSizeAlignment
                                                       ? [bgEditor didResizeSelectedViews]
                                                       : [bgEditor didAlignSelectedViews]);)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            if (!_flags.quietMode){
                [MainQueue addOperationWithBlock:^{
                    [self logRemoteElementView:bgv
                      includingSubelementViews:subelements
                                         after:0
                                       message:[NSString stringWithFormat:@"after alignment - %@", alignment]];
                }];
            }

            if (assertions && assertions[depth]) {
                [MainQueue addOperations:@[BlockOperation([[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = [MSAssertionHandler new];
                                                          MSRemoteUITestAssertions   assertionsBlock = assertions[depth];
                                                          assertionsBlock(@{@"editor" : bgEditor});)]
                       waitUntilFinished:YES];
            }

            if (++depth > DEPTH) break;
        }
    };

    NSDictionary * parameters = nil;

    switch (testNumber) {
        case 0 :{    // vertical alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUILogSubviewsKey     : @[@"digit4", @"aux2", @"aux1", @"digit6"],
                            MSRemoteUIIterationValuesKey : @[@"digit4:aux2:bottom", @"aux1:digit6:top"],
                            MSRemoteUIAssertionsKey      :
                                @[ ^(NSDictionary * variables)
                                    {
                                        ButtonGroupEditingViewController * editor = variables[@"editor"];
                                        assert(editor);
                                        Button * digit4 = (Button *)editor.sourceView[@"digit4"].remoteElement;
                                        assert(digit4);
                                        Button * digit1 = (Button *)editor.sourceView[@"digit1"].remoteElement;
                                        assert(digit1);
                                        NSDictionary * values = @{ @"firstItem"      : digit4.identifier,
                                                                   @"firstAttribute" : @(NSLayoutAttributeTop),
                                                                   @"relation"       : @(NSLayoutRelationEqual),
                                                                   @"secondItem"     : digit1.identifier };

                                        @try
                                        {
                                            NSAssert( ![digit4.firstItemConstraints firstObjectPassingTest:
                                                        ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                                            return [obj hasAttributeValues:values];
                                                        }],
                                                     @"'digit4.top = digit1.bottom' should have been removed" );

                                        }

                                        @catch (NSException * exception) {}
                                    },
                                    ^(NSDictionary * variables)
                                    {
                                        ButtonGroupEditingViewController * editor = variables[@"editor"];
                                        assert(editor);
                                        Button * aux1 = (Button *)editor.sourceView[@"aux1"].remoteElement;
                                        assert(aux1);
                                        Button * digit0 = (Button *)editor.sourceView[@"digit0"].remoteElement;
                                        assert(digit0);
                                        NSDictionary * values = @{  @"firstItem"      : aux1.identifier,
                                                                    @"firstAttribute" : @(NSLayoutAttributeBottom),
                                                                    @"relation"       : @(NSLayoutRelationEqual),
                                                                    @"secondItem"     : digit0.identifier };
                                        @try
                                        {
                                            NSAssert(![aux1.firstItemConstraints
                                                       firstObjectPassingTest:
                                                       ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                                           return ([obj hasAttributeValues:values] && (*stop = YES));
                                                       }],
                                                     @"'aux1.bottom = digit0.bottom' should have been removed");
                                        }

                                        @catch (NSException * exception) {}
                                    }
                                ]
                            };
				    performAlignments(parameters);
        }   break;

        case 1 : {   // horizontal alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:aux2:bottom",
                                                              @"aux1:digit6:top" ]
                            };
            performAlignments(parameters);
        }    break;

        case 2 : {   // top alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:aux2:bottom",
                                                              @"aux1:digit6:top" ]
                            };

            performAlignments(parameters);
        }  break;

        case 3 :  {  // bottom alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:aux2:bottom",
                                                              @"aux1:digit6:top" ]
                            };
            performAlignments(parameters);
        }   break;

        case 4 : {   // left alignment
            parameters = @{ MSRemoteUIRemoteKey          : MSRemoteControllerHomeRemoteKeyName,
                            MSRemoteUIButtonGroupKey     : @"activityButtons",
                            MSRemoteUIIterationValuesKey : @[ @"activity1:activity2:centerX",
                                                              @"activity2:activity3:left" ]
                            };
            performAlignments(parameters);
        }  break;

        case 5 :{    // right alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:aux2:bottom",
                                                              @"aux1:digit6:top" ]
                            };
            performAlignments(parameters);
        }  break;

        case 6 : {    // top and bottom alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:aux2:bottom",
                                                              @"aux1:digit6:top" ]
                            };
            performAlignments(parameters);
        }   break;

        case 7 : {   // left and right alignment
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:digit3:right",
                                                              @"digit6:digit1:left" ]
                            };
						performAlignments(parameters);
        }   break;
        case 8 : {
            parameters = @{ MSRemoteUIRemoteKey          : @"activity1",
                            MSRemoteUIButtonGroupKey     : kTopPanelOneKey,
                            MSRemoteUIIterationValuesKey : @[ @"digit4:kTuckButtonKey:horizontal",
                                                              @"digit4:kTuckButtonKey:centerX"],
                            MSRemoteUILogSubviewsKey     : @[ @"digit4", kTuckButtonKey],
                            MSRemoteUIAssertionsKey      :
                                @[ ^(NSDictionary * variables)
                                    {
                                        ButtonGroupEditingViewController * editor = variables[@"editor"];
                                        assert(editor);

                                        ButtonGroup * numberPad = (ButtonGroup *)editor.sourceView.remoteElement;
                                        assert(numberPad);

                                        Button * digit4 = (Button *)editor.sourceView[@"digit4"].remoteElement;
                                        assert(digit4);

                                        Button * digit7 = (Button *)editor.sourceView[@"digit7"].remoteElement;
                                        assert(digit7);

                                        Button * tuckPanel = (Button *)editor.sourceView[kTuckButtonKey].remoteElement;
                                        assert(tuckPanel);
                                        
                                        @try
                                        {
                                            NSAssert(![digit4 constraintWithAttributes:
                                                       (@{ @"firstItem"      : digit4,
                                                           @"firstAttribute" : @(NSLayoutAttributeLeft),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : numberPad
                                                       })],
                                                     @"'digit4.left = numberPad.left' should have been removed");
                                            
                                            NSAssert([digit4 constraintWithAttributes:
                                                      (@{ @"firstItem"      : digit4,
                                                          @"firstAttribute" : @(NSLayoutAttributeWidth),
                                                          @"relation"       : @(NSLayoutRelationEqual),
                                                          @"secondItem"     : tuckPanel
                                                       })],
                                                     @"'digit4.width = tuckPanel.width' should have been added");

                                            NSAssert(![digit7 constraintWithAttributes:
                                                       (@{ @"firstItem"      : digit7,
                                                           @"firstAttribute" : @(NSLayoutAttributeRight),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : digit4
                                                       })],
                                                     @"'digit7.right = digit4.right' should have been updated");

                                            NSString * config = [digit4.constraintManager.layoutConfiguration description];
                                            assert(config);
                                            NSAssert([@"RTBW" isEqualToString:config],
                                                     @"layout configuration for digit4 is incorrect, '%@' instead of 'RTBW'",
                                                     config);
                                        }

                                        @catch (NSException * exception) {}
                                    },
                                    ^(NSDictionary * variables)
                                    {
                                        ButtonGroupEditingViewController * editor = variables[@"editor"];
                                        assert(editor);

                                        ButtonGroup * numberPad = (ButtonGroup *)editor.sourceView.remoteElement;
                                        assert(numberPad);

                                        Button * digit4 = (Button *)editor.sourceView[@"digit4"].remoteElement;
                                        assert(digit4);

                                        Button * digit1 = (Button *)editor.sourceView[@"digit1"].remoteElement;
                                        assert(digit1);

                                        Button * tuckPanel = (Button *)editor.sourceView[kTuckButtonKey].remoteElement;
                                        assert(tuckPanel);

                                        @try
                                        {
                                            NSAssert(![digit4 constraintWithAttributes:
                                                       (@{ @"firstItem"      : digit4,
                                                           @"firstAttribute" : @(NSLayoutAttributeRight),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : digit1
                                                       })],
                                                     @"'digit4.right = digit1.right' should have been removed");
                                            
                                            NSAssert([digit4 constraintWithAttributes:
                                                      (@{ @"firstItem"      : digit4,
                                                          @"firstAttribute" : @(NSLayoutAttributeCenterX),
                                                          @"relation"       : @(NSLayoutRelationEqual),
                                                          @"secondItem"     : tuckPanel
                                                       })],
                                                     @"'digit4.centerX = tuckPanel.centerX' should have been added");

                                            NSString * config = [digit4.constraintManager.layoutConfiguration description];
                                            NSAssert([@"TBXW" isEqualToString:config],
                                                     @"layout configuration for digit4 is incorrect, '%@' instead of 'TBXW'",
                                                     config);
                                        }

                                        @catch (NSException * exception) {}
                                    }
                                ]
                            };
            performAlignments(parameters);
        } break;

        default :
            MSLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, testNumber);
    }
}

- (void)runInfoTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    MSRemoteUITestRunner   dumpInfo = ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];

        [MainQueue addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                                  assert(bgEditor && !bgEditor.sourceView);
                                                  bg = self.remoteController[remoteKey][buttonGroupKey];
                                                  assert(bg);
                                                  bgEditor.mockParentSize = MainScreen.bounds.size;
                                                  bgEditor.remoteElement = bg;
                                                  [AppController.window setRootViewController:bgEditor];
                                                  bgv = (ButtonGroupView *)bgEditor.sourceView;
                                                  assert(bgv);
                                                  )]
               waitUntilFinished:YES];

        if (!_flags.quietMode) {
            sleep(SLEEP_DURATION);
            MSLogDebug(
                       @"\n%@%@",
                       [@"autolayout trace" singleBarMessageBox],
                       AutolayoutTraceDescription());
            [self logRemoteElementView:bgv
              includingSubelementViews:subelements
                                 after:0.5
                               message:nil];
        }
    };

    switch (testNumber) {
        case 0 : dumpInfo(@{MSRemoteUIRemoteKey      : MSRemoteControllerHomeRemoteKeyName,
                            MSRemoteUIButtonGroupKey : @"activityButtons"});
            break;
        case 1 : dumpInfo(@{MSRemoteUIRemoteKey : @"activity1",
                            MSRemoteUIButtonGroupKey : kTopPanelOneKey});
            break;
        default : MSLogWarn(
                            @"%@ unsupported test number:%llu",
                            ClassTagSelectorString, testNumber);
    }
}

- (void)runDialogTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    MSRemoteUITestRunner   showDialog = ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;
        __block NSArray                          * buttons  = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSArray  * buttonKeys     = parameters[MSRemoteUIIterationValuesKey];

        [MainQueue addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                                  assert(bgEditor && !bgEditor.sourceView);
                                                  bg = self.remoteController[remoteKey][buttonGroupKey];
                                                  assert(bg);
                                                  bgEditor.mockParentSize = MainScreen.bounds.size;
                                                  bgEditor.remoteElement = bg;
                                                  [AppController.window setRootViewController:bgEditor];
                                                  bgv = (ButtonGroupView *)bgEditor.sourceView;
                                                  assert(bgv);
                                                  )]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation(buttons = [buttonKeys
                                                             arrayByMappingToBlock:^ButtonView *(NSString * obj, NSUInteger idx)
                    {
                        ButtonView * bv = (ButtonView *)bgv[obj];
                        assert(bv);

                        return bv;
                    }];
                                                  [bgEditor selectViews:[buttons set]];
                                                  bgEditor.focusView = buttons[0];
                                                  )]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation([bgEditor willAlignSelectedViews];)]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation([bgEditor alignHorizontalCenters:nil];)]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation([bgEditor didAlignSelectedViews];)]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation([bgEditor deselectAll];)]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);
        [MainQueue addOperations:@[BlockOperation([bgEditor displayStackedViewDialogForViews:[buttons set]];)]
               waitUntilFinished:YES];
    };

    switch (testNumber) {
        case 0 : showDialog(@{MSRemoteUIRemoteKey          : MSRemoteControllerHomeRemoteKeyName,
                              MSRemoteUIButtonGroupKey     : @"activityButtons",
                              MSRemoteUIIterationValuesKey : @[@"activity1",@"activity2"]}
                            );
            break;
        default : MSLogWarn(
                            @"%@ unsupported test number:%llu",
                            ClassTagSelectorString, testNumber);
    }
}

- (void)runScaleTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    MSRemoteUITestRunner   performScaling =
        ^(NSDictionary * parameters) {
        __block ButtonGroupEditingViewController * bgEditor = nil;
        __block ButtonGroupView                  * bgv      = nil;
        __block ButtonGroup                      * bg       = nil;
        __block ButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSString * buttonKey      = parameters[MSRemoteUIButtonKey];
        NSArray  * scales         = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];

        [MainQueue addOperations:@[
         BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                        assert(bgEditor && !bgEditor.sourceView);
                        bg = self.remoteController[remoteKey][buttonGroupKey];
                        assert(bg);
                        bgEditor.mockParentSize = MainScreen.bounds.size;
                        bgEditor.remoteElement = bg;
                        [AppController.window setRootViewController:bgEditor];
                        bgv = (ButtonGroupView *)bgEditor.sourceView;
                        assert(bgv);
                        bv = (ButtonView *)bgv[buttonKey];
                        assert(bv);
                        [bgEditor selectView:bv];
                        assert([bgEditor.selectedViews containsObject:bv]);)
         ]
               waitUntilFinished:YES];

        int   depth = 0;

        for (NSNumber * scale in scales) {
            if (!depth && !_flags.quietMode)
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"before scaling - %.2f", Float(scale)]];

            __block CGFloat   appliedScale;
            [MainQueue addOperations:@[BlockOperation([bgEditor willScaleSelectedViews];),
                                       BlockOperation(appliedScale = [bgEditor scaleSelectedViews:[scale floatValue]
                                                                                       validation:nil];),
                                       BlockOperation([bgEditor didScaleSelectedViews];)]
                   waitUntilFinished:YES];

            if (!_flags.quietMode) {
                sleep(SLEEP_DURATION);
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"after scaling - %.2f", Float(scale)]];
            }

            if (++depth > DEPTH) break;
        }
    };

    switch (testNumber) {
        case 0 :
            performScaling(@{
                               MSRemoteUIRemoteKey : MSRemoteControllerHomeRemoteKeyName,
                               MSRemoteUIButtonGroupKey : @"activityButtons",
                               MSRemoteUIButtonKey : @"activity1",
                               MSRemoteUIIterationValuesKey : @[
                                                                @0.5,
                                                                @2.0,
                                                                @1.5,
                                                                @0.25,
                                                                @1.0,
                                                                @4.0
                               ]
                           });
            break;
    } /* switch */
}

@end
