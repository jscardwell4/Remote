//
// CommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "CommandEditingViewController.h"
#import "AttributeEditingViewController_Private.h"
#import <QuartzCore/QuartzCore.h>
#import "CommandDetailViewController.h"
#import "HTTPCommandEditingViewController.h"
#import "SendIRCommandEditingViewController.h"
#import "DelayCommandEditingViewController.h"
#import "SwitchToRemoteCommandEditingViewController.h"
#import "MacroCommandEditingViewController.h"
#import "PowerCommandEditingViewController.h"
#import "ViewDecorator.h"
#import "Remote-Swift.h"

#define kCommandDetailsViewFrame CGRectMake(0, 40, 320, 232)

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_EDITOR;

static UIFont  * labelFont;
static UIColor * labelTextColor;
static UIColor * buttonTitleColor;

static NSDictionary const * commandTypes;
static NSArray      const * createableCommands;

@interface CommandEditingViewController ()

@property (strong, nonatomic) IBOutlet MSPickerInputButton * commandTypeButton;
@property (strong, nonatomic) IBOutlet UIView              * contentContainer;
@property (strong, nonatomic) IBOutlet MSView              * commandDetailsContainer;
@property (strong, nonatomic) IBOutlet UILabel             * detailsLabel;
@property (strong, nonatomic) IBOutlet UIButton            * removeCommandButton;
@property (strong, nonatomic) UIStoryboard                 * commandDetailEditors;

@property (strong, nonatomic) Command * initialCommand;
@property (strong, nonatomic) Command * currentCommand;

- (void)removeAllChildren;

- (IBAction)removeCommandAction:(UIButton *)sender;

@end

@implementation CommandEditingViewController

