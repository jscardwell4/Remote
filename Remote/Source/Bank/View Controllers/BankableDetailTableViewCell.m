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

const CGFloat BankableDetailCellPickerHeight = 162.0;


@interface BankableDetailTableViewCell () <UITextFieldDelegate, UITextViewDelegate, UITextViewDelegate,
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

@property (nonatomic, weak) NSLayoutConstraint * contentBottomConstraint;

@property (nonatomic, copy) NSString * beginStateText;

@end

static NSString *(^textFromObject)(id) = ^(id obj) {

  NSString * text = nil;

  if (isStringKind(obj)) text = obj;

  else if (isNumberKind(obj)) text = [obj stringValue];

  else if ([obj respondsToSelector:@selector(name)]) text = [obj name];

  return text;

};


@implementation BankableDetailTableViewCell {
  NSString * _tableIdentifier;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reuse identifiers
////////////////////////////////////////////////////////////////////////////////


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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializer and reuse preparation
////////////////////////////////////////////////////////////////////////////////


/// initWithStyle:reuseIdentifier:
/// @param style description
/// @param reuseIdentifier description
/// @return instancetype
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  static NSDictionary const * index = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{

    /// Create some more or less generic constraint strings for use in decorator blocks
    ////////////////////////////////////////////////////////////////////////////////

    NSString * nameAndInfoCenterYConstraints  = [@"\n" join:@[@"|-20-[name]-8-[info]-20-|",
                                                              @"name.centerY = info.centerY",
                                                              @"name.height = info.height",
                                                              @"V:|-2-[name]"]];

    NSString * infoConstraints                = [@"\n" join:@[@"|-20-[info]-20-|", @"V:|-8-[info]"]];

    NSString * infoDisclosureConstraints      = [@"\n" join:@[@"|-20-[info]-75-|", @"V:|-8-[info]"]];

    NSString * nameAndTextViewInfoConstraints = [@"\n" join:@[@"V:|-5-[name]-5-[info]-5-|",
                                                              @"|-20-[name]",
                                                              @"|-20-[info]-20-|"]];

    NSString * tableViewInfoConstraints       = [@"\n" join:@[@"|[info]|", @"V:|[info]|"]];

    NSString * nameInfoAndStepperConstraints  = [@"\n" join:@[@"|-20-[name]-8-[info]",
                                                              @"'info trailing' info.trailing = stepper.leading - 20",
                                                              @"name.centerY = info.centerY",
                                                              @"name.height = info.height",
                                                              @"'stepper leading' stepper.leading = content.trailing",
                                                              @"stepper.centerY = name.centerY",
                                                              @"V:|-8-[name]"]];

    NSString * imageViewInfoConstraints       = [@"\n" join:@[@"|[info]|", @"V:|[info]|"]];


    /// Create the fonts to use in decorator blocks
    ////////////////////////////////////////////////////////////////////////////////

    UIFont  * nameFont  = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIFont  * infoFont  = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    /// Create the colors to use in decorator blocks
    ////////////////////////////////////////////////////////////////////////////////

    UIColor * nameColor = [UIColor colorWithR: 59.0f G: 60.0f B: 64.0f A:255.0f];
    UIColor * infoColor = [UIColor colorWithR:159.0f G:160.0f B:164.0f A:255.0f];

    /// Create some generic blocks to add name and info views
    ////////////////////////////////////////////////////////////////////////////////

    UILabel * (^addName)(UILabel *, BankableDetailTableViewCell *) =
    ^(UILabel * name, BankableDetailTableViewCell * cell) {

      name.translatesAutoresizingMaskIntoConstraints = NO;
      [name setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
      name.font      = nameFont;
      name.textColor = nameColor;
      [cell.contentView addSubview:name];
      cell.nameLabel = name;

      return name;

    };

    id (^addInfo)(id, BankableDetailTableViewCell *) = ^(id info, BankableDetailTableViewCell * cell) {

      [info setTranslatesAutoresizingMaskIntoConstraints:NO];
      [cell.contentView addSubview:info];
      [info setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh
                                            forAxis:UILayoutConstraintAxisVertical];
      [info setUserInteractionEnabled:NO];

      if ([info isKindOfClass:[UILabel class]]) {
        UILabel * infoLabel = info;
        infoLabel.font          = infoFont;
        infoLabel.textColor     = infoColor;
        infoLabel.textAlignment = NSTextAlignmentRight;
        cell.infoLabel = infoLabel;
      }

      else if ([info isKindOfClass:[UIButton class]]) {
        UIButton * infoButton = info;
        infoButton.titleLabel.font          = infoFont;
        infoButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [infoButton addConstraints:
         [NSLayoutConstraint constraintsByParsingString:[@"\n" join:@[@"title.right = button.right",
                                                                      @"title.top = button.top",
                                                                      @"title.bottom = button.bottom",
                                                                      @"title.left = button.left"]]
                                                  views:@{@"title": infoButton.titleLabel,
                                                          @"button": infoButton}]];
        [infoButton setTitleColor:infoColor forState:UIControlStateNormal];
        [infoButton addTarget:cell
                       action:@selector(buttonUpAction:)
             forControlEvents:UIControlEventTouchUpInside];
        cell.infoButton = infoButton;
      }

      else if ([info isKindOfClass:[UITextField class]]) {
        UITextField * infoTextField = info;
        infoTextField.font          = infoFont;
        infoTextField.textColor     = infoColor;
        infoTextField.textAlignment = NSTextAlignmentRight;
        infoTextField.delegate      = cell;
        cell.infoTextField = infoTextField;
      }

      else if ([info isKindOfClass:[UITextView class]]) {
        UITextView * infoTextView = info;
        infoTextView.font      = infoFont;
        infoTextView.textColor = infoColor;
        infoTextView.delegate  = cell;
        cell.infoTextView = infoTextView;
      }

      else if ([info isKindOfClass:[UIImageView class]]) {
        UIImageView * infoImageView = info;
        infoImageView.contentMode = UIViewContentModeScaleAspectFit;
        infoImageView.clipsToBounds = YES;
        cell.infoImageView = infoImageView;
      }

      else if ([info isKindOfClass:[UITableView class]]) {
        UITableView * infoTableView = info;
        infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        infoTableView.rowHeight = 38.0;
        infoTableView.delegate = cell;
        infoTableView.dataSource = cell;
        if (cell.tableIdentifier)
          [infoTableView registerClass:[BankableDetailTableViewCell class]
                forCellReuseIdentifier:cell.tableIdentifier];
        cell.table = infoTableView;
      }

      else if ([info isKindOfClass:[UISwitch class]]) {
        UISwitch * infoSwitch = info;
        [infoSwitch addTarget:cell
                       action:@selector(switchValueDidChange:)
             forControlEvents:UIControlEventValueChanged];
        cell.infoSwitch = infoSwitch;
      }

      else if ([info isKindOfClass:[UIStepper class]]) {
        UIStepper * stepper = info;
        [stepper addTarget:cell
                    action:@selector(stepperValueDidChange:)
          forControlEvents:UIControlEventValueChanged];
        cell.stepper = stepper;
      }

      return info;

    };


    /// Create the decorator blocks keyed by the corresponding cell reuse identifier
    /// These blocks are responsible for selecting which views to create and for adding appropriate constraints
    ////////////////////////////////////////////////////////////////////////////////

    index = @{

              BankableDetailCellLabelStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * name = addName([UILabel new], cell);
                  UILabel * info = addInfo([UILabel new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameAndInfoCenterYConstraints
                                                            views:@{@"name"   : name,
                                                                    @"info"   : info,
                                                                    @"content": cell.contentView}]];

                },

              BankableDetailCellListStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel * info = addInfo([UILabel new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:infoConstraints
                                                            views:@{@"info": info}]];

                },

              BankableDetailCellButtonStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel  * name = addName([UILabel  new], cell);
                  UIButton * info = addInfo([UIButton new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameAndInfoCenterYConstraints
                                                            views:@{@"name"   : name,
                                                                    @"info"   : info,
                                                                    @"content": cell.contentView}]];

                },

              BankableDetailCellImageStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UIImageView * info = addInfo([[UIImageView alloc] initWithImage:nil], cell);

                  [cell.contentView addConstraints:
                        [NSLayoutConstraint constraintsByParsingString:imageViewInfoConstraints
                                                                 views:@{@"info": info,
                                                                         @"content": cell.contentView}]];

                },

              BankableDetailCellSwitchStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel  * name = addName([UILabel  new], cell);
                  UISwitch * info = addInfo([UISwitch new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameAndInfoCenterYConstraints
                                                            views:@{@"name": name, @"info": info}]];

                },

              BankableDetailCellStepperStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel   * name    = addName([UILabel   new], cell);
                  UILabel   * info    = addInfo([UILabel   new], cell);
                  UIStepper * stepper = addInfo([UIStepper new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameInfoAndStepperConstraints
                                                            views:@{@"name"   : name,
                                                                    @"info"   : info,
                                                                    @"stepper": stepper,
                                                                    @"content": cell.contentView}]];

                },

              BankableDetailCellDetailStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

                  UIButton * info = addInfo([UIButton new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:infoDisclosureConstraints
                                                            views:@{@"info": info}]];

                },

              BankableDetailCellTextViewStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel    * name = addName([UILabel    new], cell);
                  UITextView * info = addInfo([UITextView new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameAndTextViewInfoConstraints
                                                            views:@{@"name": name, @"info": info}]];

                },

              BankableDetailCellTextFieldStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UILabel     * name = addName([UILabel     new], cell);
                  UITextField * info = addInfo([UITextField new], cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:nameAndInfoCenterYConstraints
                                                            views:@{@"name"   : name,
                                                                    @"info"   : info,
                                                                    @"content": cell.contentView}]];

                },

              BankableDetailCellTableStyleIdentifier:
                ^(BankableDetailTableViewCell * cell) {

                  UITableView * info = addInfo([[UITableView alloc] initWithFrame:CGRectZero
                                                                            style:UITableViewStylePlain],
                                               cell);

                  [cell.contentView addConstraints:
                   [NSLayoutConstraint constraintsByParsingString:tableViewInfoConstraints
                                                            views:@{@"info": info}]];

                }

              };

  });


  /// Code to actually initialize the object
  ////////////////////////////////////////////////////////////////////////////////

  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.clipsToBounds = YES;
    self.clipsToBounds = YES;

    UIPickerView * picker = [UIPickerView newForAutolayout];
    picker.delegate   = self;
    picker.dataSource = self;
    picker.hidden     = YES;
    [self addSubview:picker];
    self.pickerView = picker;

    NSString * constraintsString = [@"\n" join:@[@"|[content]|",
                                                 @"V:|[content]|",
                                                 @"|[picker]|",
                                                 $(@"'picker height' picker.height = %f", BankableDetailCellPickerHeight),
                                                 @"picker.bottom = self.bottom"]];

    NSDictionary * views = @{@"self": self, @"picker": self.pickerView, @"content": self.contentView};

    NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:constraintsString
                                                                     views:views];

    [self addConstraints:constraints];

    void (^decorator)(BankableDetailTableViewCell *) = index[reuseIdentifier];
    if (decorator) decorator(self);

  }

  return self;

}

