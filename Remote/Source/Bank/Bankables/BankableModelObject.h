//
//  BankableModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Bank.h"

@class BankableDetailTableViewController;

@interface BankableModelObject : NamedModelObject <BankableModel>

// Class info
+ (NSString *)directoryLabel;
+ (BankFlags)bankFlags;
+ (UIImage *)directoryIcon;
+ (NSFetchedResultsController *)bankableItems;

- (BankableDetailTableViewController *)detailViewController;
- (BankableDetailTableViewController *)editingViewController;

- (void)updateItem;
- (void)resetItem;

// Object info
@property (nonatomic, copy)                          NSString     * category;
@property (nonatomic, readonly)                      UIImage      * thumbnail;
@property (nonatomic, readonly)                      UIImage      * preview;
@property (nonatomic, copy)                          NSNumber     * user;
@property (nonatomic, readonly, getter = isEditable) BOOL           editable;
@property (nonatomic, readonly)                      MSDictionary * subitems;

+ (NSFetchedResultsController *)bankableItems;

@end
