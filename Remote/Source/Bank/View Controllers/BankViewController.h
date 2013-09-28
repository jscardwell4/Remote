//
//  BankViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"

@interface BankViewController : UIViewController

@property (nonatomic, strong) Class itemClass;
@property (nonatomic, strong) NSFetchedResultsController * bankableItems;

- (void)previewItem:(id<Bankable>)item;
- (void)editItem:(id<Bankable>)item;
- (void)detailItem:(id<Bankable>)item;

- (void)showListView;
- (void)showThumbnailView;

@end


