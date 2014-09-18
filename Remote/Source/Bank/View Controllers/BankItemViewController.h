//
//  BankItemViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Bank.h"

@class BankableModelObject;

@interface BankItemViewController : UITableViewController

/// controllerWithItem:
/// @param item
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item;

/// controllerWithItem:editing:
/// @param item
/// @param isEditing
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item editing:(BOOL)isEditing;

/// initWithItem:
/// @param item
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item;

/// initWithItem:editing:
/// @param item
/// @param isEditing
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item editing:(BOOL)isEditing;

@property (nonatomic, strong) BankableModelObject * item;

@end