/// initialize
+ (void)initialize {
  if (self == [CommandEditingViewController class]) {
    commandTypes = @{
      NSStringFromClass([Command class])       : @"Generic",
      NSStringFromClass([PowerCommand class])  : @"Power",
      NSStringFromClass([SwitchCommand class]) : @"Switch",
      NSStringFromClass([MacroCommand class])  : @"Macro",
      NSStringFromClass([DelayCommand class])  : @"Delay",
      NSStringFromClass([SystemCommand class]) : @"System",
      NSStringFromClass([SendIRCommand class]) : @"Send IR",
      NSStringFromClass([HTTPCommand class])   : @"HTTP"
    };

    NSSet * excludedCommands = [NSSet setWithObjects:@"Generic", @"System", nil];

    createableCommands = [[commandTypes allValues] objectsAtIndexes:
                          [[commandTypes allValues] indexesOfObjectsPassingTest: ^BOOL (id obj, NSUInteger idx, BOOL * stop) {
                            return ![excludedCommands member:obj];
                          }]];
    labelFont        = [UIFont boldSystemFontOfSize:14.0];
    labelTextColor   = [UIColor whiteColor];
    buttonTitleColor = [UIColor colorWithRed:0.0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
  }
}

/// createableCommands
/// @return NSArray *
+ (NSArray *)createableCommands { return [createableCommands copy]; }

/// commandTypes
/// @return NSDictionary *
+ (NSDictionary *)commandTypes { return [commandTypes copy]; }

/// titleForClassOfCommand:
/// @param command
/// @return NSString *
+ (NSString *)titleForClassOfCommand:(Command *)command { return commandTypes[NSStringFromClass([command class])]; }

/// setInitialValuesFromDictionary:
/// @param initialValues
- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues {
  [super setInitialValuesFromDictionary:initialValues];
  MSLogDebug(@"%@\n\tbutton:%@", ClassTagString, [self.button debugDescription]);
  if (self.button) self.initialCommand = self.button.command;
  [self syncCurrentValuesWithIntialValues];
}

/// syncCurrentValuesWithIntialValues
- (void)syncCurrentValuesWithIntialValues { self.currentCommand = _initialCommand; }

/// restoreCurrentValues
- (void)restoreCurrentValues {

  if (_currentCommand) {

    [_commandTypeButton setTitle:commandTypes[NSStringFromClass([_currentCommand class])] forState:UIControlStateDisabled];
    _commandTypeButton.enabled  = NO;
    self.button.command         = _currentCommand;
    _removeCommandButton.hidden = NO;
    _detailsLabel.hidden        = NO;
    [self pushChildControllerForCommand:_currentCommand];

  } else if (ValueIsNotNil(_initialCommand)) {

    self.button.command = nil;
    [self.button.managedObjectContext deleteObject:_initialCommand];
    _commandTypeButton.enabled  = YES;
    _removeCommandButton.hidden = YES;
    _detailsLabel.hidden        = YES;
    [self removeAllChildren];

  }

}

/// resetToInitialState
- (void)resetToInitialState {
  [self syncCurrentValuesWithIntialValues];
  [self removeAllChildren];
  [self restoreCurrentValues];
}

/// removeAllChildren
- (void)removeAllChildren { while ([self.childViewControllers count] > 0) [self popChildController]; }

/// pushChildControllerForCommand:
/// @param command
- (void)pushChildControllerForCommand:(Command *)command {

  NSString * identifier = ClassString([command class]);
  CommandDetailViewController * childController = [self.commandDetailEditors instantiateViewControllerWithIdentifier:identifier];

  childController.command = command;

  if ([self.childViewControllers count] > 0) childController.controllerNested = YES;

  [self addChildViewController:childController];
  childController.view.frame = _commandDetailsContainer.bounds;
  [_commandDetailsContainer addSubview:childController.view];
  [childController didMoveToParentViewController:self];

}

/// popChildController
- (void)popChildController {
  CommandDetailViewController * childController = [self.childViewControllers lastObject];
  [childController removeFromParentViewController];
  [childController didMoveToParentViewController:nil];
  [childController.view removeFromSuperview];
}

/// commandDetailEditors
/// @return UIStoryboard *
- (UIStoryboard *)commandDetailEditors {
  if (!_commandDetailEditors)  self.commandDetailEditors = [UIStoryboard storyboardWithName:@"CommandDetailEditorsStoryboard"
                                                                                     bundle:nil];
  return _commandDetailEditors;
}

/// viewDidLoad
- (void)viewDidLoad {
  [super viewDidLoad];

  // Resize view to fit appropriately
  self.view.frame = self.contentContainer.bounds;

  [ViewDecorator decorateButton:_commandTypeButton excludedStates:UIControlStateDisabled];
  _commandTypeButton.inputView.cancelBarButtonItem = [ViewDecorator pickerInputCancelBarButtonItem];
  _commandTypeButton.inputView.selectBarButtonItem = [ViewDecorator pickerInputSelectBarButtonItem];

  [_commandTypeButton setTitle:@"Create New Command" forState:UIControlStateNormal];

  [self restoreCurrentValues];
}

/// didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  _commandTypeButton = nil;
  _contentContainer = nil;
  _commandDetailsContainer = nil;
  _removeCommandButton = nil;
  _detailsLabel = nil;

  if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

/// numberOfComponentsInPickerInput:
/// @param pickerInput
/// @return NSInteger
- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput { return 1; }

/// pickerInput:numberOfRowsInComponent:
/// @param pickerInput
/// @param component
/// @return NSInteger
- (NSInteger)pickerInput:(MSPickerInputView *)pickerInput numberOfRowsInComponent:(NSInteger)component {
  return [createableCommands count];
}

/// pickerInput:titleForRow:forComponent:
/// @param pickerInput
/// @param row
/// @param component
/// @return NSString *
- (NSString *)pickerInput:(MSPickerInputView *)pickerInput titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return createableCommands[row];
}

/// pickerInputDidCancel:
/// @param pickerInput
- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput { [_commandTypeButton resignFirstResponder]; }

/// pickerInput:selectedRows:
/// @param pickerInput
/// @param rows
- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {

  [_commandTypeButton resignFirstResponder];

//  NSString * selection   = createableCommands[[rows[0] integerValue]];
//  NSString * classString = [[commandTypes keysOfEntriesPassingTest:^BOOL (id key, id obj, BOOL * stop) {
//                             if ([selection isEqualToString:(NSString *)obj]) { *stop = YES; return YES; }
//                             else return NO;
//                           }] anyObject];

//  Class     commandClass = NSClassFromString(classString);
//  Command * newCommand   = (Command *)[commandClass commandInContext:self.button.managedObjectContext];

//  if (newCommand) { self.currentCommand = newCommand; [self restoreCurrentValues]; }
}

/// removeCommandAction:
/// @param sender
- (IBAction)removeCommandAction:(UIButton *)sender { self.currentCommand = nil; [self restoreCurrentValues]; }

@end
