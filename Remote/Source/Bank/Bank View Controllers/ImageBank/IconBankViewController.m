//
// IconBankViewController.m
// Remote
//
// Created by Jason Cardwell on 6/14/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "IconBankViewController.h"
#import "IconBankSubCategoriesViewController.h"

static int ddLogLevel = DefaultDDLogLevel;

@implementation IconBankViewController
@synthesize categories    = _categories;
@synthesize modalDelegate = _modalDelegate;

/*
 * init
 */
- (id)init {
    self = [super initWithNibName:@"IconBankViewController" bundle:nil];
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

    self.navigationItem.title                        = @"Icon Sets";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

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
 * viewWillAppear:
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

/*
 * categories
 */
- (NSArray *)categories {
    if (ValueIsNotNil(_categories)) return _categories;

    NSString * plistPath = [MainBundle pathForResource:@"IconSets" ofType:@"plist"];

    _plist      = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    _categories = [NSArray arrayWithArray:[_plist allKeys]];
    DDLogVerbose(@"categories = %@", _categories);

    return _categories;
}

#pragma mark - Table view data source

/*
 * numberOfSectionsInTableView:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
// #warning Potentially incomplete method implementation.

// Return the number of sections.
    return 1;
}

/*
 * tableView:numberOfRowsInSection:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
// #warning Incomplete method implementation.

// Return the number of rows in the section.
    return [self.categories count];
}

/*
 * tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell)) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    // Configure the cell...
    cell.textLabel.text = self.categories[indexPath.row];

    return cell;
}

/*
 * // Override to support conditional editing of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Return NO if you do not want the specified item to be editable.
 *  return YES;
 * }
 */

/*
 * // Override to support editing the table view.
 * - (void)tableView:(UITableView *)tableView
 * commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath
 * *)indexPath
 * {
 *  if (editingStyle == UITableViewCellEditingStyleDelete) {
 *      // Delete the row from the data source
 *      [tableView deleteRowsAtIndexPaths: @[indexPath]
 * withRowAnimation:UITableViewRowAnimationFade];
 *  }
 *  else if (editingStyle == UITableViewCellEditingStyleInsert) {
 *      // Create a new instance of the appropriate class, insert it into the array, and add a new
 * row to the table view
 *  }
 * }
 */

/*
 * // Override to support rearranging the table view.
 * - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
 * toIndexPath:(NSIndexPath *)toIndexPath
 * {
 * }
 */

/*
 * // Override to support conditional rearranging of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Return NO if you do not want the item to be re-orderable.
 *  return YES;
 * }
 */

#pragma mark - Table view delegate

/*
 * tableView:didSelectRowAtIndexPath:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    NSString                            * key                  = self.categories[indexPath.row];
    IconBankSubCategoriesViewController * detailViewController =
        [[IconBankSubCategoriesViewController alloc] initWithPlist:_plist iconSet:key];

    detailViewController.modalDelegate = _modalDelegate;
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
