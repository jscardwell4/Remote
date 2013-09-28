//
//  BankableDetailTableViewController_Private.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController.h"

@class BankableDetailTableDelegate;

@interface BankableDetailTableViewController () <UITextFieldDelegate>

@property (nonatomic, weak)     IBOutlet UITextField                 * nameTextField;
@property (nonatomic, strong)   IBOutlet UIBarButtonItem             * cancelBarButtonItem;
@property (nonatomic, strong)   IBOutlet BankableDetailTableDelegate * tableDelegate;
@property (nonatomic, readonly)          NSArray         * editableViews;

- (void)updateDisplay;
+ (Class)itemClass;

- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView;

- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView;

@end

@interface BankableDetailTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView                       * tableView;
@property (nonatomic, weak)          NSArray                           * rowItems;
@property (nonatomic, weak) IBOutlet BankableDetailTableViewController * tableViewController;
@end


MSEXTERN_NAMETAG(BankableDetailHiddenNeighborConstraint);