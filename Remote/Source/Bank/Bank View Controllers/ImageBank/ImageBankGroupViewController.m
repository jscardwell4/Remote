//
// ImageBankGroupViewController.m
// Remote
//
// Created by Jason Cardwell on 5/29/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ImageBankGroupViewController.h"
#import "GalleryGroup.h"
#import "BankObject.h"

static int ddLogLevel = DefaultDDLogLevel;

@interface ImageBankGroupViewController ()

@property (nonatomic, strong) NSArray * iconArray;
@property (nonatomic, strong) NSArray * backgroundArray;
- (void)handleTap:(UITapGestureRecognizer *)sender;
- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)selectImage;

@end

@implementation ImageBankGroupViewController
@synthesize imageViewContainer                  = _imageViewContainer;
@synthesize imageView                           = _imageView;
@synthesize group                               = _group;
@synthesize fetchedBackgroundsResultsController = __fetchedBackgroundsResultsController;
@synthesize fetchedIconsResultsController       = __fetchedIconsResultsController;
@synthesize managedObjectContext                = __managedObjectContext;
// @synthesize modalDelegate = _modalDelegate;
@synthesize iconArray, backgroundArray;

/*
 * handleCancellation
 */
- (void)handleCancellation {
    _mutatingImage = nil;
}

/*
 * handleEnteredValue:
 */
- (void)handleEnteredValue:(NSString *)value {
    _mutatingImage.name = value;
    _mutatingImage      = nil;
}

/*
 * handleTap:
 */
- (void)handleTap:(UITapGestureRecognizer *)sender {
    DDLogSelector(@"");
    self.imageViewContainer.hidden = YES;
}

/*
 * initWithGroup:
 */
- (id)initWithGroup:(GalleryGroup *)group {
    self = [super initWithNibName:@"ImageBankGroupViewController" bundle:nil];
    if (self) self.group = group;

    return self;
}

/*
 * initWithStyle:
 */
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }

    return self;
}

#pragma mark - View lifecycle

/*
 * viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageViewContainer.frame  = self.navigationController.view.frame;
    self.imageViewContainer.center = self.navigationController.view.center;
    [self.navigationController.view addSubview:self.imageViewContainer];

    UITapGestureRecognizer * tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

    [self.imageViewContainer addGestureRecognizer:tapRecognizer];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
    // controller.
// if (ValueIsNil(_modalDelegate)) self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
 *
 * setModalDelegate:
 *
 * - (void)setModalDelegate:(id <MSModalViewControllerDelegate, ImageSelection> )modalDelegate {
 * if (ValueIsNil(modalDelegate)) {
 *  self.navigationItem.rightBarButtonItem = self.editButtonItem;
 * } else {
 *  self.navigationItem.rightBarButtonItem =
 *    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
 *                                                  target:modalDelegate
 *                                                  action:@selector(didDismissModalView)];
 * }
 * _modalDelegate = modalDelegate;
 * }
 *
 */

/*
 * selectImage
 */
- (void)selectImage
{}

