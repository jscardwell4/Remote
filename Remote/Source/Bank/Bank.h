//
//  Bank.h
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"
#import "NamedModelObject.h"

@class BankableModelObject, BankableDetailTableViewController;

/** Options for how a bank object is displayed */

typedef NS_OPTIONS(uint8_t, BankFlags) {
    BankDefault    = 0b00000000,
    BankDetail     = 0b00000001,
    BankPreview    = 0b00000010,
    BankThumbnail  = 0b00000100,
    BankEditable   = 0b00001000,
    BankNoSections = 0b00010000,
    BankReserved   = 0b11100000
};

@protocol BankableDetailDelegate;


/** Protocol to ensure all bank objects have the necessary info to display */

@protocol BankableModel <NamedModel>

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel;

/// bankFlags
/// @return BankFlags
+ (BankFlags)bankFlags;

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon;

/// detailViewControllerClass
/// @return BankableDetailTableViewController *
- (BankableDetailTableViewController *)detailViewController;

/// editingViewController
/// @return BankableDetailTableViewController *
- (BankableDetailTableViewController *)editingViewController;

/// bankableItems
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)bankableItems;

/// updateItem
- (void)updateItem;

/// resetItem
- (void)resetItem;

@property (nonatomic, copy)                          NSString     * name;
@property (nonatomic, copy)                          NSString     * category;
@property (nonatomic, readonly)                      UIImage      * thumbnail;
@property (nonatomic, readonly)                      UIImage      * preview;
@property (nonatomic, copy)                          NSNumber     * user;
@property (nonatomic, readonly, getter = isEditable) BOOL           editable;
@property (nonatomic, readonly)                      MSDictionary * subitems;

@end

/** The bank singleton interface */

@interface Bank : MSSingletonController

/// registeredClasses
/// @return NSArray *
+ (NSArray *)registeredClasses;

@end

