//
//  BankPreviewViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankPreviewViewController.h"

@interface BankPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BankPreviewViewController
{
    BOOL _showStatusBarOnDismiss;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_image) self.imageView.image = _image;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!UIApp.statusBarHidden)
    {
        _showStatusBarOnDismiss = YES;
        UIApp.statusBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_showStatusBarOnDismiss) UIApp.statusBarHidden = NO;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if ([self isViewLoaded])
        self.imageView.image = image;
}

- (IBAction)dismissPreview:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
