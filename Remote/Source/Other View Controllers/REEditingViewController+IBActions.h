//
//  RemoteElementEditingViewController+IBActions.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"

@interface REEditingViewController (IBActions)

///@name Top Toolbar
- (IBAction)saveAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

///@name Empty Selection Toolbar
- (IBAction)addSubelement:(id)sender;
- (IBAction)editBackground:(id)sender;
- (IBAction)toggleBoundsVisibility:(id)sender;
- (IBAction)presets:(id)sender;

///@name Non-empty Selection Toolbar
- (IBAction)editSubelement:(id)sender;
- (IBAction)duplicateSubelements:(id)sender;
- (IBAction)copyStyle:(id)sender;
- (IBAction)pasteStyle:(id)sender;

///@name Focus Selected Toolbar
- (IBAction)alignVerticalCenters:(id)sender;
- (IBAction)alignHorizontalCenters:(id)sender;
- (IBAction)alignTopEdges:(id)sender;
- (IBAction)alignBottomEdges:(id)sender;
- (IBAction)alignLeftEdges:(id)sender;
- (IBAction)alignRightEdges:(id)sender;
- (IBAction)resizeHorizontallyFromFocusView:(id)sender;
- (IBAction)resizeVerticallyFromFocusView:(id)sender;
- (IBAction)resizeFromFocusView:(id)sender;

///@name Dialogs
- (IBAction)showMultiselect:(id)sender;
- (IBAction)hideMultiselect:(id)sender;
- (IBAction)menuAction:(id)sender;

@end
