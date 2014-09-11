//
//  BankCollectionViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewController.h"
#import "BankCollectionViewFlowLayout.h"
#import "BankCollectionHeaderReusableView.h"
#import "BankPreviewViewController.h"
#import "BankCollectionZoomView.h"
#import "MSRemoteAppController.h"
#import "CoreDataManager.h"
#import "BankableModelObject.h"
#import "BankableDetailTableViewController.h"
#import "Remote-Swift.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController class extension
////////////////////////////////////////////////////////////////////////////////

@interface BankCollectionViewController ()

@property (nonatomic, strong) NSBlockOperation          * updatesBlockOperation;
@property (nonatomic, strong) NSMutableSet              * hiddenSections;
@property (nonatomic, strong) BankPreviewViewController * previewController;
@property (nonatomic, strong) BankCollectionZoomView    * zoomView;

@property (nonatomic, readonly, getter = shouldUseListView) BOOL useListView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem     * displayOptionsBarButtonItem;
@property (nonatomic, weak)   IBOutlet UISegmentedControl  * displayOptionSegmentedControl;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankCollectionViewController
{
  BankableModelObject * _zoomedItem;
  NSIndexPath         * _swipeToDeleteCellIndexPath;
}

/// viewDidLoad
- (void)viewDidLoad {

  [super viewDidLoad];


  [self.collectionView registerClass:[BankCollectionHeaderReusableView class]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:BankCollectionHeaderIdentifier];

  [self.collectionView registerClass:[BankCollectionViewListCell class]
          forCellWithReuseIdentifier:[BankCollectionViewListCell identifier]];

  [self.collectionView registerClass:[BankCollectionViewThumbnailCell class]
          forCellWithReuseIdentifier:[BankCollectionViewThumbnailCell identifier]];

  if (  _itemClass
     && ![_itemClass isThumbnailable]
     && [self.toolbarItems containsObject:_displayOptionsBarButtonItem])
  {
    self.toolbarItems = [self.toolbarItems filtered:^BOOL(id evaluatedObject) {
      return evaluatedObject != _displayOptionsBarButtonItem;
    }];
  }

}

/// viewWillAppear:
/// @param animated description
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.collectionView reloadData];
}

/// didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  if (![self isViewLoaded]) {
    self.displayOptionsBarButtonItem = nil;
    self.previewController           = nil;
    self.zoomView                    = nil;
    self.hiddenSections              = nil;
    self.updatesBlockOperation       = nil;
    self.bankableItems               = nil;
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

/// bankableItems
/// @return NSFetchedResultsController *
- (NSFetchedResultsController *)bankableItems {
  if (!_bankableItems && self.itemClass) {
    self.bankableItems      = [self.itemClass bankableItems];
    _bankableItems.delegate = self;
    self.hiddenSections     = [NSMutableSet set];
  }

  return _bankableItems;
}

/// shouldUseListView
/// @return BOOL
- (BOOL)shouldUseListView { return (_displayOptionSegmentedControl.selectedSegmentIndex == 0); }

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

/// configureCell:atIndexPath:
/// @param cell description
/// @param indexPath description
- (void)configureCell:(BankCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//  cell.item = self.bankableItems[indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

/// zoomItem:
/// @param item description
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
/// @param item description
- (void)previewItem:(BankableModelObject *)item {
  self.previewController.image = item.preview;
  [self presentViewController:_previewController animated:YES completion:nil];
}

/// deleteItem:
/// @param item description
- (void)deleteItem:(BankableModelObject *)item {
  if ([item isEditable]) [item.managedObjectContext deleteObject:item];
}

/// editItem:
/// @param item description
- (void)editItem:(BankableModelObject *)item {
  [self.navigationController pushViewController:item.editingViewController animated:YES];
}

/// detailItem:
/// @param item description
- (void)detailItem:(BankableModelObject *)item {
  [self.navigationController pushViewController:item.detailViewController animated:YES];
}

/// toggleItemsForSection:
/// @param section description
- (void)toggleItemsForSection:(NSInteger)section {
  [self.hiddenSections addOrRemoveObject:@(section)];
  [self.collectionView reloadSections:NSIndexSetMake(section)];
}

/// segmentedControlValueDidChange:
/// @param sender description
- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender {
  [self.collectionView.collectionViewLayout invalidateLayout];
  [self.collectionView reloadData];
}

/// importBankObject:
/// @param sender description
- (IBAction)importBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// exportBankObject:
/// @param sender description
- (IBAction)exportBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// searchBankObjects:
/// @param sender description
- (IBAction)searchBankObjects:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// dismiss:
/// @param sender description
- (IBAction)dismiss:(id)sender {
  [AppController dismissViewController:[Bank viewController] completion:nil];
}

/// dismissZoom:
/// @param sender description
- (IBAction)dismissZoom:(id)sender {

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
/// @param collectionView description
/// @param section description
/// @return NSInteger
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return ([_bankableItems.sections count] && ![self.hiddenSections containsObject:@(section)]
          ? [self.bankableItems.sections[section] numberOfObjects]
          : 0);
}

/// collectionView:cellForItemAtIndexPath:
/// @param collectionView description
/// @param indexPath description
/// @return UICollectionViewCell *
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSString * identifer = (self.useListView
                          ? [BankCollectionViewListCell identifier]
                          : [BankCollectionViewThumbnailCell identifier]);
  BankCollectionViewListCell * cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
  cell.item = self.bankableItems[indexPath];
  cell.controller = self;
  return cell;
}

