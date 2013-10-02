//
//  BankCollectionHeaderReusableView.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionHeaderReusableView.h"
#import "BankCollectionViewController.h"

@implementation BankCollectionHeaderReusableView

- (IBAction)toggleItems:(id)sender
{
    [self.controller toggleItemsForSection:self.section];
}

- (void)setTitle:(NSString *)title
{
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (NSString *)title { return [self.button titleForState:UIControlStateNormal]; }

@end
