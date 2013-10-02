//
//  BankableDetailTableViewCell.h
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface BankableDetailTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) IBOutlet UILabel     * nameLabel;
@property (nonatomic, weak, readonly) IBOutlet UIButton    * infoButton;
@property (nonatomic, weak, readonly) IBOutlet UIImageView * imageView;
@property (nonatomic, weak, readonly) IBOutlet UISwitch    * infoSwitch;
@property (nonatomic, weak, readonly) IBOutlet UILabel     * infoLabel;
@property (nonatomic, weak, readonly) IBOutlet UIStepper   * infoStepper;
@property (nonatomic, weak, readonly) IBOutlet UITextField * infoTextField;
@property (nonatomic, weak, readonly) IBOutlet UITextView  * infoTextView;

@end
