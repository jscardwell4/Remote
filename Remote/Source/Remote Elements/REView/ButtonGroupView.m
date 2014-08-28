//
// ButtonGroupView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteElementView_Private.h"
#import "ButtonGroup.h"
#import "Button.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)


@interface ButtonGroupView ()

@property (nonatomic, weak) NSLayoutConstraint       * tuckedConstraint;
@property (nonatomic, weak) NSLayoutConstraint       * untuckedConstraint;
@property (nonatomic, weak) MSSwipeGestureRecognizer * tuckGesture;
@property (nonatomic, weak) MSSwipeGestureRecognizer * untuckGesture;

@property (nonatomic, assign)  UISwipeGestureRecognizerDirection tuckDirection;
@property (nonatomic, assign)  UISwipeGestureRecognizerDirection untuckDirection;
@property (nonatomic, assign)  MSSwipeGestureRecognizerQuadrant  quadrant;

@end

@implementation ButtonGroupView


- (void)updateConstraints {

  [super updateConstraints];

  NSString * nametag = ClassNametagWithSuffix(@"Label");

  if (self.label && ![self constraintsWithNametagPrefix:nametag]) {
    NSString * constraints =
      $(@"'%1$@' label.width = self.width\n"
        "'%1$@' label.height = self.height\n"
        "'%1$@' label.centerX = self.centerX\n"
        "'%1$@' label.centerY = self.centerY", nametag);

    [self addConstraints: [NSLayoutConstraint constraintsByParsingString:constraints
                                                                   views:@{@"self": self, @"label": self.label}]];
  }


}

- (CGSize)intrinsicContentSize {
  switch ((uint8_t)self.model.role) {
    case REButtonGroupRoleToolbar: return CGSizeMake(MainScreen.bounds.size.width, 44.0);
    default:                       return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
  }
}

- (void)buttonViewDidExecute:(ButtonView *)buttonView {
  if (self.model.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)tuck {
  if (self.model.isPanel && self.tuckedConstraint && self.untuckedConstraint) {
    [UIView animateWithDuration:0.25
                     animations:^{
                       self.untuckedConstraint.priority = 1;
                       self.tuckedConstraint.priority = 999;
                       [self.window setNeedsUpdateConstraints];
                       [self setNeedsLayout];
                       [self layoutIfNeeded];
                     }

                     completion:^(BOOL finished) {
                       _tuckGesture.enabled = NO;
                       _untuckGesture.enabled = YES;
                     }];
  }
}

- (void)untuck {
  if (self.model.isPanel && self.tuckedConstraint && self.untuckedConstraint) {
    [UIView animateWithDuration:0.25
                     animations:^{
                       self.tuckedConstraint.priority = 1;
                       self.untuckedConstraint.priority = 999;
                       [self.window setNeedsUpdateConstraints];
                       [self setNeedsLayout];
                       [self layoutIfNeeded];
                     }

                     completion:^(BOOL finished) {
                       _tuckGesture.enabled = YES;
                       _untuckGesture.enabled = NO;
                     }];

  }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateRecognized) {
    if (gesture == _tuckGesture)
      [self tuck];
    else if (gesture == _untuckGesture)
      [self untuck];
  }
}

- (void)attachTuckGestures {
  MSSwipeGestureRecognizer * tuck = [[MSSwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleSwipe:)];
  tuck.nametag   = $(@"'%@'-tuck", self.name);
  tuck.enabled   = NO;
  tuck.direction = self.tuckDirection;
  tuck.quadrant  = self.quadrant;
  [self.window addGestureRecognizer:tuck];
  self.tuckGesture = tuck;

  MSSwipeGestureRecognizer * untuck = [[MSSwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSwipe:)];
  untuck.nametag   = $(@"'%@'-untuck", self.name);
  untuck.direction = self.untuckDirection;
  untuck.quadrant  = self.quadrant;
  [self.window addGestureRecognizer:untuck];
  self.untuckGesture = untuck;
}

- (void)didMoveToWindow { if (self.model.isPanel && !self.isEditing && self.window) [self attachTuckGestures]; }

- (NSDictionary *)kvoRegistration {
  // TODO: observe panel location
  NSDictionary * kvoRegistration =
    @{

    @"label" :
    ^(MSKVOReceptionist * receptionist,
      NSString          * keyPath,
      id object,
      NSDictionary      * change,
      void              * context)
    {
      id newValue = change[NSKeyValueChangeNewKey];
      _label.attributedText = (ValueIsNotNil(newValue) ? (NSAttributedString *)newValue : nil);
    }

  };

  return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}

- (void)initializeIVARs {
  [super initializeIVARs];

  self.shrinkwrap  = YES;
  self.resizable   = YES;
  self.moveable    = YES;
  self.cornerRadii = CGSizeMake(5.0f, 5.0f);

  if ((self.model.role & REButtonGroupRoleToolbar) == REButtonGroupRoleToolbar) {
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
  }
}

