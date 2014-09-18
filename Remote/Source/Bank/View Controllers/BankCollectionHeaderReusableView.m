//
//  BankCollectionHeaderReusableView.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionHeaderReusableView.h"
#import "BankCollectionViewController.h"

MSIDENTIFIER_DEFINITION(BankCollectionHeader);

@interface BankCollectionHeaderReusableView ()

@property (nonatomic, weak) IBOutlet UIButton * button;

@end

@implementation BankCollectionHeaderReusableView

/// initWithFrame:
/// @param frame
/// @return instancetype
- (instancetype)initWithFrame:(CGRect)frame {

  if ((self = [super initWithFrame:frame])) {

    self.backgroundColor = [UIColor colorWithR:136 G:136 B:136 A:230];
    UIButton * button = [UIButton newForAutolayout];
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [button addTarget:self action:@selector(toggleItems:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.button = button;
    NSArray * constraints =
      [NSLayoutConstraint constraintsByParsingString:[@"\n" join:@[@"|-18-[button]-18-|",
                                                                   @"button.centerY = self.centerY"]]
                                                           views:@{@"button": button, @"self": self} ];
    [self addConstraints:constraints];

  }

  return self;
}

/// toggleItems:
/// @param sender
- (IBAction)toggleItems:(id)sender { [self.controller toggleItemsForSection:self.section]; }

/// setTitle:
/// @param title
- (void)setTitle:(NSString *)title { [self.button setTitle:title forState:UIControlStateNormal]; }

/// title
/// @return NSString *
- (NSString *)title { return [self.button titleForState:UIControlStateNormal]; }

@end
