//
//  BankableDetailTableViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "BankableDetailTableViewCell.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

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

MSSTATIC_NAMETAG(BankableDetailCellIntegerKeyboard);

@interface BankableDetailTableViewCell () <UITextFieldDelegate, UITextViewDelegate,
                                           UIPickerViewDataSource, UIPickerViewDelegate,
                                           UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UILabel      * nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIButton     * infoButton;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView  * infoImageView;
@property (nonatomic, weak, readwrite) IBOutlet UISwitch     * infoSwitch;
@property (nonatomic, weak, readwrite) IBOutlet UILabel      * infoLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIStepper    * stepper;
@property (nonatomic, weak, readwrite) IBOutlet UITextField  * infoTextField;
@property (nonatomic, weak, readwrite) IBOutlet UITextView   * infoTextView;
@property (nonatomic, weak, readwrite) IBOutlet UITableView  * table;
@property (nonatomic, weak, readwrite) IBOutlet UIPickerView * pickerView;

@property (nonatomic, copy) NSString * textViewBeginState;

@end

@implementation BankableDetailTableViewCell

/// validIdentifiers
/// @return NSSet const *
+ (NSSet const *)validIdentifiers {

  static NSSet const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    identifiers = [@[ BankableDetailCellLabelStyleIdentifier,
                      BankableDetailCellListStyleIdentifier,
                      BankableDetailCellButtonStyleIdentifier,
                      BankableDetailCellStepperStyleIdentifier,
                      BankableDetailCellSwitchStyleIdentifier,
                      BankableDetailCellTableStyleIdentifier,
                      BankableDetailCellTextFieldStyleIdentifier,
                      BankableDetailCellTextViewStyleIdentifier,
                      BankableDetailCellImageStyleIdentifier,
                      BankableDetailCellDetailStyleIdentifier ] set];


  });

  return identifiers;
}

/// isValidIentifier:
/// @param identifier description
/// @return BOOL
+ (BOOL)isValidIentifier:(NSString *)identifier { return [[self validIdentifiers] containsObject:identifier]; }

/// registerIdentifiersWithTableView:
/// @param tableView description
+ (void)registerIdentifiersWithTableView:(UITableView *)tableView {

  for (NSString * identifier in [BankableDetailTableViewCell validIdentifiers])
    [tableView registerClass:[BankableDetailTableViewCell class] forCellReuseIdentifier:identifier];

}

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

    NSString * nameInfoAndStepperConstraints  = [@"\n" join:@[@"|-20-[name]-8-[info]-20-|",
                                                              @"name.baseline = info.baseline",
                                                              @"[info]-8-[stepper]",
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
                  info.font          = infoFont;
                  info.textColor     = infoColor;
                  info.textAlignment = NSTextAlignmentRight;
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
                  info.font          = infoFont;
                  info.textColor     = infoColor;
                  info.textAlignment = NSTextAlignmentRight;
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
                  info.titleLabel.font          = infoFont;
                  info.titleLabel.textAlignment = NSTextAlignmentRight;
                  [info setTitleColor:infoColor forState:UIControlStateNormal];
                  info.userInteractionEnabled = NO;
                  [cell.contentView addSubview:info];
                  [info addTarget:cell
                           action:@selector(buttonUpAction:)
                 forControlEvents:UIControlEventTouchUpInside];
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
                  info.userInteractionEnabled = NO;
                  [cell.contentView addSubview:info];
                  [info addTarget:cell
                           action:@selector(switchValueDidChange:)
                 forControlEvents:UIControlEventValueChanged];
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
                  info.font          = infoFont;
                  info.textColor     = infoColor;
                  info.textAlignment = NSTextAlignmentRight;
                  [cell.contentView addSubview:info];
                  cell.infoLabel = info;

                  UIStepper * stepper = [UIStepper newForAutolayout];
                  stepper.hidden = YES;
                  info.userInteractionEnabled = NO;
                  [cell.contentView addSubview:stepper];
                  [stepper addTarget:cell
                              action:@selector(stepperValueDidChange:)
                    forControlEvents:UIControlEventValueChanged];
                  cell.stepper = stepper;

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
                  info.titleLabel.font         = infoFont;
                  info.titleLabel.textAlignment = NSTextAlignmentRight;
                  [info setTitleColor:infoColor forState:UIControlStateNormal];
                  [cell.contentView addSubview:info];
                  [info addTarget:cell
                           action:@selector(buttonUpAction:)
                 forControlEvents:UIControlEventTouchUpInside];
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
                  info.delegate  = cell;
                  info.userInteractionEnabled = NO;
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
                  info.font          = infoFont;
                  info.textColor     = infoColor;
                  info.textAlignment = NSTextAlignmentRight;
                  info.delegate      = cell;
                  info.userInteractionEnabled = NO;
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
                  [cell.contentView addSubview:info];
                  cell.table = info;

                  NSArray * constraints =
                  [NSLayoutConstraint constraintsByParsingString:tableViewInfoConstraints
                                                           views:@{@"info": info}];
                  assert([constraints count]);
                  [cell.contentView addConstraints:constraints];

                }

              };

  });




  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

    assert(self.bounds.size.height > 0);

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    UIPickerView * picker = [UIPickerView newForAutolayout];
    picker.delegate   = self;
    picker.dataSource = self;
    picker.hidden     = YES;
    [self addSubview:picker];
    self.pickerView = picker;

    NSString * constraintsString = [@"\n" join:@[@"|[content]|",
                                                 @"V:|[content]",
                                                 $(@"content.height = %@", @(self.height)),
                                                 @"|[picker]|",
                                                 @"picker.height = 162",
                                                 @"picker.top = content.bottom"]];

    NSDictionary * views = @{@"picker": picker, @"content": self.contentView};

    NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:constraintsString
                                                                     views:views];

    [self addConstraints:constraints];

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

  _infoImageView.image = nil;

  _infoSwitch.on = NO;

  _infoLabel.text = nil;

  _stepper.value = 0;
  _stepper.minimumValue = CGFLOAT_MIN;
  _stepper.maximumValue = CGFLOAT_MAX;
  _stepper.wraps = YES;

  _infoTextField.text  = nil;

  _infoTextView.text   = nil;

  _tableData = nil;
  [_table reloadData];

  _pickerData = nil;
  _pickerSelection = nil;

}

