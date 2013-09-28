//
//  ImageDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "ImageDetailViewController.h"
#import "Image.h"

@interface ImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel     * fileLabel;
@property (weak, nonatomic) IBOutlet UILabel     * sizeLabel;
@property (weak, nonatomic) IBOutlet UITextField * categoryTextField;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@property (nonatomic, weak, readonly) Image * image;

@end

@implementation ImageDetailViewController

- (Image *)image { return (Image *)self.item; }

+ (Class)itemClass { return [Image class]; }

- (void)updateDisplay
{
    [super updateDisplay];

    self.fileLabel.text         = self.image.fileName;
    self.sizeLabel.text         = PrettySize(self.image.size);
    self.categoryTextField.text = self.image.category;
    self.imageView.image        = self.image.preview;

    if (CGSizeContainsSize(_imageView.bounds.size, _imageView.image.size))
        _imageView.contentMode = UIViewContentModeCenter;
}

- (NSArray *)editableViews
{
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_categoryTextField]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _categoryTextField)
        self.image.category = textField.text;

    else
        [super textFieldDidEndEditing:textField];

}

@end
