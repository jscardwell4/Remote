//
//  BankCollectionViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "Bank.h"

@class BankCollectionViewCell;

@interface BankCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Class<BankableModel> itemClass;
@property (nonatomic, strong) NSFetchedResultsController * bankableItems;
@property (nonatomic, assign) BankFlags bankFlags;

- (void)zoomItemForCell:(BankCollectionViewCell *)cell;
- (void)previewItemForCell:(BankCollectionViewCell *)cell;
- (void)editItemForCell:(BankCollectionViewCell *)cell;
- (void)detailItemForCell:(BankCollectionViewCell *)cell;
- (void)deleteItemForCell:(BankCollectionViewCell *)cell;
- (void)toggleItemsForSection:(NSInteger)section;

@end
