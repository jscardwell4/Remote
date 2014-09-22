//
//  BankCollectionViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewController.h"
//#import "BankCollectionLayout.h"
//#import "BankCollectionHeaderReusableView.h"
#import "BankPreviewViewController.h"
#import "BankCollectionZoomView.h"
#import "MSRemoteAppController.h"
#import "CoreDataManager.h"
#import "BankableModelObject.h"
#import "BankItemViewController.h"
#import "Remote-Swift.h"

MSSTATIC_STRING_CONST kExportBarItemImage         = @"702-gray-share";
MSSTATIC_STRING_CONST kExportBarItemImageSelected = @"702-gray-share-selected";
MSSTATIC_STRING_CONST kImportBarItemImage         = @"703-gray-download";
MSSTATIC_STRING_CONST kImportBarItemImageSelected = @"703-gray-download-selected";
MSSTATIC_STRING_CONST kListSegmentImage           = @"399-gray-list1";
MSSTATIC_STRING_CONST kThumbnailSegmentImage      = @"822-gray-photo-2";
MSSTATIC_STRING_CONST kSearchBarItemImage         = @"708-gray-search";
MSSTATIC_STRING_CONST kIndicatorImage             = @"1040-gray-checkmark";
MSSTATIC_STRING_CONST kIndicatorImageSelected     = @"1040-gray-checkmark-selected";
MSSTATIC_STRING_CONST kTextFieldTextColor         = @"#9FA0A4FF";


static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

static const CGSize ListItemCellSize      = (CGSize) { .width = 320, .height = 38  };
static const CGSize ThumbnailItemCellSize = (CGSize) { .width = 100, .height = 100 };
static const CGSize HeaderSize            = (CGSize) { .width = 320, .height = 38  };


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController class extension
////////////////////////////////////////////////////////////////////////////////

@interface BankCollectionViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSBlockOperation             * updatesBlockOperation;
@property (nonatomic, strong) NSMutableSet                 * hiddenSections;
@property (nonatomic, strong) BankPreviewViewController    * previewController;
@property (nonatomic, strong) BankCollectionZoomView       * zoomView;
@property (nonatomic, strong) BankCollectionLayout         * layout;

@property (nonatomic, strong) UIAlertAction                * exportAlertAction;
@property (nonatomic, strong) NSMutableSet                 * existingFiles;
@property (nonatomic, strong) NSMutableSet                 * exportSelection;
@property (nonatomic, assign) BOOL                           exportSelectionMode;

@property (nonatomic, assign, getter = shouldUseListView) BOOL useListView;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankCollectionViewController
{
  BankableModelObject * _zoomedItem;
  NSIndexPath         * _swipeToDeleteCellIndexPath;
}

/// controllerWithItemClass:
/// @param itemClass
/// @return instancetype
+ (instancetype)controllerWithItemClass:(Class<BankableModel>)itemClass {

  if (!itemClass) ThrowInvalidNilArgument(itemClass);

  BankCollectionViewController * controller = [BankCollectionViewController new];
  controller.itemClass = itemClass;

  return controller;

}

/// loadView
- (void)loadView {

  assert(self.itemClass);

  self.useListView = YES;

  self.layout = ({
    BankCollectionLayout * flowLayout = [BankCollectionLayout new];
    flowLayout.itemSize = CGSizeMake(100.0, 100.0);
    flowLayout;
  });

  self.collectionView = ({
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:MainScreen.bounds
                                                           collectionViewLayout:self.layout];
    collectionView.backgroundColor = WhiteColor;
    [collectionView registerClass:[BankCollectionViewHeader class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:[BankCollectionViewHeader identifier]];

    [collectionView registerClass:[BankCollectionViewCell class]
       forCellWithReuseIdentifier:[BankCollectionViewCell listIdentifier]];

    [collectionView registerClass:[BankCollectionViewCell class]
       forCellWithReuseIdentifier:[BankCollectionViewCell thumbnailIdentifier]];

    collectionView;
  });

  self.toolbarItems = ({
    UIBarButtonItem * exportBarItem = ImageBarButton(kExportBarItemImage, @selector(exportBankObject:));
    UIBarButtonItem * spacer = FixedSpaceBarButton(20.0);
    UIBarButtonItem * importBarItem = ImageBarButton(kImportBarItemImage, @selector(importBankObject:));
    UIBarButtonItem * flex = FlexibleSpaceBarButton;
    UISegmentedControl * displayOptionsControl = [[UISegmentedControl alloc]
                                                  initWithItems:@[UIImageMake(kListSegmentImage),
                                                                  UIImageMake(kThumbnailSegmentImage)]];
    [displayOptionsControl addTarget:self
                              action:@selector(segmentedControlValueDidChange:)
                    forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem * displayOptionsItem = CustomBarButton(displayOptionsControl);
    UIBarButtonItem * searchBarItem = ImageBarButton(kSearchBarItemImage, @selector(searchBankObjects:));
    NSArray * toolbarItems = ([_itemClass isThumbnailable]
                              ? @[exportBarItem, spacer, importBarItem, flex, displayOptionsItem, flex, searchBarItem]
                              : @[exportBarItem, spacer, importBarItem, flex, searchBarItem]);
    toolbarItems;
  });

  [self refreshExistingFiles];

}

/// viewWillAppear:
/// @param animated
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationItem.rightBarButtonItem = SystemBarButton(Done, @selector(dismiss:));
  [self.collectionView reloadData];
}

/// didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  if (![self isViewLoaded]) {
    self.previewController           = nil;
    self.zoomView                    = nil;
    self.hiddenSections              = nil;
    self.updatesBlockOperation       = nil;
    self.allItems               = nil;
  }
}

/// updateViewConstraints
- (void)updateViewConstraints {
  [super updateViewConstraints];

  if (_zoomView && _zoomView.superview) {
    NSArray * constraints = [NSLayoutConstraint
                             constraintsByParsingString:@"zoom.centerX = view.centerX\n"
                                                         "zoom.centerY = view.centerY"
                                                  views:@{ @"zoom"     : _zoomView,
                                                           @"view"     : self.view }];
    [self.view addConstraints:constraints];
  }
}

/// allItems
/// @return NSFetchedResultsController *
- (NSFetchedResultsController *)allItems {
  if (!_allItems && self.itemClass) {
    self.allItems      = [self.itemClass allItems];
    _allItems.delegate = self;
    self.hiddenSections     = [NSMutableSet set];
  }

  return _allItems;
}

/// previewController
/// @return BankPreviewViewController *
- (BankPreviewViewController *)previewController {
  if (!_previewController)
    self.previewController = UIStoryboardInstantiateSceneByClassName(BankPreviewViewController);

  return _previewController;
}

/// hiddenSections
/// @return NSMutableSet *
- (NSMutableSet *)hiddenSections {
  if (!_hiddenSections) self.hiddenSections = [NSMutableSet set];

  return _hiddenSections;
}

/// zoomView
/// @return BankCollectionZoomView *
- (BankCollectionZoomView *)zoomView {
  if (!_zoomView) [MainBundle loadNibNamed:@"BankCollectionZoomView" owner:self options:nil];

  assert(_zoomView);
  return _zoomView;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Exporting items
////////////////////////////////////////////////////////////////////////////////


/// refreshExistingFiles
- (void)refreshExistingFiles {

  __weak BankCollectionViewController * weakself = self;
  dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, -1);
  dispatch_queue_t backgroundQueue = dispatch_queue_create("com.moondeerstudios.background", attr);
  dispatch_async(backgroundQueue, ^{
    NSMutableArray * directoryContents = [[MoonFunctions documentsDirectoryContents] mutableCopy];
    [directoryContents filter:^BOOL(NSString * name) { return [name hasSuffix:@".json"]; }];
    [directoryContents map:^NSString *(NSString * name, NSUInteger idx) { return [name stringByDeletingPathExtension]; }];
    if ([directoryContents count])
      [MainQueue addOperationWithBlock:^{
        weakself.existingFiles = [[directoryContents set] mutableCopy];
        MSLogDebug(@"existing files in documents directory…\n\t%@", [directoryContents componentsJoinedByString:@"\n\t"]);
      }];
  });

}