/// name
/// @return NSString *
- (NSString *)name { return (_nameLabel.text ?: nil); }

/// setName:
/// @param name description
- (void)setName:(NSString *)name { _nameLabel.text = name; }

/// setUseIntegerKeyboard:
/// @param useIntegerKeyboard description
- (void)setUseIntegerKeyboard:(BOOL)useIntegerKeyboard {
  if (_useIntegerKeyboard != useIntegerKeyboard) {
    _useIntegerKeyboard = useIntegerKeyboard;
    self.infoTextField.inputView = (_useIntegerKeyboard ? [self integerKeyboardViewForTextField] : nil);
  }
}

/// text
/// @return id
- (id)info {

  static NSDictionary const * getters = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    getters = @{ BankableDetailCellLabelStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.infoLabel.text; },
                 BankableDetailCellListStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.infoLabel.text; },
                 BankableDetailCellButtonStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) {
                    return [cell.infoButton titleForState:UIControlStateNormal];
                   },
                 BankableDetailCellImageStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.infoImageView.image; },
                 BankableDetailCellSwitchStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return @(cell.infoSwitch.on); },
                 BankableDetailCellStepperStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return @(cell.stepper.value); },
                 BankableDetailCellDetailStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) {
                    return [cell.infoButton titleForState:UIControlStateNormal];
                   },
                 BankableDetailCellTextViewStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.infoTextView.text; },
                 BankableDetailCellTextFieldStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.infoTextField.text; },
                 BankableDetailCellTableStyleIdentifier:
                   ^id(BankableDetailTableViewCell * cell) { return cell.tableData; } };

  });

  id (^getter)(BankableDetailTableViewCell * cell) = getters[self.reuseIdentifier];
  return (getter ? getter(self) : nil);

}