- (void)didMoveToSuperview {
  [super didMoveToSuperview];

  if (self.superview && [self.model isPanel] && !self.isEditing) {

    NSLayoutAttribute attribute1, attribute2;

    switch (self.model.panelLocation) {
      case REPanelLocationTop:
        attribute1           = NSLayoutAttributeBottom;
        attribute2           = NSLayoutAttributeTop;
        self.tuckDirection   = UISwipeGestureRecognizerDirectionUp;
        self.untuckDirection = UISwipeGestureRecognizerDirectionDown;
        self.quadrant        = MSSwipeGestureRecognizerQuadrantUp;
        break;

      case REPanelLocationBottom:
        attribute1           = NSLayoutAttributeTop;
        attribute2           = NSLayoutAttributeBottom;
        self.tuckDirection   = UISwipeGestureRecognizerDirectionDown;
        self.untuckDirection = UISwipeGestureRecognizerDirectionUp;
        self.quadrant        = MSSwipeGestureRecognizerQuadrantDown;
        break;

      case REPanelLocationLeft:
        attribute1           = NSLayoutAttributeRight;
        attribute2           = NSLayoutAttributeLeft;
        self.tuckDirection   = UISwipeGestureRecognizerDirectionLeft;
        self.untuckDirection = UISwipeGestureRecognizerDirectionRight;
        self.quadrant        = MSSwipeGestureRecognizerQuadrantLeft;
        break;

      case REPanelLocationRight:
        attribute1           = NSLayoutAttributeLeft;
        attribute2           = NSLayoutAttributeRight;
        self.tuckDirection   = UISwipeGestureRecognizerDirectionRight;
        self.untuckDirection = UISwipeGestureRecognizerDirectionLeft;
        self.quadrant        = MSSwipeGestureRecognizerQuadrantRight;
        break;

      default:
        assert(NO);
        break;
    }

    self.tuckedConstraint = [NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute1
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.superview
                                                     attribute:attribute2
                                                    multiplier:1.0f
                                                      constant:0.0f];
    self.tuckedConstraint.priority = 999;
    self.tuckedConstraint.nametag  = REButtonGroupPanelNametag;
    self.untuckedConstraint        = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:attribute2
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:attribute2
                                                             multiplier:1.0f
                                                               constant:0.0f];
    self.untuckedConstraint.priority = 1;
    self.untuckedConstraint.nametag  = REButtonGroupPanelNametag;
    [self.superview addConstraints:@[self.tuckedConstraint, self.untuckedConstraint]];
  }
}

- (void)addSubelementView:(ButtonView *)view {
  if (self.locked) [view setValuesForKeysWithDictionary:@{ @"resizable" : @NO,
                                                           @"moveable"  : @NO }];

  if (view.model.role == REButtonRoleTuck) {
    __weak ButtonGroupView * weakself = self;
    __weak ButtonView      * weakview = view;

    [view setActionHandler:^{ [weakself tuck]; } forAction:RESingleTapAction];
  }

  [super addSubelementView:view];
}

- (void)addInternalSubviews {
  [super addInternalSubviews];

  UILabel * label = [UILabel newForAutolayout];
  label.backgroundColor = ClearColor;
  [self addViewToContent:_label];
  self.label = label;
}

- (void)setEditingMode:(REEditingMode)mode {
  [super setEditingMode:mode];

  self.resizable = (self.editingMode == REEditingModeNotEditing) ? YES : NO;
  self.moveable  = (self.editingMode == REEditingModeNotEditing) ? YES : NO;

  if (self.editingMode == RERemoteEditingMode)
    self.subelementInteractionEnabled = NO;

  else if (self.editingMode == REButtonGroupEditingMode)
    self.subelementInteractionEnabled = YES;

}

@end

@implementation ButtonGroupView (Drawing)

- (void)drawRoundedPanelInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  REPanelLocation panelLocation = self.model.panelLocation;

  CGContextClearRect(ctx, self.bounds);

  NSUInteger roundedCorners = (panelLocation == REPanelLocationRight
                               ? UIRectCornerTopLeft | UIRectCornerBottomLeft
                               : (panelLocation == REPanelLocationLeft
                                  ? UIRectCornerTopRight | UIRectCornerBottomRight
                                  : 0));

  UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    byRoundingCorners:roundedCorners
                                                          cornerRadii:CGSizeMake(15, 15)];

  self.borderPath = bezierPath;

  [defaultBGColor() setFill];

  [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:0.9];

  CGRect  insetRect = CGRectInset(self.bounds, 0, 3);
  CGFloat tx        = (panelLocation == REPanelLocationRight ? 3 : -3);

  insetRect = CGRectApplyAffineTransform(insetRect, CGAffineTransformMakeTranslation(tx, 0));

  bezierPath = [UIBezierPath bezierPathWithRoundedRect:insetRect
                                     byRoundingCorners:roundedCorners
                                           cornerRadii:CGSizeMake(12, 12)];
  bezierPath.lineWidth = 2.0;
  [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
}

@end

