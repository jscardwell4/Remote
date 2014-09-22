//
//  BankPreviewViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankPreviewViewController.h"

@interface BankPreviewViewController ()
@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@end

@implementation BankPreviewViewController {
  BOOL _showStatusBarOnDismiss;
}

/// initWithImage:
/// @param image
/// @return instancetype
- (instancetype)initWithImage:(UIImage *)image { if ((self = [super init])) self.image = image; return self; }

/// loadView
- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:MainScreen.bounds];
  UIImageView * imageView = [[UIImageView alloc] initWithImage:self.image];
  imageView.contentMode = UIViewContentModeCenter;
  [imageView addGestureRecognizer:[UITapGestureRecognizer gestureWithTarget:self action:@selector(dismissPreview:)]];
  [self.view addSubview:imageView];
  [self.view addConstraints:[NSLayoutConstraint constraintsByParsingString:[@"\n" join:@[@"|[image]|", @"V:|[image]|"]]
                                                                     views:@{@"image": imageView}]];
  self.imageView = imageView;
}

/// viewWillAppear:
/// @param animated
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!UIApp.statusBarHidden) {
    _showStatusBarOnDismiss = YES;
    UIApp.statusBarHidden   = YES;
  }
}

/// viewWillDisappear:
/// @param animated
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if (_showStatusBarOnDismiss) UIApp.statusBarHidden = NO;
}

/// setImage:
/// @param image
- (void)setImage:(UIImage *)image { _image = image; if ([self isViewLoaded]) self.imageView.image = image; }

/// dismissPreview:
/// @param sender
- (IBAction)dismissPreview:(id)sender { [self dismissViewControllerAnimated:YES completion:nil]; }

@end
