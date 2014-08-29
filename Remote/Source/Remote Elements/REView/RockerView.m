//
// RockerView.m
// Remote
//
// Created by Jason Cardwell on 3/20/13.
// Copyright 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "ButtonGroup.h"
#import "CommandSetCollection.h"
#import "CommandContainer.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)


@interface RockerView ()

@property (nonatomic, assign) BOOL                   blockPan;
@property (nonatomic, assign) CGFloat                panLength;
@property (nonatomic, assign) NSUInteger             labelIndex;
@property (nonatomic, assign) NSUInteger             labelCount;
@property (nonatomic, assign) CGFloat                prevPanAmount;
@property (nonatomic, weak) NSLayoutConstraint     * labelContainerLeftConstraint;
@property (nonatomic, weak) UIView                 * labelContainer;
@property (nonatomic, weak) UIPanGestureRecognizer * labelPanGesture;
@end

@implementation RockerView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)updateConstraints {

  [super updateConstraints];

  NSString * nametag = ClassNametagWithSuffix(@"Internal-LabelContainer");

  if (self.labelContainer) {
    if (![self constraintsWithNametagPrefix:nametag]) {

      NSString * constraints =
        $(@"'%1$@' labels.centerY = self.centerY\n"
          "'%1$@' labels.height = self.height * 0.34\n"
          "'%1$@-left' labels.left = self.left", nametag);

      [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                    views:@{@"self": self,
                                                                            @"labels": self.labelContainer}]];

      self.labelContainerLeftConstraint = [self constraintWithNametag:$(@"%@-left", nametag)];
    }

    nametag = ClassNametagWithSuffix(@"Internal-Label");

    if (![self.labelContainer constraintsWithNametagPrefix:nametag]) {

      NSMutableString * positionalConstraints = [@"H:|" mutableCopy];

      for (NSUInteger i = 0; i < self.labelCount; i++) {
        NSString * labelName   = $(@"label%lu", (unsigned long)i);
        NSString * constraints = $(@"%1$@.width = self.width '%2$@'\n"
                                   "%1$@.centerY = container.centerY '%2$@'", labelName, nametag);
        UILabel * label = self.labelContainer.subviews[i];

        [self addConstraints:[NSLayoutConstraint
                              constraintsByParsingString:constraints
                              views:@{ labelName    : label,
                                       @"self"      : self,
                                       @"container" : self.labelContainer }]];

        [positionalConstraints appendFormat:@"[%@]", label.text];
      }

      [positionalConstraints appendString:@"|"];

      NSDictionary * labels =
      [NSDictionary dictionaryWithObjects:self.labelContainer.subviews
                                  forKeys:[self.labelContainer valueForKeyPath:@"subviews.text"]];

      NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:positionalConstraints
                                                                      options:0
                                                                      metrics:nil
                                                                        views:labels];

      [constraints setValue:nametag forKeyPath:@"nametag"];

      [self.labelContainer addConstraints:constraints];
    }
  }
}

- (void)addSubelementView:(ButtonView *)view {
  [super addSubelementView:view];
  [view.gestureRecognizers makeObjectsPerformSelector:@selector(requireGestureRecognizerToFail:)
                                           withObject:self.labelPanGesture];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroupView Overrides
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)kvoRegistration {

  MSDictionary * reg = [super kvoRegistration];
  reg[@"labels"] =  ^(MSKVOReceptionist * receptionist) {
    [(__bridge RockerView *)receptionist.context buildLabels];
  };

  reg[@"commandSets"] = ^(MSKVOReceptionist * receptionist) {
    RockerView * picker = (__bridge RockerView *)receptionist.context;
    [picker.model selectCommandSetAtIndex:picker.labelIndex];
  };

  return reg;
}

- (void)addInternalSubviews {
  [super addInternalSubviews];

  self.overlayClipsToBounds = YES;
  [self addViewToOverlay:({
    UIView * labelContainer = [UIView newForAutolayout];
    labelContainer.backgroundColor = ClearColor;
    self.labelContainer = labelContainer;
    labelContainer;
  })];
}

