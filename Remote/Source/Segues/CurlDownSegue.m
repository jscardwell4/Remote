//
// CurlDownSegue.m
// iPhonto
//
// Created by Jason Cardwell on 3/31/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "CurlDownSegue.h"
#import "ButtonEditingViewController.h"
#import "DetailedButtonEditingViewController.h"

@implementation CurlDownSegue

- (void)perform {
    ButtonEditingViewController         * buttonEditor;
    DetailedButtonEditingViewController * detailedButtonEditor;

    if ([self.sourceViewController isMemberOfClass:[ButtonEditingViewController class]]) buttonEditor = self.sourceViewController;

    if ([self.destinationViewController isMemberOfClass:[DetailedButtonEditingViewController class]]) detailedButtonEditor = self.destinationViewController;

    if (ValueIsNotNil(buttonEditor) && ValueIsNotNil(detailedButtonEditor)) {
        [buttonEditor addChildViewController:detailedButtonEditor];
        [detailedButtonEditor didMoveToParentViewController:buttonEditor];

        NSDictionary * initialValues = @{kDetailedButtonEditingButtonKey : CollectionSafeValue(buttonEditor.remoteElement), kDetailedButtonEditingControlStateKey : CollectionSafeValue(@(buttonEditor.presentedControlState))};

        [detailedButtonEditor initializeEditorWithValues:initialValues];

        if ([buttonEditor.childViewControllers count] > 1) {
            UIViewController * currentChild = [buttonEditor.childViewControllers lastObject];

            [buttonEditor transitionFromViewController:currentChild
                                      toViewController:detailedButtonEditor
                                              duration:0.5
                                               options:UIViewAnimationOptionTransitionCurlDown
                                            animations:nil
                                            completion:nil];
        } else {
            [UIView transitionWithView:buttonEditor.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlDown
                            animations:^{[buttonEditor.view
                                addSubview:detailedButtonEditor.view]; }

                            completion:nil];
        }
    }
}

@end
