//
// MacroCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MacroCommandEditingViewController.h"
#import "CommandEditingViewController.h"
#


#import "RemoteController.h"

#import "ViewDecorator.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@interface MacroCommandEditingViewController ()

@property (strong, nonatomic) IBOutlet UITableView * tableView;

- (IBAction)addCommand:(id)sender;
- (IBAction)editCommands:(id)sender;

@property (nonatomic, strong) NSArray      * createableCommands;
@property (nonatomic, strong) NSDictionary * commandTypes;

@property (nonatomic, strong) MSPickerInputButton * pickerButton;

@property (nonatomic, strong) UIButton * editCommandsButton;
@property (nonatomic, strong) UIButton * addCommandButton;

@end

@implementation MacroCommandEditingViewController
@synthesize
editCommandsButton = _editCommandsButton,
addCommandButton   = _addCommandButton,
pickerButton       = _pickerButton,
commandTypes       = _commandTypes,
createableCommands = _createableCommands,
tableView          = _tableView,
command            = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.pickerButton                           = [[MSPickerInputButton alloc] initWithFrame:CGRectZero];
    _pickerButton.delegate                      = self;
    _pickerButton.inputView.cancelBarButtonItem = [ViewDecorator pickerInputCancelBarButtonItem];
    _pickerButton.inputView.selectBarButtonItem = [ViewDecorator pickerInputSelectBarButtonItem];
    [self.view addSubview:_pickerButton];
}

- (IBAction)addCommand:(id)sender {
    [_pickerButton becomeFirstResponder];
}

- (IBAction)editCommands:(id)sender {
    BOOL   newValue = ![_tableView isEditing];

    _editCommandsButton.selected = newValue;
    [_tableView setEditing:newValue animated:YES];
}

- (NSArray *)createableCommands {
    if (ValueIsNotNil(_createableCommands)) return _createableCommands;

    self.createableCommands = [CommandEditingViewController createableCommands];

    return _createableCommands;
}

- (NSDictionary *)commandTypes {
    if (ValueIsNotNil(_commandTypes)) return _commandTypes;

    self.commandTypes = [CommandEditingViewController commandTypes];

    return _commandTypes;
}

#pragma mark - MSPickerInputDelegate methods

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    NSString * selection   = self.createableCommands[[rows[0] integerValue]];
    NSString * classString =
        [[self.commandTypes
          keysOfEntriesPassingTest:
          ^BOOL (id key, id obj, BOOL * stop) {
            if ([selection isEqualToString:(NSString *)obj]) {
                *stop = YES;

                return YES;
            } else
                return NO;
        }

         ] anyObject];
    Class     commandClass = NSClassFromString(classString);
    Command * newCommand   = (Command *)[commandClass commandInContext:_command.managedObjectContext];

    if (newCommand) {
        [_command addCommandsObject:newCommand];
        MSLogDebug(@"%@\n\tadd new command:%@", ClassTagSelectorString, newCommand);
        [_tableView reloadData];
    }

    [_pickerButton resignFirstResponder];
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    [_pickerButton resignFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 1;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    return [self.createableCommands count];
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component {
    return self.createableCommands[row];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger   rowCount = self.command.count;

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Command         * command = self.command[indexPath.row];
    UITableViewCell * cell    = [tableView dequeueReusableCellWithIdentifier:ClassString([command class])];

    cell.imageView.image =
        [MSPainter circledText:[NSString stringWithFormat:@"%li", indexPath.row + 1]
                        font:[UIFont boldSystemFontOfSize:24]
             backgroundColor:[UIColor whiteColor]
                   textColor:nil
                        size:CGSizeMake(24, 24)];

    [cell.imageView sizeToFit];

    return cell;
}

/*
 * - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 *  // Default is 1 if not implemented
 *  return 1;
 * }
 *
 *
 *
 * - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 *  // fixed font style. use custom view (UILabel) if you want something different
 *  return nil;
 * }
 *
 *
 *
 *
 * - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
 *  // fixed font style. use custom view (UILabel) if you want something different
 *  return nil;
 * }
 *
 *
 *
 *
 * - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 *  // Individual rows can opt out of having the -editing property set for them. If not implemented,
 *  // all rows are assumed to be editable.
 *  return indexPath.row != _addCommandCellIndex;
 * }
 *
 *
 *
 *
 * - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 *  // Allows the reorder accessory view to optionally be shown for a particular row. By default,
 *  // the reorder control will be shown only if the datasource implements
 *  // -tableView:moveRowAtIndexPath:toIndexPath:
 *  return YES;
 * }
 *
 *
 *
 * - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 *  // return list of section titles to display in section index view (e.g. "ABCD...Z#")
 *  return nil;
 * }
 *
 *
 *
 * - (NSInteger)      tableView:(UITableView *)tableView
 * sectionForSectionIndexTitle:(NSString *)title
 *                   atIndex:(NSInteger)index
 * {
 *    // tell table which section corresponds to section title/index (e.g. "B",1))
 *  return 0;
 * }
 *
 *
 *
 * - (void)  tableView:(UITableView *)tableView
 * commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 * forRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle
 *  // for the cell), the dataSource must commit the change
 * }
 *
 *
 *
 * - (void)  tableView:(UITableView *)tableView
 * moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
 *      toIndexPath:(NSIndexPath *)destinationIndexPath
 * {
 *
 * }
 */

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // custom view for header. will be adjusted to default or specified header height
    CGRect   frame;

    frame.origin      = CGPointZero;
    frame.size.width  = self.view.frame.size.width;
    frame.size.height = 44.0;

    UIView * headerView = [[UIView alloc] initWithFrame:frame];

    headerView.backgroundColor   = [UIColor colorWithWhite:0.0 alpha:0.9];
    headerView.layer.borderWidth = 1.0;
    headerView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.addCommandButton        = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addCommandButton setTitle:@"Add Command" forState:UIControlStateNormal];
    [_addCommandButton setTitleShadowColor:[UIColor colorWithRed:0
                                                           green:175 / 255.0
                                                            blue:1
                                                           alpha:1]
                                  forState:UIControlStateNormal];
    _addCommandButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_addCommandButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addCommandButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _addCommandButton.frame            = CGRectMake(20, 6, 100, 32);
    _addCommandButton.titleLabel.font  = [UIFont boldSystemFontOfSize:14.0];
    [_addCommandButton addTarget:self
                          action:@selector(addCommand:)
                forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_addCommandButton];

    self.editCommandsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editCommandsButton setTitle:@"Edit Commands" forState:UIControlStateNormal];
    [_editCommandsButton setTitleShadowColor:[UIColor colorWithRed:0
                                                             green:175 / 255.0
                                                              blue:1
                                                             alpha:1]
                                    forState:UIControlStateNormal];
    [_editCommandsButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _editCommandsButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_editCommandsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editCommandsButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5]
                              forState:UIControlStateSelected];
    _editCommandsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _editCommandsButton.frame            = CGRectMake(frame.size.width - 140.0, 6, 120, 32);
    _editCommandsButton.titleLabel.font  = [UIFont boldSystemFontOfSize:14.0];
    [_editCommandsButton addTarget:self
                            action:@selector(editCommands:)
                  forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_editCommandsButton];

    return headerView;
}  /* tableView */