/*
 * viewDidUnload
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setImageView:nil];
    [self setImageViewContainer:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

/*
 * viewWillAppear:
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (ValueIsNotNil(_group)) self.navigationItem.title = self.group.name;
}

/*
 * viewDidAppear:
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
 * viewWillDisappear:
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/*
 * viewDidDisappear:
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

/*
 * numberOfSectionsInTableView:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

// return [[self.fetchedResultsController sections] count];
    return 2;
}

/*
 * tableView:numberOfRowsInSection:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
// id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]
// objectAtIndex:section];
// return [sectionInfo numberOfObjects];
    NSFetchedResultsController * resultsController = section == 0 ? self.fetchedBackgroundsResultsController : self.fetchedIconsResultsController;
    NSInteger                    numOfRows         = [[resultsController fetchedObjects] count];

    return numOfRows;
}

/*
 * tableView:titleForHeaderInSection:
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Backgrounds" : @"Icons";
}

/*
 * tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

        // Add custom accessory button
        NSString * iconPath   = [[NSBundle mainBundle] pathForResource:@"Quicklook" ofType:@"png"];
        UIButton * iconButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [iconButton setImage:[UIImage imageWithContentsOfFile:iconPath] forState:UIControlStateNormal];
        [iconButton addTarget:self
                       action:@selector(accessoryButtonTapped:withEvent:)
             forControlEvents:UIControlEventTouchUpInside];
        iconButton.frame   = CGRectMake(0, 0, 44, 44);
        cell.accessoryView = iconButton;

        // Add custom editing accessory button
        iconPath   = [[NSBundle mainBundle] pathForResource:@"Pencil-Slanted" ofType:@"png"];
        iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [iconButton setImage:[UIImage imageWithContentsOfFile:iconPath] forState:UIControlStateNormal];
        [iconButton addTarget:self
                       action:@selector(accessoryButtonTapped:withEvent:)
             forControlEvents:UIControlEventTouchUpInside];
        iconButton.frame          = CGRectMake(0, 0, 44, 44);
        cell.editingAccessoryView = iconButton;

        cell.indentationLevel = 1;
    }

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    // Return NO if you do not want the specified item to be editable.
    return NO;  // ValueIsNil(self.modalDelegate);
}

/*
 * tableView:commitEditingStyle:forRowAtIndexPath:
 */
- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSFetchedResultsController * resultsController = indexPath.section == 0 ? __fetchedBackgroundsResultsController : __fetchedIconsResultsController;
        NSManagedObjectContext     * context           = [resultsController managedObjectContext];

        [context deleteObject:[resultsController objectAtIndexPath:indexPath]];

        // Save the context.
        NSError * error = nil;

        if (![context save:&error]) {
            /*
             * Replace this implementation with code to handle the error appropriately.
             *
             * abort() causes the application to generate a crash log and terminate. You should not
             * use this
             * function in a shipping application, although it may be useful during development. If
             * it is not
             * possible to recover from the error, display an alert panel that instructs the user to
             * quit the
             * application by pressing the Home button.
             */
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/*
 * tableView:canMoveRowAtIndexPath:
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

    // The table view should not be re-orderable.
    return NO;
}

/*
 * accessoryButtonTapped:withEvent:
 */
- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView
                               indexPathForRowAtPoint:[[[event touchesForView:button] anyObject]
                                                       locationInView:self.tableView]];

    if (ValueIsNil(indexPath)) return;

    [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

#pragma mark - Table view delegate

/*
 * tableView:accessoryButtonTappedForRowWithIndexPath:
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    static CGSize    baseSize    = {.width = 300.0, .height = 347.0};
    static CGPoint   centerPoint = {.x = 160.0, .y = 240.0};
    // Delete the managed object for the given index path
    NSFetchedResultsController * resultsController = indexPath.section == 0 ? __fetchedBackgroundsResultsController : __fetchedIconsResultsController;
    BOImage               * image             = [resultsController objectAtIndexPath:indexPath];

    if (self.tableView.editing)
        _mutatingImage = image;
    else {
        _imageView.image = image.image;

        CGRect   newFrame;

        newFrame.size         = [image.image sizeThatFits:baseSize];
        self.imageView.frame  = newFrame;
        self.imageView.center = centerPoint;

        self.imageViewContainer.hidden = NO;
    }
}

/*
 * configureCell:atIndexPath:
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BOBackgroundImage * image = [self.fetchedBackgroundsResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

        cell.textLabel.text  = image.name;
        cell.imageView.image = image.thumbnail;
    } else {
        BOImage * image = [self.fetchedIconsResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

        cell.textLabel.text  = image.name;
        cell.imageView.image = image.thumbnail;
    }
}

/*
 * tableView:didSelectRowAtIndexPath:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     * if (ValueIsNotNil(_modalDelegate)) {
     *  [_modalDelegate selectedImage:[self.fetchedResultsController objectAtIndexPath:indexPath]];
     *  [_modalDelegate didDismissModalView];
     * }
     */
}

/*
 * insertNewObject
 */
- (void)insertNewObject {
    // Create a new instance of the entity managed by the fetched results controller.
}