/// setInfo:
/// @param info description
- (void)setInfo:(id)info {

  static NSDictionary const * setters = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{


    NSString *(^textFromObject)(id) = ^(id obj) {

      NSString * text = nil;

      if (isStringKind(obj)) text = obj;

      else if (isNumberKind(obj)) text = [obj stringValue];

      else if ([obj respondsToSelector:@selector(name)]) text = [obj name];

      return text;

    };

    setters = @{ BankableDetailCellLabelStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                     cell.infoLabel.text = textFromObject(info);
                   },
                 BankableDetailCellListStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                     cell.infoLabel.text = textFromObject(info);
                   },
                 BankableDetailCellButtonStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                     [cell.infoButton setTitle:textFromObject(info) forState:UIControlStateNormal];
                   },
                 BankableDetailCellImageStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                    if ([info isKindOfClass:[UIImage class]] || !info) {
                      cell.infoImageView.image = info;
                      if (info) {
                        CGSize imageSize  = ((UIImage *)info).size;
                        CGSize boundsSize = cell.infoImageView.bounds.size;
                        if (CGSizeContainsSize(boundsSize, imageSize))
                          cell.infoImageView.contentMode = UIViewContentModeCenter;
                      }
                    }
                   },
                 BankableDetailCellSwitchStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                    if (isNumberKind(info) || !info) cell.infoSwitch.on = [info boolValue];
                   },
                 BankableDetailCellStepperStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                     if (isNumberKind(info) || !info) {
                       cell.stepper.value = [info intValue];
                       cell.infoLabel.text = textFromObject(info);
                     }
                   },
                 BankableDetailCellDetailStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                     [cell.infoButton setTitle:textFromObject(info) forState:UIControlStateNormal];
                   },
                 BankableDetailCellTextViewStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                    cell.infoTextView.text = textFromObject(info);
                   },
                 BankableDetailCellTextFieldStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                    cell.infoTextField.text = textFromObject(info);
                   },
                 BankableDetailCellTableStyleIdentifier:
                   ^(BankableDetailTableViewCell * cell, id info) {
                    if (isArrayKind(info) || !info) {
                      cell.tableData = info;
                      [cell.table reloadData];
                    }
                   } };

  });

  void (^setter)(BankableDetailTableViewCell * cell, id info) = setters[self.reuseIdentifier];
  if (setter) setter(self, info);

}

/// image
/// @return UIImage *
- (UIImage *)image { return _infoImageView.image; }

/// setImage:
/// @param image description
- (void)setImage:(UIImage *)image {

  self.infoImageView.image = image;

  CGSize imageSize  = image.size;
  CGSize boundsSize = self.infoImageView.bounds.size;

  if (CGSizeContainsSize(boundsSize, imageSize))
    self.infoImageView.contentMode = UIViewContentModeCenter;

}

/// stepperValueDidChange:
/// @param sender description
- (void)stepperValueDidChange:(UIStepper *)sender {
  if (self.changeHandler) self.changeHandler(self);
  self.infoLabel.text = [@(sender.value) stringValue];
}

/// buttonUpAction:
/// @param sender description
- (void)buttonUpAction:(UIButton *)sender { if (self.buttonActionHandler) self.buttonActionHandler(self); }

/// switchValueDidChange:
/// @param sender description
- (void)switchValueDidChange:(UISwitch *)sender { if (self.changeHandler) self.changeHandler(self); }

/// setStepperMinValue:
/// @param stepperMinValue description
- (void)setStepperMinValue:(double)stepperMinValue { self.stepper.minimumValue = stepperMinValue; }

/// setStepperMaxValue:
/// @param stepperMaxValue description
- (void)setStepperMaxValue:(double)stepperMaxValue { self.stepper.maximumValue = stepperMaxValue; }

/// setStepperWraps:
/// @param stepperWraps description
- (void)setStepperWraps:(BOOL)stepperWraps { self.stepper.wraps = stepperWraps; }

/// stepperMinValue
/// @return double
- (double)stepperMinValue { return self.stepper.minimumValue; }

/// stepperMaxValue
/// @return double
- (double)stepperMaxValue { return self.stepper.maximumValue; }

/// stepperWraps
/// @return BOOL
- (BOOL)stepperWraps { return self.stepper.wraps; }

