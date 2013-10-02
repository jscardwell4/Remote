//
//  BankableDetailTableViewController_Private.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController.h"
#import "BankableDetailTableViewCell.h"

@class BankableDetailTableDelegate;

@interface BankableDetailTableViewController () <UITextFieldDelegate>

@property (nonatomic, weak)     IBOutlet UITextField                 * nameTextField;
@property (nonatomic, strong)   IBOutlet UIBarButtonItem             * cancelBarButtonItem;
@property (nonatomic, strong)   IBOutlet BankableDetailTableDelegate * tableDelegate;
@property (nonatomic, readonly)          NSArray         * editableViews;

@property (nonatomic, strong) UINib   * textFieldCellNib;
@property (nonatomic, strong) UINib   * labelCellNib;
@property (nonatomic, strong) UINib   * imageCellNib;
@property (nonatomic, strong) UINib   * textViewCellNib;
@property (nonatomic, strong) UINib   * stepperCellNib;
@property (nonatomic, strong) UINib   * sliderCellNib;
@property (nonatomic, strong) UINib   * buttonCellNib;


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

MSEXTERN_IDENTIFIER(StepperCell);
MSEXTERN_IDENTIFIER(SliderCell);
MSEXTERN_IDENTIFIER(LabelCell);
MSEXTERN_IDENTIFIER(ButtonCell);
MSEXTERN_IDENTIFIER(ImageCell);
MSEXTERN_IDENTIFIER(TextFieldCell);
MSEXTERN_IDENTIFIER(TextViewCell);
