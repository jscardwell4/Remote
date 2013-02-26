//
// IconSelectionViewController.m
// iPhonto
//
// Created by Jason Cardwell on 3/31/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "IconSelectionViewController.h"
#import "GalleryImage.h"

#define MAX_COL 5
#define MIN_COL 1

static UIColor * kSelectedIconColor;
static int       ddLogLevel = DefaultDDLogLevel;

@interface IconSelectionViewController ()
@property (nonatomic, strong) NSArray * fetchedIcons;
- (IBAction)selectIconAction:(UITapGestureRecognizer *)sender;
- (GalleryIconImage *)iconForRow:(NSUInteger)row column:(NSUInteger)column;
@property (nonatomic, assign) NSUInteger        rowCount;
@property (nonatomic, assign) NSUInteger        iconCount;
@property (nonatomic, assign) NSInteger         selectedIcon;
@property (strong, nonatomic) IBOutlet UIView * tableFooter;
- (void)recolorIconAtIndex:(NSUInteger)index withColor:(UIColor *)color;
- (NSInteger)iconIndexForRow:(NSUInteger)row column:(NSUInteger)column;
- (NSIndexPath *)indexPathForIconAtIndex:(NSUInteger)index;
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)saveAction:(UIButton *)sender;

@end

@implementation IconSelectionViewController
@synthesize fetchedIcons = _fetchedIcons;
@synthesize context      = _context;
@synthesize delegate     = _delegate;
@synthesize rowCount     = _rowCount;
@synthesize iconCount    = _iconCount;
@synthesize selectedIcon = _selectedIcon;
@synthesize tableFooter  = _tableFooter;

+ (void)initialize {
    if (self == [IconSelectionViewController class]) kSelectedIconColor = [UIColor colorWithRed:0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
}

- (NSArray *)fetchedIcons {
    if (ValueIsNotNil(_fetchedIcons)) return _fetchedIcons;

    self.selectedIcon = -1;

    [_context performBlockAndWait:^{
                  NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GalleryIconImage"];

                  NSError * error = nil;
                  NSArray * fetchedObjects = [_context           executeFetchRequest:fetchRequest
                                                                     error:&error];
                  if (ValueIsNil(fetchedObjects)) {
                  DDLogError(@"%@\n\tcould not retrieve icons from database", ClassTagString);
                  self.fetchedIcons = [NSArray array];
                  } else
                  self.fetchedIcons = fetchedObjects;
    }

    ];

    return _fetchedIcons;
}

- (IBAction)selectIconAction:(UITapGestureRecognizer *)sender {
    DDLogDebug(@"%@\n\tselection action from sender:%@", ClassTagString, sender);

    CGPoint   touchLocation = [sender locationInView:self.tableView];
    UIView  * touchedView   = [self.tableView hitTest:touchLocation withEvent:nil];

    if ([touchedView isMemberOfClass:[UIImageView class]]) {
        NSUInteger   column = touchedView.tag - 1;
        NSUInteger   row    =
            [self.tableView indexPathForCell:(UITableViewCell *)touchedView.superview.superview].row;
        GalleryIconImage * icon = [self iconForRow:row column:column];

        if (ValueIsNotNil(icon)) {
            NSUInteger   touchedIcon = row * MAX_COL + column;

            if (touchedIcon == _selectedIcon) {
                self.selectedIcon = -1;
                [self recolorIconAtIndex:touchedIcon withColor:[UIColor whiteColor]];
            } else {
                if (_selectedIcon >= 0) [self recolorIconAtIndex:_selectedIcon withColor:[UIColor whiteColor]];

                self.selectedIcon = touchedIcon;
                [self recolorIconAtIndex:_selectedIcon withColor:kSelectedIconColor];
            }

// [touchedView setNeedsDisplay];
        }
    }
}

- (void)recolorIconAtIndex:(NSUInteger)index withColor:(UIColor *)color {
    NSIndexPath     * indexPath = [self indexPathForIconAtIndex:index];
    UITableViewCell * cell      =
        [self.tableView
         cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                  inSection:0]];
    UIImageView * iconView = (UIImageView *)[cell viewWithTag:indexPath.section + 1];

    iconView.image = [iconView.image recoloredImageWithColor:color];
}

- (NSInteger)iconIndexForRow:(NSUInteger)row column:(NSUInteger)column {
    return row * MAX_COL + column;
}

- (NSIndexPath *)indexPathForIconAtIndex:(NSUInteger)index {
    NSUInteger    row       = index / 5;
    NSUInteger    column    = index % 5;
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:column];

    return indexPath;
}

- (IBAction)cancelAction:(UIButton *)sender {
    [_delegate iconSelectorDidCancel:self];
}

- (IBAction)saveAction:(UIButton *)sender {
    if (_selectedIcon < 0)
        [_delegate iconSelectorDidCancel:self];
    else {
        GalleryIconImage * icon = self.fetchedIcons[_selectedIcon];

        [_delegate iconSelector:self didSelectIcon:icon];
    }
}

- (GalleryIconImage *)iconForRow:(NSUInteger)row column:(NSUInteger)column {
    if (row > _rowCount || column > MAX_COL - 1) return nil;

    NSInteger   iconIndex = [self iconIndexForRow:row column:column];

    if (iconIndex > self.iconCount) return nil;

    return (GalleryIconImage *)self.fetchedIcons[iconIndex];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isMemberOfClass:[UIButton class]]) return NO;
    else return YES;
}

- (BOOL)                             gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSUInteger)rowCount {
    if (_rowCount != 0) return _rowCount;

    self.iconCount = [self.fetchedIcons count];
    self.rowCount  = _iconCount / MAX_COL;
    if (_iconCount % MAX_COL != 0) _rowCount++;

    return _rowCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.rowCount;
}

// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
// return self.tableFooter;
// }

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _tableFooter.frame.size.height;
}

// - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
// return _tableFooter.frame.size.height;
// }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const   CellIdentifier       = @"Cell";
    static const CGSize       originalIconViewSize = (CGSize) {.width = 35.0, .height = 35.0};
    UITableViewCell         * cell                 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    @autoreleasepool {
        UIImageView      * iconView   = nil;
        GalleryIconImage * iconImage  = nil;
        NSUInteger         row        = indexPath.row;
        NSUInteger         iconNumber = row * 5;

        for (int i = 0; i < MAX_COL; i++) {
            iconView  = (UIImageView *)[cell viewWithTag:i + 1];
            iconImage = [self iconForRow:row column:i];
            if (ValueIsNotNil(iconImage)) {
                if (_selectedIcon == iconNumber + i) iconView.image = [iconImage.preview recoloredImageWithColor:kSelectedIconColor];
                else iconView.image = iconImage.preview;

                CGSize   iconSize = iconImage.size;

                if (iconImage.useRetinaScale) {
                    iconSize.width  /= 2.0;
                    iconSize.height /= 2.0;
                }

                CGSize   adjustedSize = CGSizeFitToSize(iconSize, originalIconViewSize);

                [iconView resizeFrameToSize:adjustedSize anchored:YES];
            } else
                iconView.image = nil;
        }
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
// [self.delegate iconSelector:self didSelectIcon: self.fetchedIcons[indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setTableFooter:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
