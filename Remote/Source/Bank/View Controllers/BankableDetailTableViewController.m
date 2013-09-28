//
//  BankableDetailTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"

MSNAMETAG_DEFINITION(BankableDetailHiddenNeighborConstraint);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableDetailTableViewController
////////////////////////////////////////////////////////////////////////////////


@implementation BankableDetailTableViewController

+ (Class)itemClass { return [NSObject class]; }

- (BOOL)hidesBottomBarWhenPushed { return YES; }

- (void)setItem:(id<Bankable>)item
{
    assert([item conformsToProtocol:@protocol(Bankable)]);
    if ([item isKindOfClass:[[self class] itemClass]])
    {
        _item = item;
        if ([self isViewLoaded]) [self updateDisplay];
    }
}

- (void)editItem
{
    assert(_item && [_item isEditable]);
    [self setEditing:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cancelBarButtonItem = SystemBarButton(UIBarButtonSystemItemCancel, @selector(cancel:));
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.item)
    {
        [self updateDisplay];
        self.editButtonItem.enabled = [self.item isEditable];
    }
}

- (void)updateDisplay
{
    self.nameTextField.text = self.item.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.cancelBarButtonItem = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    self.navigationItem.leftBarButtonItem = (editing ? self.cancelBarButtonItem : nil);
    self.editButtonItem.enabled = [self.item isEditable];

    for (UIView * editableView in self.editableViews)
        editableView.userInteractionEnabled = editing;

    if (!editing) [self.item updateItem];

}

- (NSArray *)editableViews
{
    return @[_nameTextField];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////

- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView
{
    assert(   hiddenView
           && neighborView
           && hiddenView.hidden);

    UIView * parentView = neighborView.superview;
    assert(parentView && [hiddenView isDescendantOfView:parentView]);

    NSLayoutConstraint * currentConstraint =
        [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
         objectPassingTest:^BOOL(NSLayoutConstraint * obj, NSUInteger idx)
                           {
                               return [[@[neighborView,hiddenView] set]
                                       isEqualToSet:[@[obj.firstItem,obj.secondItem] set]];
                           }];

    assert(   currentConstraint
           && currentConstraint.relation == NSLayoutRelationEqual
           && (   currentConstraint.firstAttribute == NSLayoutAttributeTrailing
               && currentConstraint.secondAttribute == NSLayoutAttributeTrailing));

    NSLayoutConstraint * newConstraint = [NSLayoutConstraint
                                          constraintWithItem:neighborView
                                                   attribute:NSLayoutAttributeTrailing
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:hiddenView
                                                   attribute:NSLayoutAttributeLeading
                                                  multiplier:1.0
                                                    constant:-16.0];

    newConstraint.nametag = BankableDetailHiddenNeighborConstraintNametag;

    [UIView animateWithDuration:0.25
                     animations:^{
                         hiddenView.hidden = NO;
                         [parentView removeConstraint:currentConstraint];
                         [parentView addConstraint:newConstraint];
                         [parentView layoutIfNeeded];
                     }];
}

- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView
{
    assert(   hiddenView
           && neighborView
           && !hiddenView.hidden);

    UIView * parentView = neighborView.superview;
    assert(parentView && [hiddenView isDescendantOfView:parentView]);

    NSLayoutConstraint * currentConstraint =
        [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
         objectPassingTest:^BOOL(NSLayoutConstraint * obj, NSUInteger idx)
                           {
                               return [[@[neighborView,hiddenView] set]
                                       isEqualToSet:[@[obj.firstItem,obj.secondItem] set]];
                           }];

    assert(   currentConstraint
           && currentConstraint.relation == NSLayoutRelationEqual
           && (   (  currentConstraint.firstAttribute == NSLayoutAttributeTrailing
                   && currentConstraint.secondAttribute == NSLayoutAttributeLeading)
               || (  currentConstraint.firstAttribute == NSLayoutAttributeLeading
                   && currentConstraint.secondAttribute == NSLayoutAttributeTrailing)));

    NSLayoutConstraint * newConstraint = [NSLayoutConstraint
                                          constraintWithItem:neighborView
                                                   attribute:NSLayoutAttributeTrailing
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:hiddenView
                                                   attribute:NSLayoutAttributeTrailing
                                                  multiplier:1.0
                                                    constant:0.0];

    newConstraint.nametag = BankableDetailHiddenNeighborConstraintNametag;

    [UIView animateWithDuration:0.25
                     animations:^{
                         hiddenView.hidden = YES;
                         [parentView removeConstraint:currentConstraint];
                         [parentView addConstraint:newConstraint];
                         [parentView layoutIfNeeded];
                     }];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self.item resetItem];
    [self setEditing:NO animated:YES];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return [self isEditing]; }

- (void)textFieldDidBeginEditing:(UITextField *)textField {}

- (void)textFieldDidEndEditing:(UITextField *)textField {}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField { return YES; }

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return NO;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end



////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableDetailTableDelegate
////////////////////////////////////////////////////////////////////////////////


@implementation BankableDetailTableDelegate

- (void)setRowItems:(NSArray *)rowItems
{
    _rowItems = rowItems;
    [self.tableView reloadData];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rowItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSSTATIC_STRING_CONST kCellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                             forIndexPath:indexPath];
    cell.textLabel.text = [self.rowItems[indexPath.row] valueForKey:@"name"];
    return cell;
}

@end


