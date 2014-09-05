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

- (IBAction)toggleItems:(id)sender {
  [self.controller toggleItemsForSection:self.section];
}

- (void)setTitle:(NSString *)title {
  if (_button)
    [self.button setTitle:title forState:UIControlStateNormal];
  else if (_label)
    self.label.text = title;
}

- (NSString *)title {
  return (_button ? [self.button titleForState:UIControlStateNormal] : self.label.text);
}

@end