- (void)                           tableView:(UITableView *)tableView
    accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Command * command = self.command[indexPath.row];

    [self.delegate pushChildControllerForCommand:command];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Command * command = self.command[indexPath.row];

    [self.delegate pushChildControllerForCommand:command];
}

/*
 * - (void)tableView:(UITableView *)tableView
 * willDisplayCell:(UITableViewCell *)cell
 * forRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *
 * }
 *
 * - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 *  return 0;
 * }
 *
 * - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
 *  return 0;
 * }
 *
 * - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 *  // custom view for footer. will be adjusted to default or specified footer height
 *  return nil;
 * }
 *
 * - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView
 *       accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 * {
 *  return UITableViewCellAccessoryNone;
 * }
 *
 * - (NSIndexPath *)tableView:(UITableView *)tableView
 * willSelectRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Called before the user changes the selection. Return a new indexPath, or nil, to change the
 *  // proposed selection.
 *  return nil;
 * }
 *
 * - (NSIndexPath *) tableView:(UITableView *)tableView
 * willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  return nil;
 * }
 *
 * - (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
 *
 * }
 *
 *
 *
 * - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
 *         editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not
 *  // implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when
 *  // the table has editing property set to YES.
 *  return UITableViewCellEditingStyleNone;
 * }
 *
 *
 *
 * - (NSString *)                           tableView:(UITableView *)tableView
 * titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  return nil;
 * }
 *
 *
 *
 * - (BOOL)                      tableView:(UITableView *)tableView
 * shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Controls whether the background is indented while editing.  If not implemented, the default
 *  // is YES.  This is unrelated to the indentation level below.  This method only applies to
 *  // grouped style table views.
 *  return YES;
 * }
 *
 *
 *
 * - (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // The willBegin/didEnd methods are called whenever the 'editing' property is automatically
 *  // changed by the table (allowing insert/delete/move). This is done by a swipe activating a
 *  // single row
 *
 * }
 *
 *
 *
 * - (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
 *
 * }
 *
 *
 *
 * - (NSIndexPath *)               tableView:(UITableView *)tableView
 * targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
 *                    toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
 * {
 *  // Allows customization of the target row for a particular row as it is being moved/reordered
 *  return proposedDestinationIndexPath;
 * }
 *
 *
 *
 * - (NSInteger)            tableView:(UITableView *)tableView
 * indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // return 'depth' of row for hierarchies
 *  return 0;
 * }
 *
 *
 *
 * - (BOOL)               tableView:(UITableView *)tableView
 * shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  return YES;
 * }
 *
 *
 * - (BOOL)tableView:(UITableView *)tableView
 * canPerformAction:(SEL)action
 * forRowAtIndexPath:(NSIndexPath *)indexPath
 *     withSender:(id)sender
 * {
 *  return YES;
 * }
 *
 *
 * - (void)tableView:(UITableView *)tableView
 *  performAction:(SEL)action
 * forRowAtIndexPath:(NSIndexPath *)indexPath
 *     withSender:(id)sender
 * {
 *
 * }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setTableView:nil];
    [self setPickerButton:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