/// setExportSelectionMode:
/// @param exportSelectionMode
- (void)setExportSelectionMode:(BOOL)exportSelectionMode {

  _exportSelectionMode = exportSelectionMode;

  self.exportSelection = _exportSelectionMode ? [NSMutableSet set] : nil;

  if (!self.exportSelection) {
    for (NSIndexPath * indexPath in [self.collectionView indexPathsForSelectedItems])
      [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
  }

  self.navigationItem.rightBarButtonItem = (_exportSelectionMode
                                            ? TitleBarButton(@"Export", @selector(confirmExport:))
                                            : SystemBarButton(Done, @selector(dismiss:)));

  NSMutableArray * toolbarItems = [self.toolbarItems mutableCopy];
  UIBarButtonItem * exportItem = ImageBarButton(_exportSelectionMode ? kExportBarItemImageSelected : kExportBarItemImage,
                                                @selector(exportBankObject:));
  [toolbarItems replaceObjectAtIndex:0 withObject:exportItem];
  [self setToolbarItems:toolbarItems animated:YES];
  self.collectionView.allowsMultipleSelection = _exportSelectionMode;

  [self.collectionView setValue:_exportSelectionMode ? kIndicatorImage : nil forKeyPath:@"visibleCells.indicatorImage"];
  assert(!([[self.collectionView indexPathsForSelectedItems] count] && _exportSelectionMode));

}

/// confirmExport:
/// @param sender
- (void)confirmExport:(id)sender {

  UIAlertController * alert = nil;
  __weak BankCollectionViewController * weakself = self;

  if ([self.exportSelection count]) {

    alert = [UIAlertController alertControllerWithTitle:@"Export Selection"
                                                message:@"Enter a name for the exported file"
                                         preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
      textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
      textField.textColor = [UIColor colorWithRGBAHexString:kTextFieldTextColor];
      textField.delegate = weakself;
    }];

    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
      weakself.exportSelectionMode = NO;
      weakself.exportAlertAction = nil;
      [weakself dismissViewControllerAnimated:YES completion:nil];
    }]];

    self.exportAlertAction =
    [UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
      NSString    * text      = [alert.textFields.firstObject text];
      assert([text length] && ![weakself.existingFiles containsObject:text]);
      NSString * pathToFile = [MoonFunctions documentsPathToFile:[text stringByAppendingPathExtension:@"json"]];
      [weakself exportSelectionToFile:pathToFile];

      weakself.exportSelectionMode = NO;
      [weakself dismissViewControllerAnimated:YES completion:nil];
    }];

    [alert addAction:self.exportAlertAction];

  } else {

    alert = [UIAlertController
             alertControllerWithTitle:@"Export Selection"
                              message:@"No items have been selected, what do you suppose I would be exporting?"
                       preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Alright" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      [weakself dismissViewControllerAnimated:YES completion:nil];
    }]];

  }

  [self presentViewController:alert animated:YES completion:nil];

}

/// exportSelectionToFile:
/// @param filePath
- (void)exportSelectionToFile:(NSString *)filePath {

  MSLogInfo(@"exporting selected items to file '%@'…", filePath);
  [self.exportSelection.JSONString writeToFile:filePath];

}

