//
//  PresetDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "PresetDetailViewController.h"
#import "Preset.h"
#import "RETypedefs.h"

@interface PresetDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField * categoryTextField;
@property (weak, nonatomic) IBOutlet UILabel     * typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@property (nonatomic, weak, readonly) Preset * preset;

@end

@implementation PresetDetailViewController

- (Preset *)preset { return (Preset *)self.item; }

+ (Class)itemClass { return [Preset class]; }

- (void)updateDisplay
{
    [super updateDisplay];

    self.categoryTextField.text   = self.preset.category;

    REType type = [[self.preset valueForKeyPath:@"element.type"] intValue];
    self.typeLabel.text  = NSStringFromREType(type);

    self.imageView.image = self.preset.preview;

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
        self.preset.category = textField.text;

    else
        [super textFieldDidEndEditing:textField];
    
}

@end
