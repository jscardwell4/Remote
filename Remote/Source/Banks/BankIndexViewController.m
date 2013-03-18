//
// BankIndexViewController.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BankIndexViewController.h"
#import "ViewDecorator.h"

#import "MSKit/MSKit.h"

static int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface BankIndexViewController () <MSDismissable>

- (IBAction)importBankObject:(UIBarButtonItem *)sender;
- (IBAction)exportBankObject:(UIBarButtonItem *)sender;
- (IBAction)searchBankObjects:(UIBarButtonItem *)sender;

@end

@implementation BankIndexViewController

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

    containerView.clipsToBounds = NO;

    UILabel * labelView = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 24)];

    labelView.backgroundColor = ClearColor;
    labelView.font            = [UIFont boldSystemFontOfSize:16];
    [ViewDecorator decorateLabel:labelView];
// labelView.textColor = [UIColor grayColor];
// labelView.shadowColor = [UIColor lightGrayColor];
// labelView.shadowOffset = CGSizeMake(1, 1);
// labelView.clipsToBounds = NO;
    switch (section) {
        case 0 :
            labelView.text = @"Devices & Codes";
            break;

        case 1 :
            labelView.text = @"Images";
            break;

        case 2 :
            labelView.text = @"Presets";
            break;
    }

    [containerView addSubview:labelView];

    return containerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

    NSString * bankSelected;

    switch (indexPath.section) {
        case 0 :
            switch (indexPath.row) {
                case 0 :
                    bankSelected = @"Component Devices";
                    break;

                case 1 :
                    bankSelected = @"Manufacturers";
                    break;
            }

            break;

        case 1 :
            switch (indexPath.row) {
                case 0 :
                    bankSelected = @"Backgrounds";
                    break;

                case 1 :
                    bankSelected = @"Buttons";
                    break;

                case 2 :
                    bankSelected = @"Icons";
                    break;
            }

            break;

        case 2 :
            switch (indexPath.row) {
                case 0 :
                    bankSelected = @"Remotes";
                    break;

                case 1 :
                    bankSelected = @"Button Groups";
                    break;

                case 2 :
                    bankSelected = @"Buttons";
                    break;
            }

            break;
    } /* switch */

    DDLogDebug(@"%@\n\tselected bank: %@", ClassTagSelectorString, bankSelected);

// <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc]
// initWithNibName:@"<#Nib name#>" bundle:nil];
//// ...
//// Pass the selected object to the new view controller.
// [self.navigationController pushViewController:detailViewController animated:YES];
}     /* tableView */

/**
 * Actions
 */

- (IBAction)importBankObject:(UIBarButtonItem *)sender {
    DDLogDebug(@"%@", ClassTagSelectorString);
}

- (IBAction)exportBankObject:(UIBarButtonItem *)sender {
    DDLogDebug(@"%@", ClassTagSelectorString);
}

- (IBAction)searchBankObjects:(UIBarButtonItem *)sender {
    DDLogDebug(@"%@", ClassTagSelectorString);
}

- (IBAction)dismiss:(id)sender {
    if (self.navigationController && self.navigationController.presentingViewController) [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