#pragma mark - Fetched results controller

/*
 * fetchedBackgroundsResultsController
 */
- (NSFetchedResultsController *)fetchedBackgroundsResultsController {
    if (ValueIsNotNil(__fetchedBackgroundsResultsController)) return __fetchedBackgroundsResultsController;

    /*
     * Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"BackgroundImage"
                                               inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"group == %@", _group];

    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
// NSSortDescriptor * sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"type"
// ascending:YES];
    NSSortDescriptor * sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray          * sortDescriptors = [[NSArray alloc] initWithObjects:  /*sortDescriptor1,*/ sortDescriptor2, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController * aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];

    aFetchedResultsController.delegate       = self;
    self.fetchedBackgroundsResultsController = aFetchedResultsController;

    NSError * error = nil;

    if (![self.fetchedBackgroundsResultsController performFetch:&error]) {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You
         * should not use this function in a shipping application, although it may
         * be useful during development. If it is not possible to recover from the
         * error, display an alert panel that instructs the user to quit the application
         * by pressing the Home button.
         */
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSMutableString * logString = [[NSMutableString alloc] initWithString:@"Backgrounds:\n"];

    for (BOBackgroundImage * image in[__fetchedBackgroundsResultsController fetchedObjects]) {
        [logString appendFormat:@"\t%@\n", image.name];
    }

    NSLog(@"%@", logString);

    return __fetchedBackgroundsResultsController;
}  /* fetchedBackgroundsResultsController */

/*
 * fetchedIconsResultsController
 */
- (NSFetchedResultsController *)fetchedIconsResultsController {
    if (ValueIsNotNil(__fetchedIconsResultsController)) return __fetchedIconsResultsController;

    /*
     * Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"IconImage"
                                               inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"group == %@", _group];

    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    // NSSortDescriptor * sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"type"
    // ascending:YES];
    NSSortDescriptor * sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray          * sortDescriptors = [[NSArray alloc] initWithObjects:  /*sortDescriptor1,*/ sortDescriptor2, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController * aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];

    aFetchedResultsController.delegate = self;
    self.fetchedIconsResultsController = aFetchedResultsController;

    NSError * error = nil;

    if (![self.fetchedBackgroundsResultsController performFetch:&error]) {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You
         * should not use this function in a shipping application, although it may
         * be useful during development. If it is not possible to recover from the
         * error, display an alert panel that instructs the user to quit the application
         * by pressing the Home button.
         */
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSMutableString * logString = [[NSMutableString alloc] initWithString:@"Icons:\n"];

    for (BOImage * image in[__fetchedIconsResultsController fetchedObjects]) {
        [logString appendFormat:@"\t%@\n", image.name];
    }

    NSLog(@"%@", logString);

    return __fetchedIconsResultsController;
}  /* fetchedIconsResultsController */

/*
 * managedObjectContext
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (ValueIsNotNil(__managedObjectContext)) return __managedObjectContext;

    self.managedObjectContext = [MSRemoteAppController managedObjectContext];

    return __managedObjectContext;
}

#pragma mark - Fetched results controller delegate

/*
 * controllerWillChangeContent:
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

/*
 * controller:didChangeSection:atIndex:forChangeType:
 */
- (void)  controller:(NSFetchedResultsController *)controller
    didChangeSection:(id <NSFetchedResultsSectionInfo> )sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert :
            [self.tableView
             insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                           withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete :
            [self.tableView
             deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                           withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/*
 * controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView * tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert :
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete :
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate :
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove :
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }  /* switch */
}

/*
 * controllerDidChangeContent:
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
 * // Implementing the above methods to update the table view in response to individual changes may
 * have
 * performance implications if a large number of changes are made simultaneously. If this proves to
 * be an issue,
 * you can instead just implement controllerDidChangeContent: which notifies the delegate that all
 * section and
 * object changes have been processed.
 *
 * - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 * {
 * // In the simplest, most efficient, case, reload the table view.
 * [self.tableView reloadData];
 * }
 */

@end
