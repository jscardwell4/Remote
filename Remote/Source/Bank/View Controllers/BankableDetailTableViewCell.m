//
//  BankableDetailTableViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewCell.h"

MSIDENTIFIER_DEFINITION(BankableDetailCellLabelStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellListStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellButtonStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellImageStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellSwitchStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellStepperStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellDetailStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellTextViewStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellTextFieldStyle);
MSIDENTIFIER_DEFINITION(BankableDetailCellTableStyle);


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

/// initWithStyle:reuseIdentifier:
/// @param style description
/// @param reuseIdentifier description
/// @return instancetype
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  static NSDictionary const * index = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{

    // Create some more or less generic constraint strings for use in decorator blocks

    NSString * nameAndInfoBaselineConstraints = [@"\n" join:@[@"|-20-[name]-8-[info]-20-|",
                                                              @"name.baseline = info.baseline",
                                                              @"V:|-8-[name]-8-|"]];

    NSString * nameAndInfoCenterYConstraints  = [@"\n" join:@[@"|-20-[name]-8-[info]-20-|",
                                                              @"name.centerY = info.centerY",
                                                              @"V:|-8-[name]-8-|"]];

    NSString * infoConstraints                = [@"\n" join:@[@"|-20-[info]-20-|", @"V:|-8-[info]-8-|"]];

    NSString * nameAndTextViewInfoConstraints = [@"\n" join:@[@"V:|-5-[name]-5-[info]-5-|",
                                                              @"|-20-[name]",
                                                              @"|-20-[info]-20-|"]];

    NSString * tableViewInfoConstraints       = [@"\n" join:@[@"|[info]|", @"V:|-5-[info]-5-|"]];

    NSString * nameInfoAndStepperConstraints  = [@"\n" join:@[@"|-20-[name]-8-[info]-8-[stepper]-20-|",
                                                              @"name.baseline = info.baseline",
                                                              @"stepper.centerY = name.centerY",
                                                              @"V:|-8-[name]-8-|"]];

    NSString * imageViewInfoConstraints       = [@"\n" join:@[@"|-20-[info]-20-|", @"V:|-20-[info]-20-|"]];


    // Create the fonts to use in decorator blocks

    UIFont  * nameFont  = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIFont  * infoFont  = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    // Create the colors to use in decorator blocks

    UIColor * nameColor = [UIColor colorWithRed: 59.0/255.0 green: 60.0/255.0 blue: 64.0/255.0 alpha:1.0];
    UIColor * infoColor = [UIColor colorWithRed:159.0/255.0 green:160.0/255.0 blue:164.0/255.0 alpha:1.0];

    // Create the decorator blocks keyed by the corresponding cell reuse identifier

    index = @{

              BankableDetailCellLabelStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UILabel * info = [UILabel newForAutolayout];
                  info.font      = infoFont;
                  info.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoLabel = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameAndInfoBaselineConstraints
                                                           views:@{@"name": name, @"info": info}];

                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellListStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * info = [UILabel newForAutolayout];
                  info.font      = infoFont;
                  info.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoLabel = info;

                  NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:infoConstraints
                                                                                   views:@{@"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellButtonStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UIButton * info = [UIButton newForAutolayout];
                  info.titleLabel.font      = infoFont;
                  [info setTitleColor:infoColor forState:UIControlStateNormal];
                  [cell.contentView addSubview:info];
                  cell.infoButton = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameAndInfoBaselineConstraints
                                                           views:@{@"name": name, @"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellImageStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UIImageView * info = [UIImageView newForAutolayout];
                  info.contentMode = UIViewContentModeScaleAspectFit;
                  [cell.contentView addSubview:info];
                  cell.infoImageView = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:imageViewInfoConstraints
                                                           views:@{@"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellSwitchStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UISwitch * info = [UISwitch newForAutolayout];
                  [cell.contentView addSubview:info];
                  cell.infoSwitch = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameAndInfoCenterYConstraints
                                                           views:@{@"name": name, @"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellStepperStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UILabel * info = [UILabel newForAutolayout];
                  info.font      = infoFont;
                  info.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoLabel = info;

                  UIStepper * stepper = [UIStepper newForAutolayout];
                  stepper.hidden = YES;
                  [cell.contentView addSubview:stepper];
                  cell.infoStepper = stepper;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameInfoAndStepperConstraints
                                                           views:@{@"name": name,
                                                                   @"info": info,
                                                                   @"stepper": stepper}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellDetailStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

                  UIButton * info = [UIButton newForAutolayout];
                  info.titleLabel.font      = infoFont;
                  info.titleLabel.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoButton = info;

                  NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:infoConstraints
                                                                                   views:@{@"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellTextViewStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UITextView * info = [UITextView newForAutolayout];
                  info.font      = infoFont;
                  info.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoTextView = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameAndTextViewInfoConstraints
                                                           views:@{@"name": name, @"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellTextFieldStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = [UILabel newForAutolayout];
                  name.font      = nameFont;
                  name.textColor = nameColor;
                  [cell.contentView addSubview:name];
                  cell.nameLabel = name;

                  UITextField * info = [UITextField newForAutolayout];
                  info.font      = infoFont;
                  info.textColor = infoColor;
                  [cell.contentView addSubview:info];
                  cell.infoTextField = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:nameAndInfoBaselineConstraints
                                                           views:@{@"name": name, @"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                },

              BankableDetailCellTableStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UITableView * info = [[UITableView alloc] initWithFrame:CGRectZero
                                                                     style:UITableViewStylePlain];
                  [info setTranslatesAutoresizingMaskIntoConstraints:NO];
                  info.separatorStyle = UITableViewCellSeparatorStyleNone;
                  info.rowHeight = 38.0;
                  Class c = [BankableDetailTableViewCell class];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellLabelStyleIdentifier    ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellListStyleIdentifier     ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellButtonStyleIdentifier   ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellImageStyleIdentifier    ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellSwitchStyleIdentifier   ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellStepperStyleIdentifier  ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellDetailStyleIdentifier   ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellTextViewStyleIdentifier ];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellTextFieldStyleIdentifier];
                  [info registerClass:c forCellReuseIdentifier:BankableDetailCellTableStyleIdentifier    ];
                  [cell.contentView addSubview:info];
                  cell.infoTableView = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:tableViewInfoConstraints
                                                           views:@{@"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                }

              };

  });




  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {


    void (^decorator)(BankableDetailTableViewCell *) = index[reuseIdentifier];
    if (decorator) decorator(self);

  }

  return self;

}


/// prepareForReuse
- (void)prepareForReuse {
  [super prepareForReuse];

  self.accessoryType = ([BankableDetailCellDetailStyleIdentifier isEqualToString:self.reuseIdentifier]
                        ? UITableViewCellAccessoryDetailDisclosureButton
                        : UITableViewCellAccessoryNone);

  _nameLabel.text = nil;

  [_infoButton setTitle:nil forState:UIControlStateNormal];
  [_infoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

  _infoImageView.image = nil;

  _infoSwitch.on = NO;
  [_infoSwitch removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

  _infoLabel.text = nil;

  _infoStepper.value = 0;
  [_infoStepper removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

  _infoTextField.text  = nil;
  _infoTextField.delegate = nil;

  _infoTextView.text   = nil;
  _infoTextView.delegate = nil;

  _infoTableView.delegate = nil;
  _infoTableView.dataSource = nil;
  [_infoTableView reloadData];

  [_pickerView removeFromSuperview];
  _pickerView = nil;

}

/// pickerView
/// @return UIPickerView *
- (UIPickerView *)pickerView {
  if (!_pickerView) {
    UIPickerView * picker = [UIPickerView newForAutolayout];
    [self addSubview:picker];
    self.pickerView = picker;

    NSString * constraintsString = [@"\n" join:@[@"picker.left   = self.left",
                                                 @"picker.right  = self.right",
                                                 @"picker.height = 162",
                                                 @"picker.bottom = self.bottom"]];

    NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:constraintsString
                                                                     views:@{@"picker": picker,
                                                                             @"self": self}];

    [self addConstraints:constraints];

  }

  return _pickerView;
}

/// name
/// @return NSString *
- (NSString *)name { return (_nameLabel.text ?: nil); }

/// setName:
/// @param name description
- (void)setName:(NSString *)name { _nameLabel.text = name; }

/// text
/// @return NSString *
- (NSString *)text {

  NSString * text = nil;

  if (_infoButton)         text = [_infoButton titleForState:UIControlStateNormal];
  else if (_infoLabel)     text = _infoLabel.text;
  else if (_infoTextField) text = _infoTextField.text;
  else if (_infoTextView)  text = _infoTextView.text;

  return text;

}

/// setText:
/// @param text description
- (void)setText:(NSString *)text {

  if (_infoButton)          [_infoButton setTitle:text forState:UIControlStateNormal];
  else if (_infoLabel)      _infoLabel.text = text;
  else if (_infoTextField)  _infoTextField.text = text;
  else if (_infoTextView)   _infoTextView.text = text;

}

/// image
/// @return UIImage *
- (UIImage *)image { return _infoImageView.image; }

/// setImage:
/// @param image description
- (void)setImage:(UIImage *)image { _infoImageView.image = image; }

@end