/// exportBankObject:
/// @param sender
- (void)exportBankObject:(id)sender { self.exportSelectionMode = !self.exportSelectionMode; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

/// zoomItem:
/// @param item
- (void)zoomItem:(BankableModelObject *)item {

  _zoomedItem = item;
  self.zoomView.image      = _zoomedItem.preview;
  _zoomView.name           = _zoomedItem.name;
  _zoomView.editDisabled   = !([_zoomedItem isEditable]);
  _zoomView.detailDisabled = !([_itemClass isDetailable]);

  _zoomView.backgroundImageView.image = [[self.view snapshot]
                                          applyBlurWithRadius:3.0
                                                    tintColor:UIColorMake(1, 1, 1, 0.5)
                                        saturationDeltaFactor:1.8
                                                    maskImage:nil];
  [self.view addSubview:_zoomView];
  [self.view setNeedsUpdateConstraints];

}

/// previewItem:
/// @param item
- (void)previewItem:(BankableModelObject *)item {
  self.previewController.image = item.preview;
  [self presentViewController:_previewController animated:YES completion:nil];
}

/// deleteItem:
/// @param item
- (void)deleteItem:(BankableModelObject *)item {
  if ([item isEditable]) [item.managedObjectContext deleteObject:item];
}

/// editItem:
/// @param item
- (void)editItem:(BankableModelObject *)item {
  [self.navigationController pushViewController:item.editingViewController animated:YES];
}

/// detailItem:
/// @param item
- (void)detailItem:(BankableModelObject *)item {
  [self.navigationController pushViewController:item.detailViewController animated:YES];
}

/// toggleItemsForSection:
/// @param section
- (void)toggleItemsForSection:(NSInteger)section {
  [self.hiddenSections addOrRemoveObject:@(section)];
  [self.collectionView reloadSections:NSIndexSetMake(section)];
}

/// segmentedControlValueDidChange:
/// @param sender
- (void)segmentedControlValueDidChange:(UISegmentedControl *)sender {
  self.useListView = sender.selectedSegmentIndex == 0;
  [self.collectionView.collectionViewLayout invalidateLayout];
  [self.collectionView reloadData];
}

/// importBankObject:
/// @param sender
- (void)importBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// searchBankObjects:
/// @param sender
- (void)searchBankObjects:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// dismiss:
/// @param sender
- (void)dismiss:(id)sender {
  [AppController dismissViewController:[Bank viewController] completion:nil];
}

/// dismissZoom:
/// @param sender
- (void)dismissZoom:(id)sender {

  [self.zoomView removeFromSuperview];

  UIViewController * viewController = nil;

  if (sender == _zoomView.editButton)
    viewController = _zoomedItem.editingViewController;

  else if (sender == _zoomView.detailButton)
    viewController = _zoomedItem.detailViewController;

  _zoomedItem = nil;

  if (viewController)
    [self.navigationController pushViewController:viewController animated:YES];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view data source
////////////////////////////////////////////////////////////////////////////////


/// collectionView:numberOfItemsInSection:
/// @param collectionView
/// @param section
/// @return NSInteger
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return ([self.hiddenSections containsObject:@(section)]
          ? 0
          : [self.allItems.sections[section] numberOfObjects]);
}

/// collectionView:cellForItemAtIndexPath:
/// @param collectionView
/// @param indexPath
/// @return UICollectionViewCell *
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSString * identifer = (self.useListView
                          ? [BankCollectionViewCell listIdentifier]
                          : [BankCollectionViewCell thumbnailIdentifier]);
  BankCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer
                                                                            forIndexPath:indexPath];
  cell.item       = self.allItems[indexPath];
  __weak BankCollectionViewController * weakself = self;
  cell.detailActionHandler = ^(BankCollectionViewCell * cell) { [weakself detailItem:cell.item];  };
  cell.imageActionHandler  = ^(BankCollectionViewCell * cell) { [weakself previewItem:cell.item]; };
  return cell;
}

/// numberOfSectionsInCollectionView:
/// @param collectionView
/// @return NSInteger
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return [self.allItems.sections count];
}

/// collectionView:viewForSupplementaryElementOfKind:atIndexPath:
/// @param collectionView
/// @param kind
/// @param indexPath
/// @return UICollectionReusableView *
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView * view = nil;
  if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
    BankCollectionViewHeader * header =
      [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:[BankCollectionViewHeader identifier]
                                                     forIndexPath:indexPath];
//    header.controller = self;
    header.section    = indexPath.section;
    header.title      = [self.allItems.sections[indexPath.section] name];

    view = header;
  }
  return view;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate
////////////////////////////////////////////////////////////////////////////////


/// collectionView:willDisplayCell:forItemAtIndexPath:
/// @param collectionView
/// @param cell
/// @param indexPath
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(BankCollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
//  cell.indicatorImage = (self.exportSelectionMode ? kIndicatorImage : nil);
}

/// collectionView:didDeselectItemAtIndexPath:
/// @param collectionView
/// @param indexPath
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

  BankCollectionViewCell * cell = (BankCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

  // Check if we are selecting items to export
  if (self.exportSelectionMode) {
    [self.exportSelection removeObject:cell.item];  // Remove from our collection of items to export
//    cell.indicatorImage = kIndicatorImage;          // Change the indicator to normal
  }

}

/// collectionView:didSelectItemAtIndexPath:
/// @param collectionView
/// @param indexPath
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

  BankCollectionViewCell * cell = (BankCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

  // Check if we are selecting items to export
  if (self.exportSelectionMode) {
    [self.exportSelection addObject:cell.item];     // Add to our collection of items to export
//    cell.indicatorImage = kIndicatorImageSelected;  // Change indicator to selected
  }

  // Otherwise we push the item's detail view controller
  else [self.navigationController pushViewController:[cell.item detailViewController] animated:YES];

}

/// collectionView:canPerformAction:forItemAtIndexPath:withSender:
/// @param collectionView
/// @param action
/// @param indexPath
/// @param sender
/// @return BOOL
- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
  return (action == @selector(deleteItemForCell:) && [self.allItems[indexPath] isEditable]);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate - flow layout
