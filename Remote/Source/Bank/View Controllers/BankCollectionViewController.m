//
//  BankCollectionViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewController.h"
#import "Bank.h"
#import "BankViewController.h"
#import "MSRemoteAppController.h"
#import "BankTableViewController.h"
#import "CoreDataManager.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface BankSectionHeaderView : UICollectionReusableView
@property (nonatomic, assign) IBOutlet UIButton * button;
@end

@implementation BankSectionHeaderView @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController class extension
////////////////////////////////////////////////////////////////////////////////

@class BankCollectionViewCell;

@interface BankCollectionViewController ()

@property (nonatomic, assign, readonly) BankViewController * bankViewController;
@property (nonatomic, strong) NSBlockOperation * updatesBlockOperation;
@property (nonatomic, strong) Class itemClass;
@property (nonatomic, weak) NSFetchedResultsController * bankableItems;

- (void)previewItemForCell:(BankCollectionViewCell *)cell;
- (void)editItemForCell:(BankCollectionViewCell *)cell;
- (void)detailItemForCell:(BankCollectionViewCell *)cell;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewCell
////////////////////////////////////////////////////////////////////////////////


@interface BankCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) IBOutlet UIImageView * thumbnailImageView;
@property (nonatomic, assign) IBOutlet UILabel     * nameLabel;
@property (nonatomic, assign) IBOutlet UIButton    * editButton;
@property (nonatomic, assign) IBOutlet UIButton    * detailButton;
@property (nonatomic, assign) IBOutlet BankCollectionViewController * controller;

@end

@implementation BankCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.thumbnailImageView)
        [self.thumbnailImageView
         addGestureRecognizer:[UILongPressGestureRecognizer gestureWithTarget:self
                                                                       action:@selector(preview:)]];
}

- (IBAction)preview:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        [self.controller previewItemForCell:self];
}

- (IBAction)detail:(id)sender { [self.controller detailItemForCell:self]; }
- (IBAction)edit:(id)sender { [self.controller editItemForCell:self]; }

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankCollectionViewController
{
    BOOL _supressSectionTitle;
    BOOL _supressPreviewButton;
    BOOL _supressEditButton;
    BOOL _supressDetailButton;
    NSMutableSet * _hiddenSections;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hiddenSections = [NSMutableSet set];
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    assert(self.view);
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if ([parent isKindOfClass:[BankViewController class]])
    {
        _bankViewController = (BankViewController *)parent;
        self.itemClass = _bankViewController.itemClass;
        self.bankableItems = _bankViewController.bankableItems;
    }

    else
    {
        _bankViewController = nil;
        _bankableItems = nil;
        _itemClass = nil;
    }
}

/*
- (NSFetchedResultsController *)bankableItems
{
    if (!_bankableItems && self.itemClass)
    {
        assert(_itemClass && [_itemClass isSubclassOfClass:[NSManagedObject class]]);
        NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
        NSFetchRequest * request = [_itemClass MR_requestAllSortedBy:@"info.category" ascending:YES inContext:context];
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
            _supressSectionTitle = ([_bankableItems.sections count] < 2);
            _hiddenSections = [NSMutableSet set];
        }

    }

    return _bankableItems;
}
*/

- (void)setItemClass:(Class)itemClass
{
    if ([itemClass conformsToProtocol:@protocol(Bankable)])
    {
        _itemClass = itemClass;
        BankFlags flags = [itemClass bankFlags];
        _supressPreviewButton  = !(flags & BankPreview);
        _supressEditButton     = !(flags & BankEditable);
        _supressDetailButton   = !(flags & BankDetail);
    }
}

- (void)previewItemForCell:(BankCollectionViewCell *)cell
{
    [self.bankViewController previewItem:[self itemForCell:cell]];
}

- (void)editItemForCell:(BankCollectionViewCell *)cell
{
    [self.bankViewController editItem:[self itemForCell:cell]];
}

- (void)detailItemForCell:(BankCollectionViewCell *)cell
{
    [self.bankViewController detailItem:[self itemForCell:cell]];
}

- (id<Bankable>)itemForCell:(BankCollectionViewCell *)cell
{
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    id<Bankable> item = [self.bankableItems objectAtIndexPath:indexPath];
    assert(item);
    return item;
}

