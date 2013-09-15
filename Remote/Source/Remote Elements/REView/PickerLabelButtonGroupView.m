//
// PickerLabelButtonGroupView.m
// Remote
//
// Created by Jason Cardwell on 3/20/13.
// Copyright 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"

static int   ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

MSKIT_NAMETAG_DEFINITION(REPickerLabelButtonGroupViewInternal);
MSKIT_NAMETAG_DEFINITION(REPickerLabelButtonGroupViewLabelContainer);

@implementation PickerLabelButtonGroupView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView Overrides

////////////////////////////////////////////////////////////////////////////////

- (void)updateConstraints
{

    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:REPickerLabelButtonGroupViewInternalNametag])
    {

        NSString * constraints =
        $(@"'%1$@' _labelContainer.centerY = self.centerY\n"
          "'%1$@' _labelContainer.height = self.height * 0.34\n"
          "'%1$@-left' _labelContainer.left = self.left",
          $(@"%@-%@",
            REPickerLabelButtonGroupViewInternalNametag,
            REPickerLabelButtonGroupViewLabelContainerNametag));

        [self addConstraints:[NSLayoutConstraint
                              constraintsByParsingString:constraints
                              views:NSDictionaryOfVariableBindings(_labelContainer,
                                                                   self)]];

        _labelContainerLeftConstraint =
        [self constraintWithNametag:$(@"%@-%@-left",
                                      REPickerLabelButtonGroupViewInternalNametag,
                                      REPickerLabelButtonGroupViewLabelContainerNametag)];

        if (![_labelContainer constraintsWithNametagPrefix:REPickerLabelButtonGroupViewInternalNametag])
            [self buildLabels];
    }

}

- (void)addSubelementView:(ButtonView *)view
{
    [super addSubelementView:view];
    [view.gestureRecognizers
     makeObjectsPerformSelector:@selector(requireGestureRecognizerToFail:)
     withObject:_labelPanGesture];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroupView Overrides
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)kvoRegistration
{
    return [[super kvoRegistration]
            dictionaryByAddingEntriesFromDictionary:
            @{@"labels" : MSMakeKVOHandler({[(__bridge PickerLabelButtonGroupView *)context
                                             buildLabels];}),
              @"commandSets" : MSMakeKVOHandler({[(__bridge PickerLabelButtonGroupView *)context
                                                  updateCommandSet];})}];
}

- (void)initializeIVARs
{
    [super initializeIVARs];
    [self updateCommandSet];
}

- (void)addInternalSubviews
{
    [super addInternalSubviews];

    _labelContainer = [UIView newForAutolayout];
    _labelContainer.backgroundColor = ClearColor;
    self.overlayClipsToBounds       = YES;
    [self addViewToOverlay:_labelContainer];

}

- (void)attachGestureRecognizers
{
    [super attachGestureRecognizers];

    _labelPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
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
- (void)animateLabelContainerToIndex:(NSUInteger)index withDuration:(CGFloat)duration
{
    CGFloat   labelWidth = self.bounds.size.width;

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(  UIViewAnimationOptionBeginFromCurrentState
                                 | UIViewAnimationOptionOverrideInheritedDuration
                                 | UIViewAnimationOptionCurveEaseOut)
                     animations:^{ _labelContainerLeftConstraint.constant = 0 - labelWidth * index;
                         [self setNeedsLayout]; }
                     completion:^(BOOL finished){ [self updateCommandSet]; }];
}

/**
 * Generate `UILabels` for each label in the model's set and attach to `scrollingLabels`. Any
 * labels attached already to the `scrollingLabels` are removed first.
 */
- (void)buildLabels
{
    assert(_labelContainer.subviews.count == 0);

    CommandSetCollection * collection = ((PickerLabelButtonGroup*)self.model).commandSetCollection;

    NSMutableArray * labels = [@[] mutableCopy];
    for (CommandSet * commandSet in collection.commandSets)
        [labels addObject:collection[commandSet]];

    _pickerFlags.labelCount = [labels count];

    NSMutableString     * s     = [NSMutableString stringWithString:@"H:|"];
    NSMutableDictionary * views = [NSMutableDictionary dictionaryWithCapacity:labels.count];

    // TODO: move constraint building to `updateConstraints`

    for (NSAttributedString * label in labels)
    {
        assert([label isKindOfClass:[NSAttributedString class]]);

        UILabel * newLabel = [UILabel new];

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

        constraint.nametag = REPickerLabelButtonGroupViewInternalNametag;

        [self addConstraint:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:newLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_labelContainer
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0];
        constraint.nametag = REPickerLabelButtonGroupViewInternalNametag;

        [_labelContainer addConstraint:constraint];
        [s appendFormat:@"[%@]", label.string];
    }

    [s appendString:@"|"];

    NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:s
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views];

    [constraints setValue:REPickerLabelButtonGroupViewInternalNametag forKeyPath:@"nametag"];
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
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            _pickerFlags.blockPan      = NO;
            _pickerFlags.panLength     = 0;
            _pickerFlags.prevPanAmount = 0;
            break;

        case UIGestureRecognizerStateChanged:
        {
            if (_pickerFlags.blockPan) break;

            CGFloat   velocity = fabs([gestureRecognizer velocityInView:self].x);
            CGFloat   duration = 0.5;

            while (duration > 0.1 && velocity > 1)
            {
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

                if (_pickerFlags.prevPanAmount > 0)
                    _pickerFlags.labelIndex = MAX(_pickerFlags.labelIndex - 1, 0);

                else
                    _pickerFlags.labelIndex = MIN(_pickerFlags.labelIndex + 1,
                                                  _pickerFlags.labelCount - 1);

                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];

                break;
            }

            // Check if pan has moved out of the button group bounds
            if (_pickerFlags.panLength >= labelWidth)
            {
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

            if (newOffset < minOffset)
            {
                _pickerFlags.blockPan   = YES;
                _pickerFlags.labelIndex = _pickerFlags.labelCount - 1;
                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];
            }
            else if (newOffset > 0)
            {
                _pickerFlags.blockPan   = YES;
                _pickerFlags.labelIndex = 0;
                [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:duration];
            }
            else
            {
                _pickerFlags.prevPanAmount = panAmount;
                [UIView animateWithDuration:0
                                 animations:^{ _labelContainerLeftConstraint.constant = newOffset;
                                     [self setNeedsLayout]; }];
            }
        }
            break;

        case UIGestureRecognizerStateEnded:
            [self animateLabelContainerToIndex:_pickerFlags.labelIndex withDuration:0.5];
            break;

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * Updates button commands with values from the currently selected command set.
 */
- (void)updateCommandSet
{
    if (!_pickerFlags.labelCount) return;

    CommandSetCollection * collection = ((PickerLabelButtonGroup *)self.model).commandSetCollection;
    NSOrderedSet           * commandSets = collection.commandSets;
    assert(commandSets.count >= _pickerFlags.labelCount);
    CommandSet * commandSet = commandSets[_pickerFlags.labelIndex];
    assert(commandSet);

    for (Button * button in self.subelements) button.command = commandSet[@(button.type)];
}

@end
