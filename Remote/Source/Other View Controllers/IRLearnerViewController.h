//
// IRLearnerViewController.h
// iPhonto
//
// Created by Jason Cardwell on 5/6/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@class   IPhontoAppController;

@interface IRLearnerViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    UISwitch                      * _learnerSwitch;
    UITextView                    * _capturedCommandTextView;
    IPhontoAppController * __weak   _appDelegate;
    UITextField                   * _deviceNameTextField;
    UITextField                   * _commandNameTextField;
    UIView                        * _saveCommandDialog;
    UIButton                      * _saveCommandButton;
    UIButton                      * _confirmSaveCommandButton;
}
- (IBAction)toggleLearner:(id)sender;
- (void)learnerStateDidChange:(BOOL)enabled;
- (void)receivedCapturedCommand:(NSString *)command;
// - (void)saveData;
- (IBAction)saveCapturedCommand:(id)sender;
- (IBAction)cancelSaveCapturedCommand:(id)sender;
- (IBAction)confirmSaveCapturedCommand:(id)sender;

@property (nonatomic, strong) IBOutlet UIView      * saveCommandDialog;
@property (nonatomic, strong) IBOutlet UIButton    * saveCommandButton;
@property (nonatomic, strong) IBOutlet UIButton    * confirmSaveCommandButton;
@property (nonatomic, strong) IBOutlet UISwitch    * learnerSwitch;
@property (nonatomic, strong) IBOutlet UITextView  * capturedCommandTextView;
@property (nonatomic, weak) IPhontoAppController   * appDelegate;
@property (nonatomic, strong) IBOutlet UITextField * deviceNameTextField;
@property (nonatomic, strong) IBOutlet UITextField * commandNameTextField;

@end
