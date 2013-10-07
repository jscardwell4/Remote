//
//  BankCollectionViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewController.h"
#import "BankCollectionViewFlowLayout.h"
#import "BankCollectionViewCell.h"
#import "BankCollectionHeaderReusableView.h"
#import "BankPreviewViewController.h"
#import "BankCollectionZoomView.h"
#import "MSRemoteAppController.h"
#import "CoreDataManager.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController class extension
////////////////////////////////////////////////////////////////////////////////

@interface BankCollectionViewController () <MSTouchReporterViewDelegate>

@property (nonatomic, strong) NSBlockOperation           * updatesBlockOperation;
@property (nonatomic, strong) NSMutableSet               * hiddenSections;
@property (nonatomic, strong) BankPreviewViewController  * previewController;
@property (nonatomic, strong) BankCollectionZoomView     * zoomView;

@property (nonatomic, readonly, getter = shouldUseListView) BOOL useListView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem      * displayOptionsBarButtonItem;
@property (nonatomic, weak)   IBOutlet UISegmentedControl   * displayOptionSegmentedControl;
@property (nonatomic, strong) IBOutlet MSTouchReporterView  * touchReporterView;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankCollectionViewController
{
    BankFlags    _bankFlags;
    id<Bankable> _zoomedItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.touchReporterView.translatesAutoresizingMaskIntoConstraints = NO;
    if (   _itemClass
        && !(_bankFlags & BankThumbnail)
        && [self.toolbarItems containsObject:_displayOptionsBarButtonItem])
    {
        self.toolbarItems = [self.toolbarItems
                             filteredArrayUsingPredicateWithFormat:@"self != %@",
                                                                   _displayOptionsBarButtonItem];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (![self isViewLoaded])
    {
        self.touchReporterView = nil;
        self.displayOptionsBarButtonItem = nil;
        self.previewController = nil;
        self.zoomView = nil;
        self.hiddenSections = nil;
        self.updatesBlockOperation = nil;
        self.bankableItems = nil;
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    if (_zoomView && _zoomView.superview)
    {
        NSArray * constraints = [NSLayoutConstraint
                                 constraintsByParsingString:@"zoom.centerX = view.centerX\n"
                                                             "zoom.centerY = view.centerY\n"
                                                             "reporter.width = view.width\n"
                                                             "reporter.height = view.height\n"
                                                             "reporter.centerX = view.centerX\n"
                                                             "reporter.centerY = view.centerY"
                                 views:@{ @"zoom"     : _zoomView,
                                          @"reporter" : _touchReporterView,
                                          @"view"     : self.view }];
        [self.view addConstraints:constraints];
    }
}

- (NSFetchedResultsController *)bankableItems
{
    if (!_bankableItems && self.itemClass)
    {
        assert(_itemClass && [(Class)_itemClass isSubclassOfClass:[NSManagedObject class]]);
        NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
        NSFetchRequest * request = [(Class)_itemClass MR_requestAllSortedBy:@"info.category"
                                                                  ascending:YES inContext:context];
        NSFetchedResultsController * controller = [[NSFetchedResultsController alloc]
                                                   initWithFetchRequest:request
                                                   managedObjectContext:context
                                                     sectionNameKeyPath:@"info.category"
                                                              cacheName:nil];
        NSError * error = nil;
        [controller performFetch:&error];
        if (error) [CoreDataManager handleErrors:error];
        else
        {
            self.bankableItems = controller;
            _bankableItems.delegate = self;
            self.hiddenSections = [NSMutableSet set];
        }

    }

    return _bankableItems;
}

- (BOOL)shouldUseListView { return (_displayOptionSegmentedControl.selectedSegmentIndex == 0); }

- (BankPreviewViewController *)previewController
{
    if (!_previewController)
        self.previewController = UIStoryboardInstantiateSceneByClassName(BankPreviewViewController);

    return _previewController;
}

- (void)setItemClass:(Class<Bankable>)itemClass
{
    assert([(Class)itemClass conformsToProtocol:@protocol(Bankable)]);

    _itemClass = itemClass;
    _bankFlags = [itemClass bankFlags];
}

- (NSMutableSet *)hiddenSections
{
    if (!_hiddenSections) self.hiddenSections = [NSMutableSet set];
    return _hiddenSections;
}

- (BankCollectionZoomView *)zoomView
{
    if (!_zoomView) [MainBundle loadNibNamed:@"BankCollectionZoomView" owner:self options:nil];
    assert(_zoomView);
    return _zoomView;
}

- (id<Bankable>)itemForCell:(BankCollectionViewCell *)cell
{
    return self.bankableItems[[self.collectionView indexPathForCell:cell]];
}

- (void)configureCell:(BankCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id<Bankable>   item = self.bankableItems[indexPath];
    cell.bankFlags      = _bankFlags;
    cell.thumbnailImage = item.thumbnail;
    cell.name           = item.name;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (void)zoomItemForCell:(BankCollectionViewCell *)cell
{
    _zoomedItem              = [self itemForCell:cell];
    self.zoomView.image      = _zoomedItem.preview;
    _zoomView.name           = _zoomedItem.name;
    _zoomView.editDisabled   = !([_zoomedItem isEditable]);
    _zoomView.detailDisabled = !(_bankFlags & BankDetail);

    _zoomView.backgroundImageView.image = [[self.view snapshot]
                                           applyBlurWithRadius:3.0
                                                     tintColor:UIColorMake(1, 1, 1, 0.5)
                                         saturationDeltaFactor:1.8
                                                     maskImage:nil];
    [self.view addSubview:_touchReporterView];
    [self.view addSubview:_zoomView];
    [self.view setNeedsUpdateConstraints];
}

- (void)previewItemForCell:(BankCollectionViewCell *)cell
{
    id<Bankable> item = [self itemForCell:cell];
    self.previewController.image = item.preview;
    [self presentViewController:_previewController animated:YES completion:nil];
}

- (void)editItemForCell:(BankCollectionViewCell *)cell
{
    id<Bankable> item = [self itemForCell:cell];
    [self.navigationController pushViewController:[Bank editingControllerForItem:item]
                                         animated:YES];
}

- (void)detailItemForCell:(BankCollectionViewCell *)cell
{
    id<Bankable> item = [self itemForCell:cell];
    [self.navigationController pushViewController:[Bank detailControllerForItem:item]
                                         animated:YES];
}

- (void)toggleItemsForSection:(NSInteger)section
{
    [self.hiddenSections addOrRemoveObject:@(section)];
    [self.collectionView reloadSections:NSIndexSetMake(section)];
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (IBAction)importBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)exportBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)searchBankObjects:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)dismiss:(id)sender
{
    [AppController dismissViewController:[Bank viewController] completion:nil];
}

- (IBAction)dismissZoom:(id)sender
{
    [self.zoomView removeFromSuperview];
    [self.touchReporterView removeFromSuperview];

    UIViewController * viewController = nil;

    if (sender == _zoomView.editButton)
        viewController = [Bank editingControllerForItem:_zoomedItem];

    else if (sender == _zoomView.detailButton)
        viewController = [Bank detailControllerForItem:_zoomedItem];

    _zoomedItem = nil;

    if (viewController)
        [self.navigationController pushViewController:viewController animated:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view data source
////////////////////////////////////////////////////////////////////////////////


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return ([_bankableItems.sections count] && ![self.hiddenSections containsObject:@(section)]
            ? [self.bankableItems.sections[section] numberOfObjects]
            : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = (self.useListView ? ListCellIdentifier : ThumbnailCellIdentifier);
    BankCollectionViewCell * cell = [collectionView
                                     dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                               forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.bankableItems.sections count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    MSSTATIC_IDENTIFIER(Header);

    if ([UICollectionElementKindSectionHeader isEqualToString:kind])
    {
        BankCollectionHeaderReusableView * view =
            [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:HeaderIdentifier
                                                           forIndexPath:indexPath];
        view.section = indexPath.section;
        view.title = [self.bankableItems.sections[indexPath.section] name];

        return view;
    }

    else return nil;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate
////////////////////////////////////////////////////////////////////////////////


- (void)   collectionView:(UICollectionView *)collectionView
 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController
     pushViewController:[Bank detailControllerForItem:_bankableItems[indexPath]]
               animated:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate - flow layout
////////////////////////////////////////////////////////////////////////////////


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static const CGSize kListViewCellSize = (CGSize){.width = 320, .height = 38};
    static const CGSize kThumbnailViewCellSize = (CGSize){.width = 100, .height = 100};
    return (self.useListView ? kListViewCellSize : kThumbnailViewCellSize);
}

- (CGSize)        collectionView:(UICollectionView *)collectionView
                          layout:(UICollectionViewLayout*)collectionViewLayout
 referenceSizeForHeaderInSection:(NSInteger)section
{
    static const CGSize kHeaderSize = (CGSize){.width = 320, .height = 38};

    return (_bankFlags & BankNoSections ? CGSizeZero : kHeaderSize);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
////////////////////////////////////////////////////////////////////////////////


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.updatesBlockOperation = [NSBlockOperation new];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    __weak BankCollectionViewController * weakSelf = self;

    [self.updatesBlockOperation addExecutionBlock:
     ^{
         switch(type)
         {
             case NSFetchedResultsChangeInsert:
                 [weakSelf.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                 break;
                 
             case NSFetchedResultsChangeDelete:
                 [weakSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                 break;
         }
     }];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak BankCollectionViewController * weakSelf = self;
    [self.updatesBlockOperation addExecutionBlock:
     ^{
         switch(type)
         {
             case NSFetchedResultsChangeInsert:
                 [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                 break;

             case NSFetchedResultsChangeDelete:
                 [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                 break;

             case NSFetchedResultsChangeUpdate:
             {
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



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^{ [MainQueue addOperation:_updatesBlockOperation]; }
                                  completion:^(BOOL finished)
                                             {
                                                 _updatesBlockOperation = nil;
                                                 [_bankableItems.managedObjectContext processPendingChanges];
                                             }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Touch reporter delegate
////////////////////////////////////////////////////////////////////////////////


- (void)touchReporter:(MSTouchReporterView *)reporter
		 touchesBegan:(NSSet *)touches
			withEvent:(UIEvent *)event
{
    [self dismissZoom:nil];
}


@end
