//
// ButtonGroupView.m
// iPhonto
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ButtonGroupView.h"
#import "RemoteElementView_Private.h"
#import "ButtonView.h"
#import "Button.h"
#import "ButtonGroup.h"
#import "RockerButton.h"
#import "Painter.h"
#import "RemoteView.h"
#import "MSRemoteConstants.h"

// #define ADD_LAYER_BORDER

#define RESIZABLE                       YES
#define MOVEABLE                        YES
#define CORNER_RADII                    CGSizeMake(5.0f, 5.0f)
#define AUTO_REMOVE_FROM_SUPERVIEW      NO
#define UPDATE_FROM_MODEL_TRICKLES_DOWN NO
#define RESIZABLE_TRICKLES_DOWN         NO

MSKIT_STRING_CONST   kTuckButtonKey = @"kTuckButtonKey";
static int         ddLogLevel     = DefaultDDLogLevel;

// static int ddLogLevel = LOG_LEVEL_DEBUG;

@implementation ButtonGroupView {
    UILabel * _buttonGroupLabel;
    @protected

        struct {
        BOOL   isTucked;
        BOOL   locatedAtTop;
        BOOL   buttonsEnabled;
        BOOL   buttonsLocked;
    }
    _bgvflags;
}

- (void)updateConstraints {

    MSKIT_STATIC_STRING_CONST kButtonGroupViewInternalNametag = @"ButtonGroupViewInternal";
    MSKIT_STATIC_STRING_CONST kButtonGroupViewLabelNametag = @"ButtonGroupViewLabel";

    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:kButtonGroupViewInternalNametag])
    {
        NSString * constraints =
        $(@"'%1$@' _buttonGroupLabel.width = self.width\n"
          "'%1$@' _buttonGroupLabel.height = self.height\n"
          "'%1$@' _buttonGroupLabel.centerX = self.centerX\n"
          "'%1$@' _buttonGroupLabel.centerY = self.centerY",
          $(@"%@-%@", kButtonGroupViewInternalNametag, kButtonGroupViewLabelNametag));

        [self addConstraints:
         [NSLayoutConstraint
          constraintsByParsingString:constraints
          views:NSDictionaryOfVariableBindings(self, _buttonGroupLabel)]];
    }

}
- (CGSize)intrinsicContentSize {
    switch ((uint64_t)self.type) {
        case ButtonGroupTypeToolbar :

            return CGSizeMake(MainScreen.bounds.size.width, 44.0);

        default :

            return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize   minimumSize    = [self minimumSize];
    CGSize   childUnionSize = [UIView unionFrameForViews:self.subelementViews].size;
    CGSize   fittedSize     = CGSizeMake(MAX(minimumSize.width, childUnionSize.width), MAX(minimumSize.height, childUnionSize.height));

    // TODO: Check against parent bounds to contain new size
    return fittedSize;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

- (BOOL)buttonsEnabled {
    return _bgvflags.buttonsEnabled;
}

- (void)setButtonsEnabled:(BOOL)buttonsEnabled {
    _bgvflags.buttonsEnabled                = buttonsEnabled;
    self.contentInteractionEnabled = _bgvflags.buttonsEnabled;

// DDLogDebug(@"%@\n\t%@abling buttons...contextView.userInteractionEnabled? %@",
// ClassTagSelectorStringForInstance(self.displayName),
// buttonsEnabled ? @"en" : @"dis",
// BOOLString(self.contentView.userInteractionEnabled));
}

- (void)setButtonsLocked:(BOOL)buttonsLocked {
    [self.subelementViews setValue:@(!buttonsLocked) forKey:@"moveable"];
    [self.subelementViews setValue:@(!buttonsLocked) forKey:@"resizable"];
    _bgvflags.buttonsLocked = buttonsLocked;
}

- (BOOL)buttonsLocked {
    return _bgvflags.buttonsLocked;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Actions
////////////////////////////////////////////////////////////////////////////////

- (void)buttonViewDidExecute:(ButtonView *)buttonView {
    if (self.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)tuckAction:(id)sender {
    if (self.parentElementView) [(RemoteView *)self.parentElementView tuckRequestFromButtonGroupView : self];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementView Overrides
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)kvoRegistration {
    __strong NSDictionary * kvoRegistration = @{
                                           @"labelText" : ^(MSKVOReceptionist * receptionist,
                                                             NSString * keyPath,
                                                             id object,
                                                             NSDictionary * change,
                                                             void * context)
        {
            id newValue = change[NSKeyValueChangeNewKey];
            _buttonGroupLabel.text = (ValueIsNotNil(newValue) ? (NSString *)newValue : nil);
        },
                                           @"labelCenter" : ^(MSKVOReceptionist * receptionist,
                                                               NSString * keyPath,
                                                               id object,
                                                               NSDictionary * change,
                                                               void * context)
        {},
                                           @"labelTextColor" : ^(MSKVOReceptionist * receptionist,
                                                                  NSString * keyPath,
                                                                  id object,
                                                                  NSDictionary * change,
                                                                  void * context)
        {
            id newValue = change[NSKeyValueChangeNewKey];
            _buttonGroupLabel.textColor = (ValueIsNotNil(newValue) ? (UIColor *)newValue : nil);
        },
                                           @"labelTextAlignment" : ^(MSKVOReceptionist * receptionist,
                                                                      NSString * keyPath,
                                                                      id object,
                                                                      NSDictionary * change,
                                                                      void * context)
        {
            id newValue = change[NSKeyValueChangeNewKey];
            _buttonGroupLabel.textAlignment = (ValueIsNotNil(newValue)
                                               ?[(NSNumber *)newValue unsignedIntegerValue]
                                               : NSTextAlignmentCenter);
        }
                                         };

    return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}

- (void)initializeIVARs {
    [super initializeIVARs];

    self.shrinkwrap      = YES;
    self.resizable       = RESIZABLE;
    self.moveable        = MOVEABLE;
    self.cornerRadii         = CORNER_RADII;

    if (self.type == ButtonGroupTypeToolbar) {
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
}

- (void)addSubelementView:(ButtonView *)view {
    _bgvflags.buttonsLocked = (  _bgvflags.buttonsLocked
                              && !view.resizable
                              && !view.moveable);
    if ([view.key isEqualToString:kTuckButtonKey]) {
        __weak ButtonGroupView * weakSelf = self;
        __weak ButtonView      * weakView = view;

        [view setActionHandler:^{[weakSelf tuckAction:weakView]; }

                     forAction:ButtonViewSingleTapAction];
    }

    [super addSubelementView:view];
}

// - (ButtonView *)objectAtIndexedSubscript:(NSUInteger)idx
// {
// return (ButtonView *)[super objectAtIndexedSubscript:idx];
// }

- (void)addInternalSubviews {
    [super addInternalSubviews];

    _buttonGroupLabel                                           = [[UILabel alloc] init];
    _buttonGroupLabel.backgroundColor                           = ClearColor;
    _buttonGroupLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addViewToContent:_buttonGroupLabel];

}

- (void)setEditingMode:(EditingMode)mode {
    [super setEditingMode:mode];

    self.resizable = (self.editingMode == EditingModeEditingNone) ? YES : NO;
    self.moveable  = (self.editingMode == EditingModeEditingNone) ? YES : NO;

    if (self.editingMode == EditingModeEditingRemote) self.buttonsEnabled = NO;
    else if (self.editingMode == EditingModeEditingButtonGroup) self.buttonsEnabled = YES;

    [self.subelementViews setValue:@(mode) forKeyPath:@"editingMode"];
}

- (void)setResizable:(BOOL)resizable {
    [super setResizable:resizable];

    if (RESIZABLE_TRICKLES_DOWN)
        for (ButtonView * buttonView in self.subelementViews) {
            buttonView.resizable = resizable;
        }
}

- (void)setMoveable:(BOOL)moveable {
    [super setMoveable:moveable];
}

@end

@implementation RoundedPanelButtonGroupView {}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ￼ButtonGroupView Overrides
////////////////////////////////////////////////////////////////////////////////

/**
 * Overridden to prevent setting a background color
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor
{}

- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    ButtonGroupSubtype   panelLocation = self.panelLocation;

    CGContextClearRect(ctx, self.bounds);

    NSUInteger   roundedCorners = (panelLocation == ButtonGroupPanelLocationRight
                                   ? UIRectCornerTopLeft | UIRectCornerBottomLeft
                                   : (panelLocation == ButtonGroupPanelLocationLeft
                                      ? UIRectCornerTopRight | UIRectCornerBottomRight
                                      : 0)
                                   );
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                      byRoundingCorners:roundedCorners
                                                            cornerRadii:CGSizeMake(15, 15)];

    self.borderPath = bezierPath;

    [defaultBGColor() setFill];

    [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:0.9];

    CGRect    insetRect = CGRectInset(self.bounds, 0, 3);
    CGFloat   tx        = (panelLocation == ButtonGroupPanelLocationRight ? 3 : -3);

    insetRect = CGRectApplyAffineTransform(insetRect, CGAffineTransformMakeTranslation(tx, 0));

    bezierPath = [UIBezierPath bezierPathWithRoundedRect:insetRect
                                       byRoundingCorners:roundedCorners
                                             cornerRadii:CGSizeMake(12, 12)];
    bezierPath.lineWidth = 2.0;
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
}

@end

#import "ConfigurationDelegate.h"
#import "ControlStateSet.h"

@implementation SelectionPanelButtonGroupView {
    /**
     * Tracks the currently selected button for the view. The currently selected button represents
     * the current configuration via its `key` value. The setter for this property ensures that
     * only one of the view's buttons can be selected at any given time.
     */
    __weak ButtonView * _selectedButton;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView overrides
////////////////////////////////////////////////////////////////////////////////
- (void)initializeIVARs {
    [super initializeIVARs];
    self.autohide = YES;
}

- (void)addSubelementView:(ButtonView *)view {
    [super addSubelementView:view];

    __weak SelectionPanelButtonGroupView * weakSelf = self;
    __weak ButtonView                    * weakView = view;

    [view setActionHandler:^{[weakSelf handleSelection:weakView]; }

                 forAction:ButtonViewSingleTapAction];
    if (!_selectedButton && [kDefaultConfiguration isEqualToString:view.key]) {
        self.selectedButton = view;
        [self postNotificationOfNewConfiguration:kDefaultConfiguration];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selection Handling
////////////////////////////////////////////////////////////////////////////////

- (void)setSelectedButton:(ButtonView *)newSelection {
    if (_selectedButton != newSelection) {
        if (_selectedButton) ((Button *)_selectedButton.remoteElement).selected = NO;

        _selectedButton                                    = newSelection;
        ((Button *)_selectedButton.remoteElement).selected = YES;
    }
}

/**
 * Button action attached to the view's button's as they are added as subviews. This method
 * updates the value of `selectedButton` with the `ButtonView` that invoked the method.
 * @param sender The `ButtonView` that has been touched.
 */
- (void)handleSelection:(ButtonView *)sender {
    if (_selectedButton == sender) {
        DDLogDebug(@"%@\n\tsender(%@) is already selected",
                   ClassTagString, sender.key);

        return;
    }

    self.selectedButton = sender;
        DDLogDebug(@"%@\n\tselected button with key '%@'",
               ClassTagString, _selectedButton.key);

        assert(StringIsNotEmpty(_selectedButton.key));
    [self postNotificationOfNewConfiguration:_selectedButton.key];

    if (self.autohide) [self performSelector:@selector(tuckAction:) withObject:nil afterDelay:1.0];
}

/**
 * Uses the default notification center to post a new `kCurrentConfigurationDidChangeNotification`
 * containing a dictionary entry with the new configuration value under `kConfigurationKey`.
 */
- (void)postNotificationOfNewConfiguration:(NSString *)configuration {
        assert([_selectedButton.key isEqualToString:configuration]);
    [NotificationCenter postNotificationName:kCurrentConfigurationDidChangeNotification
                                      object:self
                                    userInfo:@{kConfigurationKey : configuration}
    ];
}

@end

#import "CommandSet.h"
#import "CommandSetCollection.h"

#define kLabelPadding    10
#define kDefaultDuration 0.5
#define kLabelDivider    @"  "

enum {
    kLabelsIndex,
    kCommandSetsIndex

};

@implementation PickerLabelButtonGroupView {
    struct {
        BOOL         blockPan;
        CGFloat      panLength;
        NSUInteger   labelIndex;
        NSUInteger   labelCount;
        CGFloat      prevPanAmount;
    }
    _pickerFlags;

    NSLayoutConstraint     * _labelContainerLeftConstraint;
    UIView                 * _labelContainer;
    UIPanGestureRecognizer * _labelPanGesture;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView Overrides
////////////////////////////////////////////////////////////////////////////////

MSKIT_STATIC_STRING_CONST
kPickerLabelButtonGroupViewInternalNametag = @"PickerLabelButtonGroupViewInternal";

MSKIT_STATIC_STRING_CONST
kPickerLabelButtonGroupViewLabelContainer = @"PickerLabelButtonGroupViewLabelContainer";

- (void)updateConstraints {

    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:kPickerLabelButtonGroupViewInternalNametag]) {

        NSString * constraints =
            $(@"'%1$@' _labelContainer.centerY = self.centerY\n"
              "'%1$@' _labelContainer.height = self.height * 0.34\n"
              "'%1$@-left' _labelContainer.left = self.left",
              $(@"%@-%@",
              kPickerLabelButtonGroupViewInternalNametag,
              kPickerLabelButtonGroupViewLabelContainer));

        [self addConstraints:[NSLayoutConstraint
                              constraintsByParsingString:constraints
                              views:NSDictionaryOfVariableBindings(_labelContainer, self)]];

        _labelContainerLeftConstraint =
            [self constraintWithNametag:$(@"%@-%@-left",
                                          kPickerLabelButtonGroupViewInternalNametag,
                                          kPickerLabelButtonGroupViewLabelContainer)];

        if (![_labelContainer constraintsWithNametagPrefix:kPickerLabelButtonGroupViewInternalNametag])
            [self buildLabels];
    }

}

- (void)addSubelementView:(ButtonView *)view {
    [super addSubelementView:view];
    [view.gestureRecognizers
     makeObjectsPerformSelector:@selector(requireGestureRecognizerToFail:)
                     withObject:_labelPanGesture];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroupView Overrides
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)kvoRegistration {
    __weak PickerLabelButtonGroupView * weakSelf = self;

    return [[super kvoRegistration]
            dictionaryByAddingEntriesFromDictionary:
            @{
              @"labels" : ^(MSKVOReceptionist * receptionist,
                             NSString * keyPath,
                             id object,
                             NSDictionary * change,
                             void * context)
            {
                [weakSelf buildLabels];
            },
              @"commandSets" : ^(MSKVOReceptionist * receptionist,
                                  NSString * keyPath,
                                  id object,
                                  NSDictionary * change,
                                  void * context)
            {
                [weakSelf updateCommandSet];
            }
            }];
}

- (void)initializeIVARs {
    [super initializeIVARs];
    [self updateCommandSet];
}

- (void)addInternalSubviews {
    [super addInternalSubviews];

    _labelContainer                                           = [[UIView alloc] init];
    _labelContainer.backgroundColor                           = ClearColor;
    self.overlayClipsToBounds                                 = YES;
    _labelContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addViewToOverlay:_labelContainer];

}

- (void)attachGestureRecognizers {
    [super attachGestureRecognizers];

    _labelPanGesture = [[UIPanGestureRecognizer alloc]
                        initWithTarget:self
                                action:@selector(handlePan:)];
    _labelPanGesture.maximumNumberOfTouches = 1;

    [self addGestureRecognizer:_labelPanGesture];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Label Management
////////////////////////////////////////////////////////////////////////////////

/**
 * This method animates the label "paged" to via the panning gesture and calls `updateCommandSet`
 * upon completion.
 * @param index The label index for the destination label.
 * @param duration The time in seconds it should take the animation to complete.
 */
- (void)animateLabelContainerToIndex:(NSUInteger)index withDuration:(CGFloat)duration {
    CGFloat   labelWidth = self.bounds.size.width;

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _labelContainerLeftConstraint.constant = 0 - labelWidth * index;
                         [self setNeedsLayout];
                     }

                     completion:^(BOOL finished) {[self updateCommandSet]; }

    ];
}

/**
 * Generate `UILabels` for each label in the model's set and attach to `scrollingLabels`. Any
 * labels attached already to the `scrollingLabels` are removed first.
 */
- (void)buildLabels {
        assert(_labelContainer.subviews.count == 0);

    NSOrderedSet * labelSet = ((PickerLabelButtonGroup *)self.remoteElement).commandSetLabels;

    _pickerFlags.labelCount = [labelSet count];

    NSMutableString     * s     = [NSMutableString stringWithString:@"H:|"];
    NSMutableDictionary * views = [NSMutableDictionary dictionaryWithCapacity:labelSet.count];

    // TODO: move constraint building to `updateConstraints`

    for (NSAttributedString * label in labelSet) {
        assert([label isKindOfClass:[NSAttributedString class]]);

        UILabel * newLabel = [[UILabel alloc] init];

        newLabel.translatesAutoresizingMaskIntoConstraints = NO;
        newLabel.attributedText                            = label;
        newLabel.backgroundColor                           = [UIColor clearColor];
        [_labelContainer addSubview:newLabel];
        views[label.string] = newLabel;
        NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:newLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
        constraint.nametag = kPickerLabelButtonGroupViewInternalNametag;

        [self addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:newLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_labelContainer
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0];
        constraint.nametag = kPickerLabelButtonGroupViewInternalNametag;

        [_labelContainer addConstraint:constraint];
        [s appendFormat:@"[%@]", label.string];
    }

    [s appendString:@"|"];
    NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:s options:0 metrics:nil views:views];
    [constraints setValue:kPickerLabelButtonGroupViewInternalNametag forKeyPath:@"nametag"];
    [_labelContainer addConstraints:constraints];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

/**
 * Handler for pan gesture attached to `labelContainer` that behaves similar to a scroll view for
 * selecting among the labels attached.
 * @param gestureRecognizer The gesture that responded to a pan event in the view.
 */
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan :
            _pickerFlags.blockPan      = NO;
            _pickerFlags.panLength     = 0;
            _pickerFlags.prevPanAmount = 0;
            break;

        case UIGestureRecognizerStateChanged : {
            if (_pickerFlags.blockPan) break;

            CGFloat   velocity = fabs([gestureRecognizer velocityInView:self].x);
            CGFloat   duration = kDefaultDuration;

            while (duration > 0.1 && velocity > 1) {
                velocity /= 3.0;
                if (velocity > 1) duration -= 0.1;
            }

            CGFloat   labelWidth = self.bounds.size.width;
            CGFloat   panAmount  = [gestureRecognizer translationInView:self].x;

            _pickerFlags.panLength += fabs(panAmount);

            // Check if pan has moved out of label index range
            if (  _pickerFlags.prevPanAmount != 0
               && (  (panAmount < 0 && panAmount > _pickerFlags.prevPanAmount)
                  || (panAmount > 0 && panAmount < _pickerFlags.prevPanAmount)))
            {
                _pickerFlags.blockPan = YES;

                if (_pickerFlags.prevPanAmount > 0) _pickerFlags.labelIndex = MAX(_pickerFlags.labelIndex - 1, 0);
                else _pickerFlags.labelIndex = MIN(_pickerFlags.labelIndex + 1, _pickerFlags.labelCount - 1);

                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];

                break;
            }

            // Check if pan has moved out of the button group bounds
            if (_pickerFlags.panLength >= labelWidth) {
                _pickerFlags.blockPan = YES;
                if (panAmount > 0) _pickerFlags.labelIndex--;
                else _pickerFlags.labelIndex++;

                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];
                break;
            }

            // Check that pan leaves at least one full label within button group bounds
            CGFloat   currentOffset  = _labelContainerLeftConstraint.constant;
            CGFloat   newOffset      = currentOffset + panAmount;
            CGFloat   containerWidth = _labelContainer.bounds.size.width;
            CGFloat   minOffset      = -containerWidth + labelWidth;

            if (newOffset < minOffset) {
                _pickerFlags.blockPan   = YES;
                _pickerFlags.labelIndex = _pickerFlags.labelCount - 1;
                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];
            } else if (newOffset > 0) {
                _pickerFlags.blockPan   = YES;
                _pickerFlags.labelIndex = 0;
                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];
            } else {
                _pickerFlags.prevPanAmount = panAmount;
                [UIView animateWithDuration:0
                                 animations:^{
                                     _labelContainerLeftConstraint.constant = newOffset;
                                     [self setNeedsLayout];
                                 }

                ];
            }
        }
        break;

        case UIGestureRecognizerStateEnded :
            [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:kDefaultDuration];
            break;

        case UIGestureRecognizerStateCancelled :
        case UIGestureRecognizerStateFailed :
        case UIGestureRecognizerStatePossible :
            break;
    } /* switch */
}     /* handlePan */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * Updates button commands with values from the currently selected command set.
 */
- (void)updateCommandSet {
    NSURL * uri = [((PickerLabelButtonGroup *)self.remoteElement).commandSets
objectAtIndex: _pickerFlags.labelIndex];
    NSManagedObjectID * objectID = [[self.remoteElement.managedObjectContext
                                     persistentStoreCoordinator]
                                    managedObjectIDForURIRepresentation:uri];

    if (objectID) {
        CommandSet * commandSet = (CommandSet *)[self.remoteElement.managedObjectContext
                                                 objectWithID:objectID];

        if (commandSet)
            for (Button * button in self.subelements) {
                if ([commandSet isValidKey:button.key]) button.command = [commandSet commandForKey:button.key];
            }
    }
}

@end