/// willTransitionToState:
/// @param state description
- (void)willTransitionToState:(UITableViewCellStateMask)state {

  static NSDictionary const * handlers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    handlers = @{ BankableDetailCellButtonStyleIdentifier:
                    ^(BankableDetailTableViewCell *cell, BOOL editing) {
                      cell.infoButton.userInteractionEnabled = editing;
                    },
                  BankableDetailCellSwitchStyleIdentifier:
                    ^(BankableDetailTableViewCell *cell, BOOL editing) {
                      cell.infoSwitch.userInteractionEnabled = editing;
                    },
                  BankableDetailCellStepperStyleIdentifier:
                    ^(BankableDetailTableViewCell *cell, BOOL editing) {
                      cell.stepper.userInteractionEnabled = editing;
                    },
                  BankableDetailCellTextViewStyleIdentifier:
                    ^(BankableDetailTableViewCell *cell, BOOL editing) {
                      cell.infoTextView.userInteractionEnabled = editing;
                    },
                  BankableDetailCellTextFieldStyleIdentifier:
                    ^(BankableDetailTableViewCell *cell, BOOL editing) {
                      cell.infoTextField.userInteractionEnabled = editing;
                    } };

  });


  void (^handler)(BankableDetailTableViewCell * cell, BOOL editing) = handlers[self.reuseIdentifier];
  if (handler) {

    BOOL editing = ((state & UITableViewCellStateEditingMask) == UITableViewCellStateEditingMask);

    MSLogDebug(@"calling handler for transition to %@ state", (editing ? @"editing" : @"non-editing"));

    handler(self, editing);

  }


}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Input views
////////////////////////////////////////////////////////////////////////////////


/// integerKeyboardViewForTextField:
/// @return UIView *
- (UIView *)integerKeyboardViewForTextField {

  UITextField * textField = self.infoTextField;

  if (!textField) return nil;  // At the moment, the insertion/deletion actions below are linked to text field

  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
  view.nametag = BankableDetailCellIntegerKeyboardNametag;

  NSDictionary * index = @{ @0 : @"1",      @1 : @"2",    @2 : @"3",
                            @3 : @"4",      @4 : @"5",    @5 : @"6",
                            @6 : @"7",      @7 : @"8",    @8 : @"9",
                            @9 : @"Erase",  @10 : @"0",  @11 : @"Done" };


  for (NSUInteger i = 0; i < 12; i++) {

    UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
    PrepConstraints(b);

    if (i < 11) {

      NSString * imageName = $(@"IntegerKeyboard_%@.png", index[@(i)]);
      UIImage  * image     = [UIImage imageNamed:imageName];
      [b setImage:image forState:UIControlStateNormal];
      imageName = $(@"IntegerKeyboard_%@-Highlighted.png", index[@(i)]);
      image     = [UIImage imageNamed:imageName];
      [b setImage:image forState:UIControlStateHighlighted];

    } else {

      [b setBackgroundColor:UIColorMake(0, 122 / 255.0, 1, 1)];
      [b setTitle:@"Done" forState:UIControlStateNormal];
      [b setTitleColor:WhiteColor forState:UIControlStateNormal];

    }

    void (^actionBlock)(void) =
    (i == 9
     ? ^{ textField.text = [textField.text substringToIndex:textField.text.length - 1]; }  // Erase
     : (i == 11
        ? ^{ [textField resignFirstResponder]; }                                           // Done
        : ^{ [textField insertText:index[@(i)]]; }                                         // 0-9
        )
     );

    [b addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

    ConstrainHeight(b, (i < 3 ? 54 : 53.5));
    ConstrainWidth(b, (i % 3 && (i + 1) % 3 ? 110 : 104.5));
    [view addSubview:b];

    if (i < 3) AlignViewTop(view, b, 0);
    else if (i > 8) AlignViewBottom(view, b, 0);

    if (i % 3 == 0) AlignViewLeft(view, b, 0);
    else if ((i + 1) % 3 == 0) AlignViewRight(view, b, 0);
    else CenterViewH(view, b, 0);

    if (i >= 3 && i <= 5) CenterViewV(view, b, -26.75);
    else if (i >= 6 && i <= 8) CenterViewV(view, b, 27.25);

  }

  return view;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////


/// textFieldShouldBeginEditing:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return [self isEditing]; }

/// textFieldDidBeginEditing:
/// @param textField description
- (void)textFieldDidBeginEditing:(UITextField *)textField {

  [textField selectAll:nil];

  if (self.pickerView) [self showPickerView];

}

/// textFieldDidEndEditing:
/// @param textField description
- (void)textFieldDidEndEditing:(UITextField *)textField {

  if (self.changeHandler) self.changeHandler(self);

  if (self.pickerView) [self hidePickerView];

}

/// textFieldShouldEndEditing:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  return (self.validationHandler ? self.validationHandler(self) : YES);
}

/// textFieldShouldReturn:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return NO; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Text view delegate
////////////////////////////////////////////////////////////////////////////////


/// textViewDidBeginEditing:
/// @param textView description
- (void)textViewDidBeginEditing:(UITextView *)textView { self.textViewBeginState = [textView.text copy]; }

/// textViewDidEndEditing:
/// @param textView description
- (void)textViewDidEndEditing:(UITextView *)textView {
  if (self.changeHandler && ![textView.text isEqualToString:self.textViewBeginState])
    self.changeHandler(self);
}

/// textViewShouldBeginEditing:
/// @param textView description
/// @return BOOL
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView { return [self isEditing]; }

/// textViewShouldEndEditing:
/// @param textView description
/// @return BOOL
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  return (self.validationHandler ? self.validationHandler(self) : YES);
}

