//
// ButtonGroupEditingTest.m
// Remote
//
// Created by Jason Cardwell on 2/7/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSRemoteUITest_Private.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "RemoteElement_Private.h"
#import "REConstraint.h"
#import "RemoteConstruction.h"
#import "REEditingViewController_Private.h"
#import "REButtonGroupEditingViewController.h"
#import "REButtonGroupView.h"
#import "UITestRunner.h"

// #define DEBUG_CONTEXT  UITESTING_F
#define DEPTH NSUIntegerMax

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = EDITOR_F;

#pragma unused(ddLogLevel, msLogContext)

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

    MSRemoteUITestRunner   performTranslations = ^(NSDictionary * parameters) {
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;
        __block REButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSString * buttonKey      = parameters[MSRemoteUIButtonKey];
        NSArray  * translations   = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];
        NSArray  * assertions     = parameters[MSRemoteUIAssertionsKey];

        [MainQueue
         addOperations:@[BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                        assert(bgEditor && !bgEditor.sourceView);
                                        bg = self.remoteController[remoteKey][buttonGroupKey];
                                        assert(bg);
                                        bgEditor.mockParentSize = MainScreen.bounds.size;
                                        bgEditor.remoteElement = bg;
                                        [AppController.window setRootViewController:bgEditor];
                                        bgv = (REButtonGroupView *)bgEditor.sourceView;
                                        assert(bgv);
                                        bv = (REButtonView *)bgv[buttonKey];
                                        assert(bv);
                                        [bgEditor selectView:bv];
                                        assert([bgEditor.selectedViews containsObject:bv]);)]
         waitUntilFinished:YES];

        int   depth = 0;

        for (NSValue * translation in translations) {
            [MainQueue addOperations:@[BlockOperation(
             if (!depth && !_flags.quietMode)
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:$(@"before translation: %@", CGPointString(CGPointValue(translation)))];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation([bgEditor willTranslateSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:
             @[BlockOperation([bgEditor translateSelectedViews:CGPointValue(translation)];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation([bgEditor didTranslateSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            if (!_flags.quietMode)
                [MainQueue addOperationWithBlock:^{
                  [self logRemoteElementView:bgv
                  includingSubelementViews:subelements
                          after:0
                        message:[NSString stringWithFormat:@"after translation: %@", CGPointString(CGPointValue(translation))]];
                }];

            if (assertions && assertions[depth]) {
                [MainQueue addOperations:@[BlockOperation([[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = [MSAssertionHandler new];
                                                          MSRemoteUITestAssertions   assertionsBlock = assertions[depth];
                                                          assertionsBlock(bgEditor);)]
                       waitUntilFinished:YES];
            }

            if (++depth > DEPTH) break;
        }
    };

    NSDictionary * parameters = nil;

    switch (testNumber) {
        case 0 : {
            __block void(^assertSize)(REView *, CGSize) = ^(REView * view, CGSize size) {
                @try
                {
                    NSAssert(CGSizeEqualToSize(size, view.bounds.size),
                             @"element '%@' size should be %.2f x %.2f but it is %.2f x %.2f",
                             view.displayName,
                             size.width,
                             size.height,
                             view.bounds.size.width,
                             view.bounds.size.height);
                }

                @catch (NSException * exception) {}
            };

            parameters = @{MSRemoteUIRemoteKey 						 		: MSRemoteControllerHomeRemoteKeyName,
                           MSRemoteUIButtonGroupKey 	: @"activityButtons",
                           MSRemoteUIButtonKey		 		: @"activity1",
                           MSRemoteUIIterationValuesKey : @[NSValueWithCGPoint(CGPointMake(0, -48)),
                                                            NSValueWithCGPoint(CGPointMake(0, 248)),
                                                            NSValueWithCGPoint(CGPointMake(0, -200)),
                                                            NSValueWithCGPoint(CGPointMake(-9, -32)),
                                                            NSValueWithCGPoint(CGPointMake(32.5, 72)),
                                                            NSValueWithCGPoint(CGPointMake(1, 146)),
                                                            NSValueWithCGPoint(CGPointMake(-24.5, -186))],
                           MSRemoteUILogSubviewsKey 	: @[@"activity1",
                                                            @"activity2",
                                                            @"activity3",
                                                            @"activity4"],
                           MSRemoteUIAssertionsKey      : @[^(REEditingViewController * editor) {
                                                               assertSize(editor.sourceView,CGSizeMake(300, 348));
                                                               for (REView * view in editor.sourceView.subelementViews)
                                                                   assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(300, 350));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(300, 300));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(309, 332));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(300, 300));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(300, 336));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));
                                                             },
                                                             ^(REEditingViewController * editor) {
                                                                 assertSize(editor.sourceView,CGSizeMake(300, 300));
                                                                 for (REView * view in editor.sourceView.subelementViews)
                                                                     assertSize(view,CGSizeMake(150,150));}]
                           };
            performTranslations(parameters);
        } break;
            
        case 1 :
            parameters = @{
                                    MSRemoteUIRemoteKey : @"activity1",
                                    MSRemoteUIButtonGroupKey : kTopPanelOneKey,
                                    MSRemoteUIButtonKey : kDigitFourButtonKey,
                                    MSRemoteUIIterationValuesKey : @[NSValueWithCGPoint(CGPointMake(20, 60)),
                                                                     NSValueWithCGPoint(CGPointMake(5, 5)),
                                                                     NSValueWithCGPoint(CGPointMake(-25, -65))],
                                    MSRemoteUILogSubviewsKey : @[@"digit4", @"digit7"]

                                };
            performTranslations(parameters);
            break;

        case 2 :
            parameters = @{
                                    MSRemoteUIRemoteKey : MSRemoteControllerHomeRemoteKeyName,
                                    MSRemoteUIButtonGroupKey : @"activityButtons",
                                    MSRemoteUIButtonKey : @"activity1",
                                    MSRemoteUIIterationValuesKey : @[NSValueWithCGPoint(CGPointMake(8.5, 46)),
                                                                     NSValueWithCGPoint(CGPointMake(0.5, 122))],
                                    MSRemoteUILogSubviewsKey : @[@"activity1", @"activity2", @"activity3", @"activity4"]

                                };
            performTranslations(parameters);
            break;

        default :
            MSLogWarn(@"%@ unsupported test number:%llu", ClassTagSelectorString, testNumber);
            break;
    }
}

- (void)runFocusTestNumber:(uint64_t)testNumber options:(uint64_t)testOptions {
    MSRemoteUITestRunner   performFocus = ^(NSDictionary * parameters) {
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;
        __block REButtonView                       * bv       = nil;

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
                                                  bgv = (REButtonGroupView *)bgEditor.sourceView;
                                                      assert(bgv);
                                                  for (NSString * buttonKey in buttonKeys) {
                                                      bv = (REButtonView *)bgv[buttonKey];
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
            @"left"       : SelectorString(@selector(alignLeftEdges:)),
            @"top"        : SelectorString(@selector(alignTopEdges:)),
            @"right"      : SelectorString(@selector(alignRightEdges:)),
            @"bottom"     : SelectorString(@selector(alignBottomEdges:)),
            @"centerX"    : SelectorString(@selector(alignHorizontalCenters:)),
            @"centerY"    : SelectorString(@selector(alignVerticalCenters:)),
            @"horizontal" : SelectorString(@selector(resizeHorizontallyFromFocusView:)),
            @"vertical"   : SelectorString(@selector(resizeVerticallyFromFocusView:)),
            @"both"       : SelectorString(@selector(resizeFromFocusView:))
        };
        kSizeAlignmentAttributes = [@[@"horizontal",@"vertical",@"both"] set];
    });

    MSRemoteUITestRunner   performAlignments = ^(NSDictionary * parameters) {
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;
        __block REButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSArray  * alignments     = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * assertions     = parameters[MSRemoteUIAssertionsKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];

        [MainQueue
         addOperations:@[BlockOperation(
                                        bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                                        assert(bgEditor && !bgEditor.sourceView);
                                        bg = self.remoteController[remoteKey][buttonGroupKey];
                                        assert(bg);
                                        bgEditor.mockParentSize = MainScreen.bounds.size;
                                        bgEditor.remoteElement = bg;
                                        [AppController.window
                                         setRootViewController:bgEditor];
                                        bgv = (REButtonGroupView *)bgEditor.sourceView;
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
                                                bv = (REButtonView *)bgv[key];
                                                assert(bv);
                                                [bgEditor selectView:bv];
                                                assert([bgEditor.selectedViews containsObject:bv]);
                                            }
                                            bv = (REButtonView *)bgv[keys[1]];
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
                                                          assertionsBlock(bgEditor);)]
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
                                @[ ^(REEditingViewController * editor)
                                    {
                                        REButtonGroup * numberPad = (REButtonGroup *)editor.sourceView.model;
                                        REButton * digit4 = numberPad[@"digit4"];
                                        REButton * digit1 = numberPad[@"digit1"];
                                        NSDictionary * values = @{ @"firstItem"      : digit4.uuid,
                                                                   @"firstAttribute" : @(NSLayoutAttributeTop),
                                                                   @"relation"       : @(NSLayoutRelationEqual),
                                                                   @"secondItem"     : digit1.uuid };

                                        @try
                                        {
                                            NSAssert( ![digit4.firstItemConstraints firstObjectPassingTest:
                                                        ^BOOL (REConstraint * obj, BOOL * stop) {
                                                            return [obj hasAttributeValues:values];
                                                        }],
                                                     @"'digit4.top = digit1.bottom' should have been removed" );

                                        }

                                        @catch (NSException * exception) {}
                                    },
                                    ^(REEditingViewController * editor)
                                    {
                                        REButtonGroup * numberPad = (REButtonGroup *)editor.sourceView.model;
                                        REButton * aux1 =numberPad[@"aux1"];
                                        REButton * digit0 =numberPad[@"digit0"];
                                        NSDictionary * values = @{  @"firstItem"      : aux1.uuid,
                                                                    @"firstAttribute" : @(NSLayoutAttributeBottom),
                                                                    @"relation"       : @(NSLayoutRelationEqual),
                                                                    @"secondItem"     : digit0.uuid };
                                        @try
                                        {
                                            NSAssert(![aux1.firstItemConstraints
                                                       firstObjectPassingTest:
                                                       ^BOOL (REConstraint * obj, BOOL * stop) {
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
                                @[ ^(REEditingViewController * editor)
                                    {
                                        REButtonGroup * numberPad = (REButtonGroup *)editor.sourceView.model;
                                        REButton * digit4 = numberPad[@"digit4"];
                                        REButton * digit7 = numberPad[@"digit7"];
                                        REButton * tuckPanel = numberPad[kTuckButtonKey];

                                        @try
                                        {
                                            NSAssert(![digit4.layoutConfiguration constraintWithValues:
                                                       (@{ @"firstItem"      : digit4,
                                                           @"firstAttribute" : @(NSLayoutAttributeLeft),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : numberPad
                                                       })],
                                                     @"'digit4.left = numberPad.left' should have been removed");

                                            NSAssert([digit4.layoutConfiguration constraintWithValues:
                                                      (@{ @"firstItem"      : digit4,
                                                          @"firstAttribute" : @(NSLayoutAttributeWidth),
                                                          @"relation"       : @(NSLayoutRelationEqual),
                                                          @"secondItem"     : tuckPanel
                                                       })],
                                                     @"'digit4.width = tuckPanel.width' should have been added");

                                            NSAssert(![digit7.layoutConfiguration constraintWithValues:
                                                       (@{ @"firstItem"      : digit7,
                                                           @"firstAttribute" : @(NSLayoutAttributeRight),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : digit4
                                                       })],
                                                     @"'digit7.right = digit4.right' should have been updated");

                                            NSString * config = [digit4.layoutConfiguration description];
                                            NSAssert([@"TBXW" isEqualToString:config],
                                                     @"layout configuration for digit4 is incorrect, '%@' instead of 'TBXW'",
                                                     config);
                                        }

                                        @catch (NSException * exception) {}
                                    },
                                    ^(REEditingViewController * editor)
                                    {
                                        REButtonGroup * numberPad = (REButtonGroup*)editor.sourceView.model;
                                        REButton      * digit4    = numberPad[@"digit4"];
                                        REButton      * digit1    = numberPad[@"digit1"];
                                        REButton      * tuckPanel = numberPad[kTuckButtonKey];

                                        @try
                                        {
                                            NSAssert(![digit4.layoutConfiguration constraintWithValues:
                                                       (@{ @"firstItem"      : digit4,
                                                           @"firstAttribute" : @(NSLayoutAttributeRight),
                                                           @"relation"       : @(NSLayoutRelationEqual),
                                                           @"secondItem"     : digit1
                                                       })],
                                                     @"'digit4.right = digit1.right' should have been removed");

                                            NSAssert([digit4.layoutConfiguration constraintWithValues:
                                                      (@{ @"firstItem"      : digit4,
                                                          @"firstAttribute" : @(NSLayoutAttributeCenterX),
                                                          @"relation"       : @(NSLayoutRelationEqual),
                                                          @"secondItem"     : tuckPanel
                                                       })],
                                                     @"'digit4.centerX = tuckPanel.centerX' should have been added");

                                            NSString * config = [digit4.layoutConfiguration description];
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
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;

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
                                                  bgv = (REButtonGroupView *)bgEditor.sourceView;
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
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;
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
                                                  bgv = (REButtonGroupView *)bgEditor.sourceView;
                                                  assert(bgv);
                                                  )]
               waitUntilFinished:YES];

        sleep(SLEEP_DURATION);

        [MainQueue addOperations:@[BlockOperation(buttons = [buttonKeys
                                                             arrayByMappingToBlock:^REButtonView *(NSString * obj, NSUInteger idx)
                    {
                        REButtonView * bv = (REButtonView *)bgv[obj];
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
        __block REButtonGroupEditingViewController * bgEditor = nil;
        __block REButtonGroupView                  * bgv      = nil;
        __block REButtonGroup                      * bg       = nil;
        __block REButtonView                       * bv       = nil;

        NSString * remoteKey      = parameters[MSRemoteUIRemoteKey];
        NSString * buttonGroupKey = parameters[MSRemoteUIButtonGroupKey];
        NSString * buttonKey      = parameters[MSRemoteUIButtonKey];
        NSArray  * scales         = parameters[MSRemoteUIIterationValuesKey];
        NSArray  * subelements    = parameters[MSRemoteUILogSubviewsKey];
        NSArray  * assertions     = parameters[MSRemoteUIAssertionsKey];

        [MainQueue addOperations:@[
         BlockOperation(bgEditor = [StoryboardProxy buttonGroupEditingViewController];
                        assert(bgEditor && !bgEditor.sourceView);
                        bg = self.remoteController[remoteKey][buttonGroupKey];
                        assert(bg);
                        bgEditor.mockParentSize = MainScreen.bounds.size;
                        bgEditor.remoteElement = bg;
                        [AppController.window setRootViewController:bgEditor];
                        bgv = (REButtonGroupView *)bgEditor.sourceView;
                        assert(bgv);
                        bv = (REButtonView *)bgv[buttonKey];
                        assert(bv);
                        [bgEditor selectView:bv];
                        assert([bgEditor.selectedViews containsObject:bv]);)
         ]
               waitUntilFinished:YES];

        int   depth = 0;

        for (NSNumber * scale in scales) {
            if (!depth && !_flags.quietMode)
                [MainQueue addOperationWithBlock:^{
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"before scaling - %.2f", CGFloatValue(scale)]];
                }];

            __block CGFloat   appliedScale;
            [MainQueue addOperations:@[BlockOperation([bgEditor willScaleSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation(appliedScale = [bgEditor
                                                                      scaleSelectedViews:CGFloatValue(scale)
                                                                      validation:nil];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            [MainQueue addOperations:@[BlockOperation([bgEditor didScaleSelectedViews];)]
                   waitUntilFinished:YES];

            sleep(SLEEP_DURATION);

            if (!_flags.quietMode) {
                [MainQueue addOperationWithBlock:^{
                [self logRemoteElementView:bgv
                includingSubelementViews:subelements
                        after:0
                      message:[NSString stringWithFormat:@"after scaling - %.2f", CGFloatValue(scale)]];
                }];
            }
            if (assertions && assertions[depth]) {
                [MainQueue addOperations:@[BlockOperation([[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = [MSAssertionHandler new];
                                                          MSRemoteUITestAssertions   assertionsBlock = assertions[depth];
                                                          assertionsBlock(bgEditor);)]
                       waitUntilFinished:YES];
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
                               MSRemoteUIIterationValuesKey : @[@0.5, @2.0, @1.5, @0.25, @1.0, @4.0]//, // actual applied: 0.853, 2.0, 1.172, 0.427, 1.0, 2.344
//                               MSRemoteUILogSubviewsKey :@[@"activity1", @"activity2", @"activity3", @"activity4"]
                           });
            break;
    }
}

@end
