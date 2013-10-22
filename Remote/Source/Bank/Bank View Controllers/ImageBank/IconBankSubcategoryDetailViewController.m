//
// IconBankSubcategoryDetailViewController.m
// Remote
//
// Created by Jason Cardwell on 6/14/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "IconBankSubcategoryDetailViewController.h"
#import "BankObject.h"

static int ddLogLevel = DefaultDDLogLevel;

@interface IconBankSubcategoryDetailViewController ()

// - (NSString *)fileNamePrefix;
// - (NSString *)trimmedFileNameForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation IconBankSubcategoryDetailViewController
@synthesize modalDelegate = _modalDelegate;

/*
 * initWithPlist:iconSet:subcategory:
 */
- (id)initWithPlist:(NSDictionary *)plist iconSet:(NSString *)iconSet subcategory:(NSString *)subcategory {
    self = [super initWithNibName:@"IconBankSubCategoriesViewController" bundle:nil];
    if (self) {
        //
        _plist       = plist;
        _iconSet     = iconSet;
        _subcategory = subcategory;

        /*NSArray *bundlePNGs = [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
         * inDirectory:nil];
         * NSString *fileNamePrefix = [self fileNamePrefix];
         * NSIndexSet *subcategoryFiles = [bundlePNGs indexesOfObjectsPassingTest:^BOOL(id obj,
         * NSUInteger idx, BOOL *stop) {
         *  //
         *  NSString *filePath = (NSString *)obj;
         *  NSString *fileName = [filePath lastPathComponent];
         *  if (![fileName hasPrefix:fileNamePrefix])
         *      return NO;
         *  if (![fileName hasSuffix:@"@2x.png"])
         *      return NO;
         *  else
         *      return YES;
         * }];*/

        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IconImage"];
        NSPredicate    * predicate    = [NSPredicate predicateWithFormat:@"subcategory == %@",
                                         _subcategory];

        [fetchRequest setPredicate:predicate];

        NSError * error          = nil;
        NSArray * fetchedObjects = [[MSRemoteAppController managedObjectContext] executeFetchRequest:fetchRequest error:&error];

        if (ValueIsNil(fetchedObjects)) DDLogWarn(@"could not located IconImages for iconSet:'%@' and subcategory:'%@'", _iconSet, _subcategory);

// _icons = [[bundlePNGs objectsAtIndexes:subcategoryFiles] retain];
        _icons = fetchedObjects;
    }

    return self;
}

/*- (NSString *)fileNamePrefix {
 *  return [NSString stringWithFormat:@"%@<%@>~",_iconSet, _subcategory];
 * }*/
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

    if (ValueIsNotNil(_subcategory)) self.navigationItem.title = _subcategory;

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
    return [_icons count];
}

/*
 * tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell)) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    // Configure the cell...
// cell.textLabel.text = [self trimmedFileNameForIndexPath:indexPath];
// cell.imageView.image = [UIImage imageWithContentsOfFile: _icons[indexPath.row]];
    BOImage * iconImage = _icons[indexPath.row];

    cell.textLabel.text  = iconImage.name;
    cell.imageView.image = [UIImage imageNamed:iconImage.fileName];

    return cell;
}

/*- (NSString *)trimmedFileNameForIndexPath:(NSIndexPath *)indexPath {
 *  NSString *filePath = _icons[indexPath.row];
 *  NSString *fileName = [filePath lastPathComponent];
 *  NSUInteger prefixCharacterCount = [[self fileNamePrefix] length];
 *  NSUInteger suffixCharacterCount = [@"@2x.png" length];
 *  NSUInteger trimmedLength = [fileName length] - suffixCharacterCount - prefixCharacterCount;
 *  NSRange substringRange = NSMakeRange(prefixCharacterCount, trimmedLength);
 *  NSString *trimmedName = [fileName substringWithRange:substringRange];
 *  return trimmedName;
 * }*/

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
    if (ValueIsNotNil(_modalDelegate)) {
// NSString *iconString = [[self fileNamePrefix] stringByAppendingString:[self
// trimmedFileNameForIndexPath:indexPath]];
        BOImage * iconImage  = _icons[indexPath.row];
        NSString         * iconString = iconImage.fileName;

        [_modalDelegate didSelectIconFile:iconString];
        [_modalDelegate didDismissModalViewController:self];
    }
}

@end
