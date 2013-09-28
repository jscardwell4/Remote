//
//  BankTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankTableViewController.h"
#import "Bank.h"
#import "BankViewController.h"
#import "MSRemoteAppController.h"
#import "BankCollectionViewController.h"
#import "CoreDataManager.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


#define HEADER_HEIGHT 38.0


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankTableViewController class extension
////////////////////////////////////////////////////////////////////////////////

@interface BankTableViewController ()

@property (nonatomic, assign, readonly) BankViewController         * bankViewController;
@property (nonatomic, strong)           Class                        itemClass;
@property (nonatomic, weak)             NSFetchedResultsController * bankableItems;
@property (nonatomic, strong) IBOutlet  UIToolbar                  * tableHeaderView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankTableViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankTableViewController
{
    BankFlags _flags;
    NSMutableSet * _hiddenSections;
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    assert(self.view);
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if ([parent isKindOfClass:[BankViewController class]])
    {
        _bankViewController = (BankViewController *)parent;
        self.itemClass = _bankViewController.itemClass;
        self.bankableItems = _bankViewController.bankableItems;
    }

    else
    {
        _bankViewController = nil;
        _bankableItems = nil;
        self.itemClass = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hiddenSections = [NSMutableSet set];
    if (self.itemClass && (_flags & BankThumbnail))
        self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tableHeaderView.superview)
        self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)setItemClass:(Class<Bankable>)itemClass
{
    _itemClass = itemClass;
    _flags = (_itemClass ? [itemClass bankFlags] : BankDefault);
    if ((_flags & BankThumbnail) && [self isViewLoaded])
        self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id<Bankable> item = [self.bankableItems objectAtIndexPath:indexPath];
    assert(item && [item conformsToProtocol:@protocol(Bankable)]);



    if (_flags & BankPreview)
        cell.imageView.image = item.thumbnail;


    cell.accessoryType = (_flags & BankDetail
                          ? UITableViewCellAccessoryDetailDisclosureButton
                          : UITableViewCellAccessoryNone);

    cell.textLabel.text = item.name;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////



- (IBAction)toggleItemsForSection:(UITapGestureRecognizer *)gesture
{
    if (!_bankableItems) return;

    NSInteger section = gesture.tag;

    if ([_hiddenSections containsObject:@(section)])
        [_hiddenSections removeObject:@(section)];
    else
        [_hiddenSections addObject:@(section)];

    [self.tableView reloadData];
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex)
    {
        [self.bankViewController showThumbnailView];
        sender.selectedSegmentIndex = 0;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.bankableItems.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.bankableItems.sections count] && ![_hiddenSections containsObject:@(section)]
            ? [self.bankableItems.sections[section] numberOfObjects]
            : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSSTATIC_IDENTIFIER(Cell);
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                              forIndexPath:indexPath];

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MSSTATIC_STRING_CONST kHeaderIdentifier = @"Header";

//    if (_flags & BankNoSections) return nil;

    BankTableHeaderView * view = [tableView
                                  dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
    [view.button setTitle:[self.bankableItems.sections[section] name]
                 forState:UIControlStateNormal];
    view.button.tag = section;

    if (![view.button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside])
        [view.button addTarget:self action:@selector(toggleItemsForSection:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}
*/




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.bankableItems.sections[section] name];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.bankViewController detailItem:[_bankableItems objectAtIndexPath:indexPath]];
}

- (void)                           tableView:(UITableView *)tableView
    accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.bankViewController detailItem:[_bankableItems objectAtIndexPath:indexPath]];
}


- (void)        tableView:(UITableView *)tableView
    willDisplayHeaderView:(UIView *)view
               forSection:(NSInteger)section
{
    MSSTATIC_NAMETAG(Toggle);

    if (![view gestureWithNametag:ToggleNametag])
    {
        UITapGestureRecognizer * gesture = [UITapGestureRecognizer
                                            gestureWithTarget:self
                                                       action:@selector(toggleItemsForSection:)];
        gesture.nametag = ToggleNametag;
        gesture.tag = section;
        [view addGestureRecognizer:gesture];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (_flags & BankNoSections ? 0.0 : HEADER_HEIGHT);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Fetched results controller delegate
////////////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