- (void)configureCell:(BankCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id<Bankable> item = [self.bankableItems objectAtIndexPath:indexPath];
    assert(item && [item conformsToProtocol:@protocol(Bankable)]);
    
    if (_supressEditButton && cell.editButton)
    {
        [cell.editButton removeFromSuperview];
        cell.editButton = nil;
    }
    
    else cell.editButton.enabled = item.user;
    
    if (cell.thumbnailImageView)
        cell.thumbnailImageView.userInteractionEnabled = !_supressPreviewButton;

    if (cell.detailButton) cell.detailButton.enabled = !_supressDetailButton;

    cell.thumbnailImageView.image = item.thumbnail;
    
    cell.nameLabel.text = item.name;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)toggleItemsForSection:(UIButton *)button
{
    if (!_bankableItems) return;

    NSInteger section = button.tag;

    if ([_hiddenSections containsObject:@(section)])
        [_hiddenSections removeObject:@(section)];
    else
        [_hiddenSections addObject:@(section)];

    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender
{
    if (!sender.selectedSegmentIndex)
    {
        [self.bankViewController showListView];
        sender.selectedSegmentIndex = 1;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (   [[self.bankableItems sections] count] > 0
        && ![_hiddenSections containsObject:@(section)])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.bankableItems sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    else
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSTATIC_STRING_CONST kCellIdentifier = @"Cell";
    BankCollectionViewCell * cell = [collectionView
                                     dequeueReusableCellWithReuseIdentifier:kCellIdentifier
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
    MSSTATIC_NAMETAG(DisplayOptions);
    MSSTATIC_NAMETAG(SegmentedControl);
    MSSTATIC_NAMETAG(DisplayOptionsHeightConstraint);
    if ([UICollectionElementKindSectionHeader isEqualToString:kind])
    {
        UICollectionReusableView * view = [self.collectionView
                                           dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:HeaderIdentifier
                                                                     forIndexPath:indexPath];

        NSLayoutConstraint * heightConstraint = [[view viewWithNametag:DisplayOptionsNametag]
                                                 constraintWithNametag:DisplayOptionsHeightConstraintNametag];
        heightConstraint.constant = (indexPath.section ? 0 : 44);

        UIButton * button = (UIButton *)[view viewWithNametag:@"button"];
        [button setTitle:[self.bankableItems.sections[indexPath.section] name]
                forState:UIControlStateNormal];
        button.tag = indexPath.section;

        UISegmentedControl * segmentedControl = (UISegmentedControl *)[view viewWithNametag:SegmentedControlNametag];
        segmentedControl.selectedSegmentIndex = 1;

        return view;
    }

    else return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate
////////////////////////////////////////////////////////////////////////////////


/*
- (BOOL)         collectionView:(UICollectionView *)collectionView
 shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

/*
- (void)      collectionView:(UICollectionView *)collectionView
 didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)        collectionView:(UICollectionView *)collectionView
 didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{

}
*/

/*
- (BOOL)      collectionView:(UICollectionView *)collectionView
 shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

/*
- (BOOL)        collectionView:(UICollectionView *)collectionView
 shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/


- (void)   collectionView:(UICollectionView *)collectionView
 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.bankViewController detailItem:[_bankableItems objectAtIndexPath:indexPath]];
}

/*
- (void)     collectionView:(UICollectionView *)collectionView
 didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
*/

/*
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)            collectionView:(UICollectionView *)collectionView
 didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
                  forElementOfKind:(NSString *)elementKind
                       atIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)           collectionView:(UICollectionView *)collectionView
 shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{

}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout
                                           newLayout:(UICollectionViewLayout *)toLayout
{
    return nil;
}
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Navigation
////////////////////////////////////////////////////////////////////////////////

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
/*
    if ([BankViewThumbnailToListSegue isEqualToString:segue.identifier])
    {
        BankTableViewController * tableVC = [segue destinationViewController];
        tableVC.itemClass = self.itemClass;
        tableVC.bankableItems = self.bankableItems;
    }
*/
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

    [self.updatesBlockOperation addExecutionBlock:^{
        switch(type) {
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
    [self.updatesBlockOperation addExecutionBlock:^{
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
                BankCollectionViewCell * cell = (BankCollectionViewCell*)
                                                [weakSelf.collectionView
                                                 cellForItemAtIndexPath:indexPath];
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
                                  completion:^(BOOL finished) {
                                      _supressSectionTitle = ([controller.sections count] < 2);
                                      _updatesBlockOperation = nil;
                                  }];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collection view delegate - flow layout
////////////////////////////////////////////////////////////////////////////////



/*
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}
*/

/*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 10, 0);
}
*/

/*
- (CGFloat)           collectionView:(UICollectionView *)collectionView
                              layout:(UICollectionViewLayout*)collectionViewLayout
 minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
*/

/*
- (CGFloat)                collectionView:(UICollectionView *)collectionView
                                   layout:(UICollectionViewLayout*)collectionViewLayout
 minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
*/


- (CGSize)        collectionView:(UICollectionView *)collectionView
                          layout:(UICollectionViewLayout*)collectionViewLayout
 referenceSizeForHeaderInSection:(NSInteger)section
{
    static const CGSize TopHeaderSize = (CGSize){.width = 320, .height = 82};
    static const CGSize SubsequentHeaderSize = (CGSize){.width = 320, .height = 38};

    CGSize size = (section == 0 ? TopHeaderSize : SubsequentHeaderSize);
    return size;
}

/*
- (CGSize)        collectionView:(UICollectionView *)collectionView
                          layout:(UICollectionViewLayout*)collectionViewLayout
 referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}
*/

@end
