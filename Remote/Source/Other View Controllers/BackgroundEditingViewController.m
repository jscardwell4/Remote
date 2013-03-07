//
// BackgroundEditingViewController.m
// iPhonto
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BackgroundEditingViewController.h"
#import "GalleryImage.h"
#import "StoryboardProxy.h"
#import "Painter.h"

static int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface BackgroundEditingViewController () <MSResettable, ColorSelectionDelegate, UITableViewDataSource, UITableViewDelegate>

- (IBAction)cancelAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
- (void)selectImageAtIndex:(NSUInteger)index;
- (IBAction)dismissPreview:(UITapGestureRecognizer *)sender;
- (IBAction)backgroundColorInputAction:(id)sender;

@property (nonatomic, strong) ColorSelectionViewController * colorSelectionVC;
@property (strong, nonatomic) IBOutlet UIView              * colorSelectionContainer;
@property (nonatomic, assign, readonly) BOOL                 hasChanges;
@property (nonatomic, strong) NSArray                      * fetchedBackgrounds;
@property (strong, nonatomic) IBOutlet UITableView         * tableView;
@property (strong, nonatomic) IBOutlet UIImageView         * imagePreview;
@property (strong, nonatomic) IBOutlet MSColorInputButton  * colorInputButton;

- (void)initializeColorSelectionControllerWithColor:(UIColor *)color;
- (void)selectRowForGalleryBackgroundImage:(GalleryBackgroundImage *)bgImage;
- (void)resetUI;

- (void)setBorderForView:(UIView *)view selected:(BOOL)selected;

- (UIImage *)noBackgroundImage;

@end

@implementation BackgroundEditingViewController {
    NSInteger   selectedIndex;
}

@synthesize sourceObject = _sourceObject;
// @synthesize delegate = _delegate;
@synthesize colorSelectionContainer = _colorSelectionContainer;
@synthesize hasChanges;
@synthesize fetchedBackgrounds = _fetchedBackgrounds;
@synthesize tableView          = _tableView;
@synthesize colorSelectionVC   = _colorSelectionVC;
@synthesize imagePreview       = _zoomImageView;
@synthesize colorInputButton   = _colorInputButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

// [self addChildViewController:self.colorSelectionVC];
// [_colorSelectionVC didMoveToParentViewController:self];
// _colorSelectionVC.view.frame = _colorSelectionContainer.bounds;
// [self.colorSelectionContainer addSubview:_colorSelectionVC.view];

    [self resetUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.colorSelectionContainer = nil;
    self.tableView               = nil;
    self.imagePreview            = nil;
    self.colorInputButton        = nil;
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (void)resetToInitialState {
    hasChanges          = NO;
    _fetchedBackgrounds = nil;
    [self resetUI];
}

- (void)resetUI {
    selectedIndex = -2;

    if (_sourceObject) {
        [self selectRowForGalleryBackgroundImage:(GalleryBackgroundImage *)_sourceObject.backgroundImage];
// self.colorSelectionVC.initialColor = self.sourceObject.backgroundColor;
// [self initializeColorSelectionControllerWithColor:_sourceObject.backgroundColor];
        self.colorInputButton.backgroundColor = _sourceObject.backgroundColor;
    }
}

- (UIImage *)noBackgroundImage {
    static const CGRect   frame = (CGRect) {
        .origin.x    = 16,
        .origin.y    = 8,
        .size.width  = 86,
        .size.height = 130
    };
    static UIImage * noBackgroundImage;

    if (noBackgroundImage) return noBackgroundImage;

    UIBezierPath * path = [UIBezierPath bezierPath];

    [path moveToPoint:CGPointMake(0, frame.size.height)];
    [path addLineToPoint:CGPointMake(frame.size.width, 0)];
    path.lineWidth    = 8.0;
    path.lineCapStyle = kCGLineCapSquare;

    UIGraphicsBeginImageContextWithOptions(frame.size, YES, MainScreenScale);
    [[UIColor whiteColor] setFill];
// [[UIColor scrollViewTexturedBackgroundColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect) {.size = frame.size}
                      );
    [[[UIColor redColor] colorWithAlphaComponent:0.9] setStroke];
    [path stroke];

    noBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return noBackgroundImage;
// return [Painter blurImage:noBackgroundImage];
}

