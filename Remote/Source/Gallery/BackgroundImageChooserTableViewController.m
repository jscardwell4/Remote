//
// BackgroundImageChooserTableViewController.m
// iPhonto
//
// Created by Jason Cardwell on 3/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BackgroundImageChooserTableViewController.h"
#import "Remote.h"
#import "GalleryImage.h"

static int   ddLogLevel = DefaultDDLogLevel;

@interface BackgroundImageChooserTableViewController ()

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer;
- (void)cancel;
- (void)save;

@property (nonatomic, strong) NSArray              * fetchedBackgrounds;
@property (nonatomic, strong) IBOutlet UIView      * imageViewContainer;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@end

@implementation BackgroundImageChooserTableViewController

@synthesize remote;
@synthesize fetchedBackgrounds = _fetchedBackgrounds;
@synthesize imageView          = _imageView;
@synthesize imageViewContainer = _imageViewContainer;

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

/*
 * didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 * viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageView                    = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    _imageView.hidden = YES;

    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

    [self.imageView addGestureRecognizer:tapRecognizer];

    UIToolbar       * headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem * cancelButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem * flexSpace     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * saveButton    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];

    headerToolbar.items            = @[cancelButton, flexSpace, saveButton];
    self.tableView.tableHeaderView = headerToolbar;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
    // controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
 * cancel
 */
- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * save
 */
- (void)save {
    NSUInteger               selectedRow   = [self.tableView indexPathForSelectedRow].row;
    GalleryBackgroundImage * selectedImage = self.fetchedBackgrounds[selectedRow];

    self.remote.backgroundImage = selectedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * handleTap:
 */
- (void)handleTap:(UITapGestureRecognizer *)sender {
    DDLogSelector(@"");
    self.imageView.hidden = YES;
}

/*
 * fetchedBackgrounds
 */
- (NSArray *)fetchedBackgrounds {
    if (ValueIsNotNil(_fetchedBackgrounds) || ValueIsNil(remote)) return _fetchedBackgrounds;

    [remote.managedObjectContext
     performBlockAndWait:^{
         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BackgroundImage"];

         NSError * error = nil;
         self.fetchedBackgrounds = [remote.managedObjectContext
                                   executeFetchRequest:fetchRequest
                                                 error:&error];
         if (ValueIsNil(_fetchedBackgrounds)) DDLogWarn(@"fetch results for background images was empty");
     }

    ];

    return _fetchedBackgrounds;
}

#pragma mark - Table view data source

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
    return [self.fetchedBackgrounds count];
}

/*
 * tableView:accessoryButtonTappedForRowWithIndexPath:
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    static CGSize            baseSize    = {.width = 300.0, .height = 347.0};
    static CGPoint           centerPoint = {.x = 160.0, .y = 240.0};
    GalleryBackgroundImage * image       = (GalleryBackgroundImage *)self.fetchedBackgrounds[indexPath.row];

    _imageView.image = image.image;

    CGRect   newFrame = CGRectZero;

    newFrame.size         = [image.image sizeThatFits:baseSize];
    self.imageView.frame  = newFrame;
    self.imageView.center = centerPoint;

    self.imageView.hidden = NO;
}

/*
 * tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell)) {
        cell               = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    // Configure the cell...
    GalleryBackgroundImage * backgroundImage = (GalleryBackgroundImage *)self.fetchedBackgrounds[indexPath.row];

    cell.textLabel.text  = backgroundImage.name;
    cell.imageView.image = backgroundImage.thumbnail;

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

    /*
     * <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc]
     * initWithNibName:@"<#Nib name#>" bundle:nil];
     * // ...
     * // Pass the selected object to the new view controller.
     * [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
