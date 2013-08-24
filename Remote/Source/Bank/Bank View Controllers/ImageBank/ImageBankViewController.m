//
// ImageBankViewController.m
// Remote
//
// Created by Jason Cardwell on 5/29/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ImageBankViewController.h"
#import "MSRemoteAppController.h"
#import "GalleryGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation ImageBankViewController
@synthesize fetchedGroups = _fetchedGroups;
@synthesize modalDelegate = _modalDelegate;

/*
 * init
 */
- (id)init {
    self = [super initWithNibName:@"ImageBankViewController" bundle:nil];
    if (self) {
        //
    }

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

// self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
    // controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

/*
 * setModalDelegate:
 */
- (void)setModalDelegate:(id <MSModalViewControllerDelegate, ImageSelection> )modalDelegate {
    if (ValueIsNil(modalDelegate))
        self.navigationItem.rightBarButtonItem = nil;
    else
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:modalDelegate
                                                          action:@selector(didDismissModalView)];

    _modalDelegate = modalDelegate;
}

/*
 * viewWillAppear:
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
// self.navigationController.navigationBarHidden = NO;
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
 * fetchedGroups
 */
- (NSArray *)fetchedGroups {
    if (ValueIsNotNil(_fetchedGroups)) return _fetchedGroups;

    NSManagedObjectContext * context      = [MSRemoteAppController managedObjectContext];
    NSFetchRequest         * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription    * entity       = [NSEntityDescription entityForName:@"GalleryGroup"
                                                        inManagedObjectContext:context];

    [fetchRequest setEntity:entity];

    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    NSError * error = nil;

    self.fetchedGroups = [context executeFetchRequest:fetchRequest error:&error];
    if (ValueIsNil(_fetchedGroups)) {
        DDLogWarn(@"No gallery group objects could be found");
        self.fetchedGroups = [NSArray array];
    }

    return _fetchedGroups;
}

/*
 * numberOfSectionsInTableView:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

/*
 * tableView:numberOfRowsInSection:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.fetchedGroups count];
}

/*
 * tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell))
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

    // Configure the cell...
    GalleryGroup * group = (GalleryGroup *)self.fetchedGroups[indexPath.row];

    cell.textLabel.text = group.name;

    return cell;
}

#pragma mark - Table view delegate

/*
 * tableView:didSelectRowAtIndexPath:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    GalleryGroup                 * group                = (GalleryGroup *)self.fetchedGroups[indexPath.row];
    ImageBankGroupViewController * detailViewController = [[ImageBankGroupViewController alloc]
                                                           initWithGroup:group];

    detailViewController.modalDelegate = self.modalDelegate;
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