- (IBAction)cancelAction:(id)sender {
    if (hasChanges) [self resetToInitialState];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetAction:(id)sender {
    [self resetToInitialState];
}

- (IBAction)saveAction:(id)sender {
    if (selectedIndex == -1) _sourceObject.backgroundImage = nil;
    else _sourceObject.backgroundImage = self.fetchedBackgrounds[selectedIndex];

    _sourceObject.backgroundColor = self.colorInputButton.backgroundColor;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeColorSelectionControllerWithColor:(UIColor *)color {
    self.colorSelectionVC.initialColor = color;
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    NSIndexPath * indexPath   = [_tableView indexPathForCell:(UITableViewCell *)sender.view];
    UIView      * touchedView = [sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
    NSInteger     index       = touchedView.tag; // (touchedView.tag > 0 ? indexPath.row * 3 +
                                                 // touchedView.tag - 1 : 0);

    if (sender.numberOfTapsRequired == 2 && index >= 0) {
        GalleryBackgroundImage * bgImage =
            (GalleryBackgroundImage *)self.fetchedBackgrounds[index];

        self.imagePreview.image  = bgImage.image;
        self.imagePreview.hidden = NO;
    } else
        [self selectImageAtIndex:index];

    DDLogDebug(@"%@\nsender.view:%@\nindexPath:%@\ntouchedView:%@\n",
               ClassTagSelectorString, sender.view, indexPath, touchedView);
}

- (void)selectImageAtIndex:(NSUInteger)index {
    if (selectedIndex != -2) {
        NSUInteger        rowIndex  = (selectedIndex + 1) / 3;
        NSIndexPath     * indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        UITableViewCell * cell      = [self.tableView cellForRowAtIndexPath:indexPath];

        if (cell) {
            NSArray * imageViews = @[[cell viewWithNametag:@"column1"],
                                     [cell viewWithNametag:@"column2"],
                                     [cell viewWithNametag:@"column3"]];

            for (UIView * view in imageViews) {
                [self setBorderForView:view selected:NO];
            }
        }
    }

    selectedIndex = index;

    NSUInteger        rowIndex  = (selectedIndex + 1) / 3;
    NSIndexPath     * indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    UITableViewCell * cell      = [self.tableView cellForRowAtIndexPath:indexPath];

    if (cell) {
        NSArray * imageViews = @[[cell viewWithNametag:@"column1"],
                                 [cell viewWithNametag:@"column2"],
                                 [cell viewWithNametag:@"column3"]];

        for (UIView * view in imageViews) {
            [self setBorderForView:view selected:(view.tag == selectedIndex)];
        }
    }
}

- (IBAction)dismissPreview:(UITapGestureRecognizer *)sender {
    self.imagePreview.hidden = YES;
}

- (IBAction)backgroundColorInputAction:(id)sender
{}

- (void)setSourceObject:(NSManagedObject <EditableBackground> *)sourceObject {
    _sourceObject = sourceObject;
    [self resetToInitialState];
}

- (void)selectRowForGalleryBackgroundImage:(GalleryBackgroundImage *)bgImage {
    if (!bgImage) {
        selectedIndex = -1;

        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.tableView
         selectRowAtIndexPath:indexPath
                     animated:NO
               scrollPosition:UITableViewScrollPositionMiddle];
    } else {
        NSUInteger   index =
            [self.fetchedBackgrounds
             indexOfObjectPassingTest:
             ^BOOL (id obj, NSUInteger idx, BOOL * stop) {
            if (bgImage.tag == ((GalleryBackgroundImage *)obj).tag) {
                *stop = YES;

                return YES;
            } else
                return NO;
        }

            ];

        if (index != NSNotFound) {
            selectedIndex = index;

            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(index + 1) / 3 inSection:0];

            [self.tableView
             selectRowAtIndexPath:indexPath
                         animated:NO
                   scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)setBorderForView:(UIView *)view selected:(BOOL)selected {
    static UIColor * selectedColor;

    if (!selectedColor) selectedColor = [UIColor colorWithRed:0 green:175.0 / 255.0 blue:1.0 alpha:1.0];

    view.layer.borderColor = (selected ? selectedColor : ClearColor).CGColor;
    view.layer.borderWidth = (selected ? 1.0 : 0.0);
}

- (NSArray *)fetchedBackgrounds {
    if (_fetchedBackgrounds) return _fetchedBackgrounds;

    if (!_sourceObject)
        self.fetchedBackgrounds = [NSArray array];
    else {
        [_sourceObject.managedObjectContext
         performBlockAndWait:^{
             NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GalleryBackgroundImage"];
             NSError * error = nil;
             NSArray * fetchedObjects =
                [_sourceObject.managedObjectContext
                 executeFetchRequest:fetchRequest
                               error:&error];

             if (error) {
                DDLogError(@"%@\n\terror retrieving background images: %@",
                           ClassTagSelectorString, [error localizedFailureReason]);
                self.fetchedBackgrounds = [NSArray array];
             } else if (!fetchedObjects || [fetchedObjects count] == 0) {
                DDLogError(@"%@\n\tbackground image fetch returned empty array", ClassTagSelectorString);
                self.fetchedBackgrounds = [NSArray array];
             } else
                self.fetchedBackgrounds = fetchedObjects;
        }

        ];
    }

    return _fetchedBackgrounds;
}

- (ColorSelectionViewController *)colorSelectionVC {
    if (_colorSelectionVC) return _colorSelectionVC;

    self.colorSelectionVC          = [StoryboardProxy colorSelectionViewController];
    _colorSelectionVC.hidesToolbar = YES;

    return _colorSelectionVC;
}

#pragma mark - ColorSelectionDelegate

- (void)colorSelector:(ColorSelectionViewController *)controller didSelectColor:(UIColor *)color
{}

- (void)colorSelectorDidCancel:(ColorSelectionViewController *)controller
{}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedBackgrounds count] / 3 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSKIT_STATIC_STRING_CONST   kCellIdentifier = @"Cell";
    UITableViewCell         * cell            = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    NSInteger                 index           = indexPath.row * 3 - 1;
    GalleryBackgroundImage  * bgImage;
    UIImageView             * imageView;

    imageView     = (UIImageView *)[cell viewWithNametag:@"column1"];
    imageView.tag = index;
    [self setBorderForView:imageView selected:(index == selectedIndex)];

    if (index >= 0) {
        bgImage         = (GalleryBackgroundImage *)_fetchedBackgrounds[index];
        imageView.image = bgImage.image;
    } else
        imageView.image = [self noBackgroundImage];

    if (++index < [self.fetchedBackgrounds count]) {
        bgImage         = (GalleryBackgroundImage *)_fetchedBackgrounds[index];
        imageView       = (UIImageView *)[cell viewWithNametag:@"column2"];
        imageView.image = bgImage.image;
        imageView.tag   = index;
        [self setBorderForView:imageView selected:(index == selectedIndex)];

        if (++index < [self.fetchedBackgrounds count]) {
            bgImage         = (GalleryBackgroundImage *)_fetchedBackgrounds[index];
            imageView       = (UIImageView *)[cell viewWithNametag:@"column3"];
            imageView.image = bgImage.image;
            imageView.tag   = index;
            [self setBorderForView:imageView selected:(index == selectedIndex)];
        }
    }

    UITapGestureRecognizer * tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

    [cell addGestureRecognizer:tapRecognizer];

    UITapGestureRecognizer * doubleTapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

    doubleTapRecognizer.numberOfTapsRequired = 2;
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [cell addGestureRecognizer:doubleTapRecognizer];

    return cell;
}  /* tableView */

@end