////////////////////////////////////////////////////////////////////////////////


/// collectionView:layout:sizeForItemAtIndexPath:
/// @param collectionView
/// @param collectionViewLayout
/// @param indexPath
/// @return CGSize
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

  CGSize size = CGSizeZero;

  if (self.useListView) size = ListItemCellSize;

  else {

    CGSize maxSize = ThumbnailItemCellSize;
    BankableModelObject * item = self.allItems[indexPath];
    assert(item);

    CGSize imageSize = CGSizeZero;
    UIImage * itemImage = item.preview;
    if (itemImage) imageSize = itemImage.size;

    CGSize fittedSize = CGSizeAspectMappedToSize(imageSize, maxSize, YES);
    if (fittedSize.width < maxSize.width) fittedSize.width = ceil(fittedSize.width);
    if (fittedSize.height < maxSize.height) fittedSize.height = ceil(fittedSize.height);

    if (CGSizeContainsSize(maxSize, fittedSize)) size = fittedSize;

    MSLogDebug(@"maxSize: %@, imageSize: %@, fittedSize: %@, finalSize: %@",
               CGSizeString(maxSize), CGSizeString(imageSize), CGSizeString(fittedSize), CGSizeString(size));

  }

  return size;
}

/// collectionView:layout:referenceSizeForHeaderInSection:
/// @param collectionView
/// @param collectionViewLayout
/// @param section
/// @return CGSize
- (CGSize)         collectionView:(UICollectionView *)collectionView
                           layout:(UICollectionViewLayout *)collectionViewLayout
  referenceSizeForHeaderInSection:(NSInteger)section
{
  return ([self.itemClass isSectionable] ? HeaderSize : CGSizeZero);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
////////////////////////////////////////////////////////////////////////////////


/// controllerWillChangeContent:
/// @param controller
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  self.updatesBlockOperation = [NSBlockOperation new];
}

/// controller:didChangeSection:atIndex:forChangeType:
/// @param controller
/// @param sectionInfo
/// @param sectionIndex
/// @param type
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  __weak BankCollectionViewController * weakSelf = self;
  [_updatesBlockOperation addExecutionBlock:^{
    switch (type) {
      case NSFetchedResultsChangeInsert: [weakSelf.collectionView insertSections:NSIndexSetMake(sectionIndex)]; break;
      case NSFetchedResultsChangeDelete: [weakSelf.collectionView deleteSections:NSIndexSetMake(sectionIndex)]; break;
      default:                                                                                                  break;
    }
  }];
}

/// controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:
/// @param controller
/// @param anObject
/// @param indexPath
/// @param type
/// @param newIndexPath
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  __weak BankCollectionViewController * weakSelf = self;
  [_updatesBlockOperation addExecutionBlock:^{
    switch (type) {
      case NSFetchedResultsChangeInsert: [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]]; break;
      case NSFetchedResultsChangeDelete: [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];    break;
      case NSFetchedResultsChangeMove:   [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                         [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]]; break;
      default:                                                                                              break;
    }
  }];
}

/// controllerDidChangeContent:
/// @param controller
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.collectionView performBatchUpdates:^{ [_updatesBlockOperation start]; } completion:nil];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////

/// textFieldShouldEndEditing:
/// @param textField
/// @return BOOL
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if ([self.existingFiles containsObject:textField.text]) {
    textField.textColor = RedColor;
    return NO;
  }
  return YES;
}

/// textField:shouldChangeCharactersInRange:replacementString:
/// @param textField
/// @param range
/// @param string
/// @return BOOL
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

  NSString * text = (range.length == 0
                     ? [textField.text stringByAppendingString:string]
                     : [textField.text stringByReplacingCharactersInRange:range withString:string]);
  BOOL nameInvalid = [self.existingFiles containsObject:text];
  textField.textColor = (nameInvalid
                         ? [UIColor colorWithName:@"fire-brick"]
                         : [UIColor colorWithRGBAHexString:kTextFieldTextColor]);
  self.exportAlertAction.enabled = !nameInvalid;
  return YES;
}

/// textFieldShouldReturn:
/// @param textField
/// @return BOOL
- (BOOL)textFieldShouldReturn:(UITextField *)textField { return NO; }

/// textFieldShouldClear:
/// @param textField
/// @return BOOL
- (BOOL)textFieldShouldClear:(UITextField *)textField {
  return YES;
}

@end
