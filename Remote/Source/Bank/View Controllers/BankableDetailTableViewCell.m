//
//  BankableDetailTableViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewCell.h"

@interface BankableDetailTableViewCell ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel     * nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIButton    * infoButton;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView * imageView;
@property (nonatomic, weak, readwrite) IBOutlet UISwitch    * infoSwitch;
@property (nonatomic, weak, readwrite) IBOutlet UILabel     * infoLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIStepper   * infoStepper;
@property (nonatomic, weak, readwrite) IBOutlet UITextField * infoTextField;
@property (nonatomic, weak, readwrite) IBOutlet UITextView  * infoTextView;

@end

@implementation BankableDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
