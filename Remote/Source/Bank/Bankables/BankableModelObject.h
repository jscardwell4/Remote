//
//  BankableModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"

@class BankItemDetailController;

/** Protocol to ensure all bank objects have the necessary info to display */

@protocol BankableModel <NamedModel>

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel;

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon;

/// isThumbnailable
/// @return BOOL
+ (BOOL)isThumbnailable;

/// isPreviewable
/// @return BOOL
+ (BOOL)isPreviewable;

/// isDetailable
/// @return BOOL
+ (BOOL)isDetailable;

/// isEditable
/// @return BOOL
+ (BOOL)isEditable;

/// isSectionable
/// @return BOOL
+ (BOOL)isSectionable;

/// detailViewControllerClass
/// @return BankItemViewController *
- (BankItemDetailController *)detailViewController;

/// editingViewController
/// @return BankItemViewController *
- (BankItemDetailController *)editingViewController;

/// allItems
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)allItems;

/// updateItem
- (void)updateItem;

/// resetItem
- (void)resetItem;

@property (nonatomic, copy)                               NSString     * name;
@property (nonatomic, copy)                               NSString     * category;
@property (nonatomic, readonly)                           UIImage      * thumbnail;
@property (nonatomic, readonly)                           UIImage      * preview;
@property (nonatomic, copy)                               NSNumber     * user;
@property (nonatomic, readonly, getter = isEditable)      BOOL           editable;
@property (nonatomic, readonly, getter = isThumbnailable) BOOL           thumbnailable;
@property (nonatomic, readonly, getter = isPreviewable)   BOOL           previewable;
@property (nonatomic, readonly, getter = isDetailable)    BOOL           detailable;
@property (nonatomic, readonly)                           MSDictionary * subitems;

@end

@interface BankableModelObject : NamedModelObject <BankableModel>

@end