- (void)initializeViewFromModel {
  [super initializeViewFromModel];
  [self buildLabels];
  [self.model selectCommandSetAtIndex:self.labelIndex];
}
- (void)attachGestureRecognizers {
  [super attachGestureRecognizers];

  UIPanGestureRecognizer * labelPanGesture = [[UIPanGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePan:)];
  labelPanGesture.maximumNumberOfTouches = 1;
  [self addGestureRecognizer:labelPanGesture];
  for (UIView * view in self.subelementViews)
    [view.gestureRecognizers makeObjectsPerformSelector:@selector(requireGestureRecognizerToFail:)
                                             withObject:self.labelPanGesture];

  self.labelPanGesture = labelPanGesture;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Label Management
////////////////////////////////////////////////////////////////////////////////

/// This method animates the label "paged" to via the panning gesture and calls `updateCommandSet`
/// upon completion.
/// @param index The label index for the destination label.
/// @param duration The time in seconds it should take the animation to complete.
- (void)animateLabelContainerToIndex:(NSUInteger)index withDuration:(CGFloat)duration {
  CGFloat labelWidth = self.bounds.size.width;

  [UIView animateWithDuration:duration
                        delay:0.0
                      options:(UIViewAnimationOptionBeginFromCurrentState
                               | UIViewAnimationOptionOverrideInheritedDuration
                               | UIViewAnimationOptionCurveEaseOut)
                   animations:^{ self.labelContainerLeftConstraint.constant = 0 - labelWidth * index;
                                 [self setNeedsLayout]; }
                   completion:^(BOOL finished) { if (finished)
                                                   [self.model selectCommandSetAtIndex:_labelIndex]; }];
}

/// Generate `UILabels` for each label in the model's set and attach to `scrollingLabels`. Any
/// labels attached already to the `scrollingLabels` are removed first.
- (void)buildLabels {

  for (UIView * subview in self.labelContainer.subviews) [subview removeFromSuperview];

  CommandContainer * container = self.model.commandContainer;

  if ([container isKindOfClass:[CommandSetCollection class]]) {

    self.labelCount = container.count;

    if (self.labelCount) {

      for (NSUInteger i = 0; i < self.labelCount; i++) {

        NSAttributedString * label = [self.model labelForCommandSetAtIndex:i];

        UILabel * newLabel = [UILabel newForAutolayout];
        newLabel.attributedText  = label;
        newLabel.backgroundColor = [UIColor clearColor];
        [self.labelContainer addSubview:newLabel];

      }

    }

  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

/// Handler for pan gesture attached to `labelContainer` that behaves similar to a scroll view for
/// selecting among the labels attached.
/// @param gestureRecognizer The gesture that responded to a pan event in the view.
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
  switch (gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan:
      _blockPan      = NO;
      _panLength     = 0;
      _prevPanAmount = 0;
      break;

    case UIGestureRecognizerStateChanged: {
      if (_blockPan) break;

      CGFloat velocity = fabs([gestureRecognizer velocityInView:self].x);
      CGFloat duration = 0.5;

      while (duration > 0.1 && velocity > 1) {
        velocity /= 3.0;

        if (velocity > 1) duration -= 0.1;
      }

      CGFloat labelWidth = self.bounds.size.width;
      CGFloat panAmount  = [gestureRecognizer translationInView:self].x;

      _panLength += fabs(panAmount);

      // Check if pan has moved out of label index range
      if (  _prevPanAmount != 0
         && (  (panAmount < 0 && panAmount > _prevPanAmount)
            || (panAmount > 0 && panAmount < _prevPanAmount)))
      {
        _blockPan = YES;

        if (_prevPanAmount > 0)
          _labelIndex = MAX(_labelIndex - 1, 0);

        else
          _labelIndex = MIN(_labelIndex + 1, _labelCount - 1);

        [self animateLabelContainerToIndex:_labelIndex withDuration:duration];

        break;
      }

      // Check if pan has moved out of the button group bounds
      if (_panLength >= labelWidth) {
        _blockPan = YES;

        if (panAmount > 0) _labelIndex--;
        else _labelIndex++;

        [self animateLabelContainerToIndex:_labelIndex withDuration:duration];
        break;
      }

      // Check that pan leaves at least one full label within button group bounds
      CGFloat currentOffset  = self.labelContainerLeftConstraint.constant;
      CGFloat newOffset      = currentOffset + panAmount;
      CGFloat containerWidth = self.labelContainer.bounds.size.width;
      CGFloat minOffset      = -containerWidth + labelWidth;

      if (newOffset < minOffset) {
        _blockPan   = YES;
        _labelIndex = self.labelCount - 1;
        [self animateLabelContainerToIndex:_labelIndex withDuration:duration];
      } else if (newOffset > 0) {
        _blockPan   = YES;
        _labelIndex = 0;
        [self animateLabelContainerToIndex:_labelIndex withDuration:duration];
      } else {
        _prevPanAmount = panAmount;
        [UIView animateWithDuration:0
                         animations:^{ _labelContainerLeftConstraint.constant = newOffset;
                                       [self setNeedsLayout]; }];
      }

      break;
    }

    case UIGestureRecognizerStateEnded:
      [self animateLabelContainerToIndex:_labelIndex withDuration:0.5];
      break;

    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStatePossible:
      break;
  }

}

@end
