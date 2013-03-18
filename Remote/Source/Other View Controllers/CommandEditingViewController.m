//
// CommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "CommandEditingViewController.h"
#import "AttributeEditingViewController_Private.h"
#import "Command.h"
#import "REButtonGroup.h"
#import "RERemote.h"
#import "RERemoteController.h"
#import "ComponentDevice.h"
#import "IRCode.h"
#import <QuartzCore/QuartzCore.h>
#import "Painter.h"
#import "CommandDetailViewController.h"
#import "HTTPCommandEditingViewController.h"
#import "SendIRCommandEditingViewController.h"
#import "DelayCommandEditingViewController.h"
#import "SwitchToRemoteCommandEditingViewController.h"
#import "MacroCommandEditingViewController.h"
#import "PowerCommandEditingViewController.h"
#import "ViewDecorator.h"

#define kCommandDetailsViewFrame CGRectMake(0, 40, 320, 232)

static int       ddLogLevel = LOG_LEVEL_DEBUG;
static UIFont  * labelFont;
static UIColor * labelTextColor;
static UIColor * buttonTitleColor;

// static NSString const * kCreateCommandString = @"Create New Command";
static NSDictionary const * commandTypes;
static NSArray const      * createableCommands;

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

#pragma mark - Methods for managing initial/selected values
@synthesize detailsLabel = _detailsLabel;
@synthesize
removeCommandButton     = _removeCommandButton,
commandDetailEditors    = _commandDetailEditors,
commandDetailsContainer = _commandDetailsContainer,
contentContainer        = _contentContainer,
initialCommand          = _initialCommand,
currentCommand          = _currentCommand,
commandTypeButton       = _commandTypeButton,
button                  = _button;

+ (void)initialize {
    if (self == [CommandEditingViewController class]) {
        commandTypes = @{NSStringFromClass([Command class]) : @"Generic", NSStringFromClass([PowerCommand class]) : @"Power", NSStringFromClass([SwitchToRemoteCommand class]) : @"Switch-To-Remote", NSStringFromClass([MacroCommand class]) : @"Macro", NSStringFromClass([DelayCommand class]) : @"Delay", NSStringFromClass([SystemCommand class]) : @"System", NSStringFromClass([SendIRCommand class]) : @"Send IR", NSStringFromClass([HTTPCommand class]) : @"HTTP"};

        NSSet * excludedCommands = [NSSet setWithObjects:@"Generic", @"System", nil];

        createableCommands = [[commandTypes allValues] objectsAtIndexes:
                              [[commandTypes allValues]
                               indexesOfObjectsPassingTest:
                               ^BOOL (id obj, NSUInteger idx, BOOL * stop) {
                return ![excludedCommands member:obj];
            }

                              ]
                             ];
        labelFont        = [UIFont boldSystemFontOfSize:14.0];
        labelTextColor   = [UIColor whiteColor];
        buttonTitleColor = [UIColor colorWithRed:0.0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
    }
}

+ (NSArray *)createableCommands {
    return [createableCommands copy];
}

+ (NSDictionary *)commandTypes {
    return [commandTypes copy];
}

+ (NSString *)titleForClassOfCommand:(Command *)command {
    return commandTypes[NSStringFromClass([command class])];
}

- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues {
    [super setInitialValuesFromDictionary:initialValues];

    DDLogDebug(@"%@\n\tbutton:%@", ClassTagString, [self.button debugDescription]);

    if (ValueIsNotNil(_button)) self.initialCommand = _button.command;

    [self syncCurrentValuesWithIntialValues];
}

- (void)syncCurrentValuesWithIntialValues {
    self.currentCommand = _initialCommand;
}

- (void)restoreCurrentValues {
    if (ValueIsNotNil(_currentCommand)) {
        [_commandTypeButton setTitle:[commandTypes
                                      objectForKey:NSStringFromClass([_currentCommand class])]
                            forState:UIControlStateDisabled];
        _commandTypeButton.enabled  = NO;
        _button.command             = _currentCommand;
        _removeCommandButton.hidden = NO;
        _detailsLabel.hidden        = NO;
        [self pushChildControllerForCommand:_currentCommand];
    } else if (ValueIsNotNil(_initialCommand)) {
        _button.command = nil;
        [_button.managedObjectContext deleteObject:_initialCommand];
        _commandTypeButton.enabled  = YES;
        _removeCommandButton.hidden = YES;
        _detailsLabel.hidden        = YES;
        [self removeAllChildren];
    }
}

- (void)resetToInitialState {
    [self syncCurrentValuesWithIntialValues];

    [self removeAllChildren];

    [self restoreCurrentValues];
}

- (void)removeAllChildren {
    while ([self.childViewControllers count] > 0)
        [self popChildController];
}

- (void)pushChildControllerForCommand:(Command *)command {
    NSString                    * identifier      = ClassString([command class]);
    CommandDetailViewController * childController =
        [self.commandDetailEditors instantiateViewControllerWithIdentifier:identifier];

    childController.command = command;

    if ([self.childViewControllers count] > 0) childController.controllerNested = YES;

    [self addChildViewController:childController];
    childController.view.frame = _commandDetailsContainer.bounds;
    [_commandDetailsContainer addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

- (void)popChildController {
    CommandDetailViewController * childController = [self.childViewControllers lastObject];

    [childController removeFromParentViewController];
    [childController didMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
}

- (UIStoryboard *)commandDetailEditors {
    if (ValueIsNotNil(_commandDetailEditors)) return _commandDetailEditors;

    self.commandDetailEditors = [UIStoryboard storyboardWithName:@"CommandDetailEditorsStoryboard"
                                                          bundle:nil];

    return _commandDetailEditors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Resize view to fit appropriately
    self.view.frame = self.contentContainer.bounds;

    [ViewDecorator decorateButton:_commandTypeButton excludedStates:UIControlStateDisabled];
    _commandTypeButton.inputView.cancelBarButtonItem = [ViewDecorator pickerInputCancelBarButtonItem];
    _commandTypeButton.inputView.selectBarButtonItem = [ViewDecorator pickerInputSelectBarButtonItem];

    [_commandTypeButton setTitle:@"Create New Command" forState:UIControlStateNormal];

    [self restoreCurrentValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setCommandTypeButton:nil];
    [self setContentContainer:nil];
    [self setCommandDetailsContainer:nil];
    [self setRemoveCommandButton:nil];
    [self setDetailsLabel:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 1;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    return [createableCommands count];
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component {
    return createableCommands[row];
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    [_commandTypeButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    [_commandTypeButton resignFirstResponder];

    NSString * selection         = createableCommands[[rows[0] integerValue]];
    NSString * classString =
        [[commandTypes keysOfEntriesPassingTest:
          ^BOOL (id key, id obj, BOOL * stop) {
            if ([selection isEqualToString:(NSString *)obj]) {
                *stop = YES;

                return YES;
            } else
                return NO;
        }

         ] anyObject];
    Class     commandClass = NSClassFromString(classString);
    Command * newCommand   = (Command *)[commandClass commandInContext:_button.managedObjectContext];

    if (newCommand) {
        self.currentCommand = newCommand;
        [self restoreCurrentValues];
    }
}

- (IBAction)removeCommandAction:(UIButton *)sender {
    self.currentCommand = nil;
    [self restoreCurrentValues];
}

@end
