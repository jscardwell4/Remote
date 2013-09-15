//
// UITestRunner.m
// Remote
//
// Created by Jason Cardwell on 1/15/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "UITestRunner.h"
#import "MSRemoteUITest.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "RemoteViewController.h"
#import "RemoteConstruction.h"
#import "RemoteElementView.h"
#import "RemoteElementEditingViewController_Private.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

static BOOL                     kSuppressDialog;
static NSOperationQueue const * kTestQueue;

@implementation UITestRunner

+ (void)initialize {
    if (self == [UITestRunner class])
        kTestQueue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.uitesting"];
}

+ (void)setSuppressDialog:(BOOL)suppressDialog { kSuppressDialog = suppressDialog; }

+ (BOOL)shouldSuppressDialog { return kSuppressDialog; }

+ (void)showDialog {
        assert(IsMainQueue);
    [MainQueue addOperationWithBlock:^{
                   [UIAlertView            showAlertViewWithTitle:@"UITestRunner"
                                                 style:UIAlertViewStylePlainTextInput
                                               message:@"Enter code for test to run:"
                                     cancelButtonTitle:@"Cancel"
                                     otherButtonTitles:@[@"Run Test"]
                                             onDismiss:^(int buttonIndex, UIAlertView * alertView) {
                                                 [UITestRunner runTests:@[@([[alertView textFieldAtIndex:0].text longLongValue])]];
                   }

                                              onCancel:^{
                                                  [AppController showMainMenu];
                   }];
               }];
}

+ (void)runTests:(NSArray *)tests {
        assert(IsMainQueue);
    LOG_QUEUE_NAME;

    NSMutableArray                  * blockOperations = [@[] mutableCopy];
    __block __weak NSBlockOperation * previousOp      = nil;

    [tests enumerateObjectsWithOptions:0
                            usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                                UITestCode testCode = [obj unsignedLongLongValue];
                                __weak NSBlockOperation * newOp = BlockOperation([[MSRemoteUITest testWithCode:testCode] runTest];);
                                if (previousOp) [newOp addDependency:previousOp];
                                previousOp = newOp;
                                [blockOperations addObject:newOp];
                            }];
        assert(previousOp);
    [previousOp setCompletionBlock:^{[MainQueue addOperationWithBlock:^{[UITestRunner testingFinished];}];}];
    [kTestQueue addOperations:blockOperations waitUntilFinished:NO];
}

+ (void)testingFinished {
    if (!kSuppressDialog) {
        assert(IsMainQueue);
        LOG_QUEUE_NAME;
        [UIAlertView showAlertViewWithTitle:@"UITestRunner"
                                      style:UIAlertViewStyleDefault
                                    message:@"Run another test?"
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@[@"Yes", @"Dismiss", @"Exit"]
                                  onDismiss:^(int buttonIndex, UIAlertView * alertView) {
                                      if (buttonIndex == 0) [UITestRunner showDialog];
                                      else if (buttonIndex == 2) exit(EXIT_SUCCESS);
                                  }

                                   onCancel:^{
                                       [AppController showMainMenu];
                                   }];
    }
}

@end
