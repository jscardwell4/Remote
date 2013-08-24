//
// IRCodeDetailViewController.h
// Remote
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "UserCodesViewController.h"
#import "RECommand.h"

@class   BOIRCode;

@interface IRCodeDetailViewController : UIViewController <UITextFieldDelegate,
                                                          UITextViewDelegate,
                                                          MSCheckboxViewDelegate>
{
    @private
    IBOutlet UITextView     * onOffPatternTextView;
    IBOutlet UITextField    * frequencyTextField;
    IBOutlet UILabel        * repeatLabel;
    IBOutlet UIStepper      * repeatStepper;
    IBOutlet UITextField    * offsetTextField;
    IBOutlet MSCheckboxView * setsDeviceInputCheckbox;
    IBOutlet UILabel        * codeNameLabel;
    IBOutlet MSView         * onOffPatternContainer;
    IBOutlet MSView         * patternTraitsContainer;
    IBOutlet MSView         * testControlsContainer;
    IBOutlet UIStepper      * portStepper;
    IBOutlet UILabel        * portLabel;
    IBOutlet MSCheckboxView * testCommandResultView;
}

@property (nonatomic, weak) BOIRCode * code;
@end
