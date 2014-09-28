//
//  Bank.h
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

@import Foundation;

@protocol NamedModel, BankableCategory;
@class BankItemDetailController;

/// inherits `uuid` from `Model` and `name` from `NamedModel`
@protocol BankableModel <NamedModel>

/// The text to show in the root bank table view
/// @return NSString *
+ (NSString *)directoryLabel;

/// The icon to display next to the `directoryLabel`
/// @return UIImage *
+ (UIImage *)directoryIcon;

/// Items provide a thumbnail image
/// @return BOOL
+ (BOOL)isThumbnailable;

/// Items provide a preview image
/// @return BOOL
+ (BOOL)isPreviewable;

/// Items provide a detail view controller
/// @return BOOL
+ (BOOL)isDetailable;

/// Items provide an editing view controller
/// @return BOOL
+ (BOOL)isEditable;

/// Items can be divided into logical sections
/// @return BOOL
+ (BOOL)isCategorized;

/// The view controller to push for displaying an item's details
/// @return BankItemViewController *
- (BankItemDetailController *)detailViewController;

/// The view controller to push for editing an item's details
/// @return BankItemViewController *
- (BankItemDetailController *)editingViewController;

/// Method for getting a controller preloaded and fetch executed for all the class' existing items
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)allItems;

/// rootCategories
/// @return NSArray *
+ (NSArray *)rootCategories;

/// Method for forcing an item to save any changes to storage
- (void)updateItem;

/// Method for forcing an item to reload itself from storage
- (void)resetItem;

@property (nonatomic, strong)                             id<BankableCategory>   category;
@property (nonatomic, readonly)                           UIImage              * thumbnail;
@property (nonatomic, readonly)                           UIImage              * preview;
@property (nonatomic, copy)                               NSNumber             * user;
@property (nonatomic, readonly, getter = isEditable)      BOOL                   editable;
@property (nonatomic, readonly, getter = isThumbnailable) BOOL                   thumbnailable;
@property (nonatomic, readonly, getter = isPreviewable)   BOOL                   previewable;
@property (nonatomic, readonly, getter = isDetailable)    BOOL                   detailable;

@end

@protocol BankableCategory <NamedModel>

@property (nonatomic, readonly) NSSet                * allItems;

@optional
@property (nonatomic, readonly) NSSet                * subCategories;
@property (nonatomic, readonly) id<BankableCategory>   parentCategory;

@end