/// textView:shouldChangeTextInRange:replacementText:
/// @param textView description
/// @param range description
/// @param text description
/// @return BOOL
- (BOOL)         textView:(UITextView *)textView
  shouldChangeTextInRange:(NSRange)range
          replacementText:(NSString *)text
{
  if (!self.allowReturnsInTextView && text.length && [text[0] isEqual:@('\n')]) {
    [textView resignFirstResponder];
    return NO;
  } else return YES;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Picker view management
////////////////////////////////////////////////////////////////////////////////


/// showPickerView
- (void)showPickerView {

  if (self.pickerData) {

    if (self.pickerSelection) {
      NSUInteger idx = [self.pickerData indexOfObject:self.pickerSelection];
      if (idx != NSNotFound) [self.pickerView selectRow:idx inComponent:0 animated:NO];
    }

    self.pickerView.hidden = NO;
    self.expanded = YES;

    if (self.pickerDisplayCallback) self.pickerDisplayCallback(self, NO);
  }

}

/// hidePickerView
- (void)hidePickerView {

  if (!self.pickerView.hidden) {
    self.pickerView.hidden = YES;
    self.expanded = NO;
    if (self.pickerDisplayCallback) self.pickerDisplayCallback(self, YES);
  }

}

/// Picker view delegate
////////////////////////////////////////////////////////////////////////////////

/// pickerView:didSelectRow:inComponent:
/// @param pickerView description
/// @param row description
/// @param component description
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  if (self.pickerSelectionHandler) self.pickerSelectionHandler(self, row);

  self.info = self.pickerData[row];

  [self hidePickerView];

}

/// Picker view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfComponentsInPickerView:
/// @param pickerView description
/// @return NSInteger
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

/// pickerView:numberOfRowsInComponent:
/// @param pickerView description
/// @param component description
/// @return NSInteger
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return [self.pickerData count];
}

/// pickerView:titleForRow:forComponent:
/// @param pickerView description
/// @param row description
/// @param component description
/// @return NSString *
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  NSString * title = nil;

  id value = self.pickerData[row];
  if (isStringKind(value)) title = value;
  else if ([value respondsToSelector:@selector(name)])
    title = [value valueForKey:@"name"];

  return title;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view management
////////////////////////////////////////////////////////////////////////////////


/// setAllowRowSelection:
/// @param allowRowSelection BOOL
- (void)setAllowRowSelection:(BOOL)allowRowSelection { self.table.allowsSelection = allowRowSelection; }


/// UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////



/// UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////


/// tableIdentifier
/// @return NSString *
- (NSString *)tableIdentifier {
  if (!_tableIdentifier) self.tableIdentifier = BankableDetailCellListStyleIdentifier;
  return _tableIdentifier;
}

/// setTableCell:
/// @param tableCell description
- (void)setTableCellIdentifier:(NSString *)tableIdentifier {

  _tableIdentifier = ([[self class] isValidIentifier:tableIdentifier]
                          ? [tableIdentifier copy]
                          : nil);
  if (_tableIdentifier && self.table)
    [self.table registerClass:[self class] forCellReuseIdentifier:_tableIdentifier];
}

/// numberOfSectionsInTableView:
/// @param tableView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

/// tableView:numberOfRowsInSection:
/// @param tableView description
/// @param section description
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.tableData count];
}

/// tableView:heightForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return CGFloat
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return BankableDetailDefaultRowHeight;
}


/// tableView:cellForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BankableDetailTableViewCell * cell =
  [tableView dequeueReusableCellWithIdentifier:(self.tableIdentifier ?: BankableDetailCellListStyleIdentifier)
                                  forIndexPath:indexPath];

  id value = self.tableData[indexPath.row];


  return cell;

}

@end