/// numberOfSectionsInCollectionView:
/// @param collectionView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return [self.bankableItems.sections count];
}

/// collectionView:viewForSupplementaryElementOfKind:atIndexPath:
/// @param collectionView description
/// @param kind description
/// @param indexPath description
/// @return UICollectionReusableView *
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{

  if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
    BankCollectionHeaderReusableView * view =
      [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:BankCollectionHeaderIdentifier
                                                     forIndexPath:indexPath];
    view.controller = self;
    view.section = indexPath.section;
    view.title   = [self.bankableItems.sections[indexPath.section] name];

    return view;
  } else return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate
////////////////////////////////////////////////////////////////////////////////


/// collectionView:didSelectItemAtIndexPath:
/// @param collectionView description
/// @param indexPath description
- (void)    collectionView:(UICollectionView *)collectionView
  didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  BankableModelObject * item = _bankableItems[indexPath];
  assert([item isKindOfClass:[BankableModelObject class]]);

  BankableDetailTableViewController * detailVC = item.detailViewController;
  assert([detailVC isKindOfClass:[BankableDetailTableViewController class]]);

  [self.navigationController pushViewController:detailVC animated:YES];

}

/// collectionView:canPerformAction:forItemAtIndexPath:withSender:
/// @param collectionView description
/// @param action description
/// @param indexPath description
/// @param sender description
/// @return BOOL
- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
  BOOL answer = NO;

  BankableModelObject * item = self.bankableItems[indexPath];

  if (action == @selector(deleteItemForCell:) && [item isEditable]) answer = YES;

  return answer;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate - flow layout
////////////////////////////////////////////////////////////////////////////////


/// collectionView:layout:sizeForItemAtIndexPath:
/// @param collectionView description
/// @param collectionViewLayout description
/// @param indexPath description
/// @return CGSize
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  static const CGSize kListViewCellSize = (CGSize) {
    .width = 320, .height = 38
  };
  static const CGSize kThumbnailViewCellSize = (CGSize) {
    .width = 100, .height = 100
  };
  return (self.useListView ? kListViewCellSize : kThumbnailViewCellSize);
}

/// collectionView:layout:referenceSizeForHeaderInSection:
/// @param collectionView description
/// @param collectionViewLayout description
/// @param section description
/// @return CGSize
- (CGSize)         collectionView:(UICollectionView *)collectionView
                           layout:(UICollectionViewLayout *)collectionViewLayout
  referenceSizeForHeaderInSection:(NSInteger)section
{
  static const CGSize kHeaderSize = (CGSize) {
    .width = 320, .height = 38
  };

  return ([_itemClass isSectionable] ? kHeaderSize : CGSizeZero);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
////////////////////////////////////////////////////////////////////////////////


/// controllerWillChangeContent:
/// @param controller description
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  self.updatesBlockOperation = [NSBlockOperation new];
}

/// controller:didChangeSection:atIndex:forChangeType:
/// @param controller description
/// @param sectionInfo description
/// @param sectionIndex description
/// @param type description
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
  __weak BankCollectionViewController * weakSelf = self;

  [_updatesBlockOperation addExecutionBlock:
   ^{
    switch (type) {
      case NSFetchedResultsChangeInsert:
        [weakSelf.collectionView insertSections:NSIndexSetMake(sectionIndex)];
        break;

      case NSFetchedResultsChangeDelete:
        [weakSelf.collectionView deleteSections:NSIndexSetMake(sectionIndex)];
        break;

      default: break;
    }
  }];
}

/// controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:
/// @param controller description
/// @param anObject description
/// @param indexPath description
/// @param type description
/// @param newIndexPath description
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  __weak BankCollectionViewController * weakSelf = self;
  [_updatesBlockOperation addExecutionBlock:
   ^{
    switch (type) {
      case NSFetchedResultsChangeInsert:
        [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        break;

      case NSFetchedResultsChangeDelete:
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        break;

      case NSFetchedResultsChangeUpdate: {
        id cell = [weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        [weakSelf configureCell:cell atIndexPath:indexPath];
      }   break;

      case NSFetchedResultsChangeMove:
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        break;
    }
  }];
}

/// controllerDidChangeContent:
/// @param controller description
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.collectionView performBatchUpdates:^{ [_updatesBlockOperation start]; } completion:nil];
}


@end
