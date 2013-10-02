//
//  BankTableViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Bank.h"

@interface BankTableViewController:UITableViewController <NSFetchedResultsControllerDelegate,
                                                          BankableViewController>

@property (nonatomic, strong) Class<Bankable>   itemClass;

@end
