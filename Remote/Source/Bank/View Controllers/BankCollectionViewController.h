//
//  BankCollectionViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"

@class BankCollectionViewCell;

@interface BankCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, BankableViewController>

@property (nonatomic, strong) Class<Bankable> itemClass;
@property (nonatomic, strong) NSFetchedResultsController * bankableItems;

- (void)zoomItemForCell:(BankCollectionViewCell *)cell;
- (void)previewItemForCell:(BankCollectionViewCell *)cell;
- (void)editItemForCell:(BankCollectionViewCell *)cell;
- (void)detailItemForCell:(BankCollectionViewCell *)cell;
- (void)toggleItemsForSection:(NSInteger)section;

@end