/// updateConstraints
- (void)updateConstraints {

  [super updateConstraints];

//  if (!self.contentBottomConstraint) {
//
//    NSString * constraintsString = [@"\n" join:@[@"content.left = self.left",
//                                                 @"content.right = self.right",
//                                                 @"content.top = self.top",
//                                                 @"'content bottom' content.bottom = self.bottom",
//                                                 @"picker.bottom = self.bottom",
//                                                 @"|[picker]|",
//                                                 $(@"picker.height = %f", BankableDetailCellPickerHeight)]];
//    NSDictionary * views = @{@"content": self.contentView, @"picker": self.pickerView, @"self": self};
//    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraintsString views:views]];
//    self.contentBottomConstraint = [self constraintWithNametag:@"content bottom"];
//
//  }


}


/// prepareForReuse
- (void)prepareForReuse {
  [super prepareForReuse];

  _nameLabel.text = nil;

  [_infoButton setTitle:nil forState:UIControlStateNormal];

  _infoImageView.image = nil;
  _infoImageView.contentMode = UIViewContentModeScaleAspectFit;

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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors
////////////////////////////////////////////////////////////////////////////////


/// name
/// @return NSString *
- (NSString *)name { return _nameLabel.text; }

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
                        CGSize boundsSize = cell.bounds.size;
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

/// setAllowRowSelection:
/// @param allowRowSelection BOOL
- (void)setAllowRowSelection:(BOOL)allowRowSelection { self.table.allowsSelection = allowRowSelection; }

/// setTableCell:
/// @param tableCell description
- (void)setTableIdentifier:(NSString *)tableIdentifier {
  _tableIdentifier = ([[self class] isValidIentifier:tableIdentifier] ? [tableIdentifier copy] : nil);
  if (_tableIdentifier && self.table) [self.table registerClass:[self class] forCellReuseIdentifier:_tableIdentifier];
}

/// tableIdentifier
/// @return NSString *
- (NSString *)tableIdentifier {
  if (!_tableIdentifier) self.tableIdentifier = BankableDetailCellListStyleIdentifier;
  return _tableIdentifier;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Control action callbacks
////////////////////////////////////////////////////////////////////////////////


/// stepperValueDidChange:
/// @param sender description
- (void)stepperValueDidChange:(UIStepper *)sender {
  if (self.changeHandler) self.changeHandler(self);
  self.infoLabel.text = [@(sender.value) stringValue];
}

/// buttonUpAction:
/// @param sender description
- (void)buttonUpAction:(UIButton *)sender {
  if (self.buttonActionHandler) self.buttonActionHandler(self);
  if (self.pickerData) {
    if (self.pickerView.hidden == YES) [self showPickerView];
    else                               [self hidePickerView];
  }
}

/// switchValueDidChange:
/// @param sender description
- (void)switchValueDidChange:(UISwitch *)sender { if (self.changeHandler) self.changeHandler(self); }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - State changes
////////////////////////////////////////////////////////////////////////////////


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
                      NSLayoutConstraint * infoTrailing  = [cell.contentView constraintWithNametag:@"info trailing"];
                      NSLayoutConstraint * stepperLeading = [cell.contentView constraintWithNametag:@"stepper leading"];
                      infoTrailing.constant  = (editing ? -8.0 : -20.0);
                      stepperLeading.constant = (editing ? -20.0 - cell.stepper.bounds.size.width : 0.0);
                      

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
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////


/// textFieldDidBeginEditing:
/// @param textField description
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.beginStateText = [textField.text copy];
  if (self.pickerData) [self showPickerView];
}

/// textFieldDidEndEditing:
/// @param textField description
- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (self.changeHandler && ![textField.text isEqualToString:self.beginStateText]) self.changeHandler(self);
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
//- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return NO; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate
////////////////////////////////////////////////////////////////////////////////


/// textViewDidBeginEditing:
/// @param textView description
- (void)textViewDidBeginEditing:(UITextView *)textView { self.beginStateText = [textView.text copy]; }

/// textViewDidEndEditing:
/// @param textView description
- (void)textViewDidEndEditing:(UITextView *)textView {
  if (self.changeHandler && ![textView.text isEqualToString:self.beginStateText]) self.changeHandler(self);
}

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
  return (!self.allowReturnsInTextView && [text containsString:@"\n"] && [textView resignFirstResponder] ? NO : YES);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Picker view management
////////////////////////////////////////////////////////////////////////////////


/// showPickerView
- (void)showPickerView {

  if (self.pickerData && (!self.shouldShowPicker || self.shouldShowPicker(self)) ) {
    if (self.pickerSelection) {
      NSUInteger idx = [self.pickerData indexOfObject:self.pickerSelection];
      if (idx != NSNotFound) [self.pickerView selectRow:idx inComponent:0 animated:NO];
    }
    self.pickerView.hidden = NO;
//    self.contentBottomConstraint.constant = -BankableDetailCellPickerHeight;
    if (self.didShowPicker) self.didShowPicker(self);
  }
}

/// hidePickerView
- (void)hidePickerView {
  if (!self.pickerView.hidden && (!self.shouldHidePicker || self.shouldHidePicker(self))) {
    self.pickerView.hidden = YES;
//    self.contentBottomConstraint.constant = 0.0;
    if (self.didHidePicker) self.didHidePicker(self);
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
  self.pickerSelection = self.pickerData[row];
  if (self.pickerSelectionHandler) self.pickerSelectionHandler(self);
  self.info = self.pickerSelection;
  if ([self.infoTextField isFirstResponder]) [self.infoTextField resignFirstResponder];
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
  return textFromObject(self.pickerData[row]);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////


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
