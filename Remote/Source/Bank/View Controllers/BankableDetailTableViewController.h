//
//  BankableDetailTableViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Bank.h"

@class BankableModelObject;

@interface BankableDetailTableViewController : UITableViewController

/// controllerWithItem:
/// @param item description
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item;

/// controllerWithItem:editing:
/// @param item description
/// @param isEditing description
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item editing:(BOOL)isEditing;

/// initWithItem:
/// @param item description
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item;

/// initWithItem:editing:
/// @param item description
/// @param isEditing description
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item editing:(BOOL)isEditing;

@property (nonatomic, strong) BankableModelObject * item;

@end
