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

- (NSString *)name { return (_nameLabel.text ?: nil); }

- (void)setName:(NSString *)name { if (_nameLabel) _nameLabel.text = name; }

- (NSString *)text
{
    NSString * text = nil;
    if (_infoButton) text = [_infoButton titleForState:UIControlStateNormal];
    else if (_infoLabel) text = _infoLabel.text;
    else if (_infoTextField) text = _infoTextField.text;
    else if (_infoTextView) text = _infoTextView.text;
    return text;
}

- (void)setText:(NSString *)text
{
    if (_infoButton) [_infoButton setTitle:text forState:UIControlStateNormal];
    else if (_infoLabel) _infoLabel.text = text;
    else if (_infoTextField) _infoTextField.text = text;
    else if (_infoTextView) _infoTextView.text = text;
}

- (UIImage *)image { return _infoImageView.image; }

- (void)setImage:(UIImage *)image { if (_infoImageView) _infoImageView.image = image; }

@end
