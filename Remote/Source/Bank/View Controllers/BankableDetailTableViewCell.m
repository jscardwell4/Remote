//
//  BankableDetailTableViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewCell.h"

@interface BankableDetailTableViewCell ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel      * nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIButton     * infoButton;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView  * infoImageView;
@property (nonatomic, weak, readwrite) IBOutlet UISwitch     * infoSwitch;
@property (nonatomic, weak, readwrite) IBOutlet UILabel      * infoLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIStepper    * infoStepper;
@property (nonatomic, weak, readwrite) IBOutlet UITextField  * infoTextField;
@property (nonatomic, weak, readwrite) IBOutlet UITextView   * infoTextView;
@property (nonatomic, weak, readwrite) IBOutlet UITableView  * infoTableView;
@property (nonatomic, weak, readwrite) IBOutlet UIPickerView * pickerView;


@end

@implementation BankableDetailTableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    _nameLabel.text = nil;
    [_infoButton setTitle:nil forState:UIControlStateNormal];
    _infoImageView.image = nil;
    _infoSwitch.on       = NO;
    _infoLabel.text      = nil;
    _infoStepper.value   = 0;
    _infoTextField.text  = nil;
    _infoTextView.text   = nil;
    [_pickerView removeFromSuperview];
    _pickerView = nil;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView)
    {
        UIPickerView * pickerView = [UIPickerView newForAutolayout];
        [self addSubview:pickerView];
        [self addConstraints:[NSLayoutConstraint
                              constraintsByParsingString:@"pickerView.left = self.left\n"
                                                          "pickerView.right = self.right\n"
                                                          "pickerView.height = 162\n"
                                                          "pickerView.bottom = self.bottom"
                              views:NSDictionaryOfVariableBindings(pickerView, self)]];
        self.pickerView = pickerView;

    }
    return _pickerView;
}

@end
