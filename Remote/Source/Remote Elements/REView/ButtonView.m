//
// ButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "ImageView.h"
#import "TitleAttributes.h"
#import "Button.h"
#import "Command.h"
#import "ControlStateTitleSet.h"

// #define DEBUG_BV_COLOR_BG

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


@interface ButtonView ()
@property (nonatomic, weak,   readwrite)  UITapGestureRecognizer       * tapGesture;
@property (nonatomic, weak,   readwrite)  MSLongPressGestureRecognizer * longPressGesture;
@property (nonatomic, weak,   readwrite)  UILabel                      * labelView;
@property (nonatomic, weak,   readwrite)  UIActivityIndicatorView      * activityIndicator;
@end

@implementation ButtonView


#pragma mark Internal subviews and constraints
////////////////////////////////////////////////////////////////////////////////


- (void)addInternalSubviews {
  [super addInternalSubviews];

  self.subelementInteractionEnabled = NO;
  self.contentInteractionEnabled    = NO;

  UILabel * labelView = [UILabel newForAutolayout];
  [self addViewToContent:labelView];
  self.labelView = labelView;

  UIActivityIndicatorView * activityIndicator = [UIActivityIndicatorView newForAutolayout];
  activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  activityIndicator.color                      = defaultTitleHighlightColor();
  [self addViewToOverlay:activityIndicator];
  self.activityIndicator = activityIndicator;
}

- (void)updateConstraints {
  [super updateConstraints];

  NSString * labelNametag    = ClassNametagWithSuffix(@"InternalLabel");
  NSString * activityNametag = ClassNametagWithSuffix(@"InternalActivity");

  if (![self constraintsWithNametagPrefix:labelNametag]) {
    UIEdgeInsets titleInsets = self.model.titleEdgeInsets;
    NSString   * constraints =
      $(@"'%1$@' label.left = self.left + %3$f @900\n"
        "'%1$@' label.top = self.top + %4$f @900\n"
        "'%1$@' label.bottom = self.bottom - %5$f @900\n"
        "'%1$@' label.right = self.right - %6$f @900\n"
        "'%2$@' activity.centerX = self.centerX\n"
        "'%2$@' activity.centerY = self.centerY",
        labelNametag, activityNametag,
        titleInsets.left, titleInsets.top, titleInsets.bottom, titleInsets.right);

    NSDictionary * views = @{@"self": self, @"label": self.labelView, @"activity": self.activityIndicator};

    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
  }
}

#pragma mark Gestures
////////////////////////////////////////////////////////////////////////////////


- (void)attachGestureRecognizers {
  [super attachGestureRecognizers];

  MSLongPressGestureRecognizer * longPressGesture =
    [MSLongPressGestureRecognizer gestureWithTarget:self action:@selector(handleLongPress:)];

  longPressGesture.delaysTouchesBegan = NO;
  longPressGesture.delegate           = self;
  [self addGestureRecognizer:longPressGesture];
  self.longPressGesture = longPressGesture;

  UITapGestureRecognizer * tapGesture =
    [UITapGestureRecognizer gestureWithTarget:self action:@selector(handleTap:)];

  tapGesture.numberOfTapsRequired    = 1;
  tapGesture.numberOfTouchesRequired = 1;
  tapGesture.delaysTouchesBegan      = NO;
  tapGesture.delegate                = self;
  [self addGestureRecognizer:tapGesture];
  self.tapGesture = tapGesture;
}

/// Single tap action executes the primary button command
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {

  if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {

    self.model.highlighted = YES;

    __weak ButtonView * weakself = self;
    MSDelayedRunOnMain(1.0, ^{ weakself.model.highlighted = NO; });

    if (self.tapAction) self.tapAction();
    else [self executeActionWithOptions:CommandOptionDefault];
  }
}

/// Long press action executes the secondary button command
- (void)handleLongPress:(MSLongPressGestureRecognizer *)gestureRecognizer {

  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {

    if (self.pressAction) self.pressAction();
    else [self executeActionWithOptions:CommandOptionLongPress];

  } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
    self.model.highlighted = YES;
    [self setNeedsDisplay];
  }
}


#pragma mark Button actions
////////////////////////////////////////////////////////////////////////////////


- (void)executeActionWithOptions:(CommandOptions)options {

  if (!self.editing) {

    if (self.model.command.indicator) [_activityIndicator startAnimating];

    [self.model executeCommandWithOptions:options
                               completion:^(BOOL success, NSError * error) {
                                 if ([self.activityIndicator isAnimating])
                                   MSRunAsyncOnMain(^{ [self.activityIndicator stopAnimating]; });
                               }];
  }

}

#pragma mark Content size
////////////////////////////////////////////////////////////////////////////////


- (CGSize)intrinsicContentSize { return self.minimumSize; }

- (CGSize)minimumSize {

  CGRect frame = (CGRect) { .size = REMinimumSize };

  NSMutableSet * titles = [NSMutableSet set];

  for (NSString *mode in self.model.modes) {
    ControlStateTitleSet * titleSet = [self.model titlesForMode:mode];
    if (titleSet) [titles addObjectsFromArray:[titleSet allValues]];
  }

  if ([titles count]) {

    CGFloat maxWidth = 0.0, maxHeight = 0.0;

    for (NSAttributedString * title in [titles valueForKeyPath:@"string"]) {

      CGSize titleSize = [title size];
      UIEdgeInsets titleInsets = self.model.titleEdgeInsets;

      titleSize.width  += titleInsets.left + titleInsets.right;
      titleSize.height += titleInsets.top + titleInsets.bottom;

      maxWidth = MAX(titleSize.width, maxWidth);
      maxHeight = MAX(titleSize.height, maxHeight);

    }

    frame.size.width = MAX(maxWidth, frame.size.width);
    frame.size.height = MAX(maxHeight, frame.size.height);
  }

  if (self.model.proportionLock && !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {

    CGSize currentSize = self.bounds.size;

    if (currentSize.width > currentSize.height)
      frame.size.height = (frame.size.width * currentSize.height) / currentSize.width;

    else
      frame.size.width = (frame.size.height * currentSize.width) / currentSize.height;
  }

  return frame.size;
}

#pragma mark Prevent adding subelement views
////////////////////////////////////////////////////////////////////////////////


- (void)addSubelementView:(RemoteElementView *)view {}
- (void)removeSubelementView:(RemoteElementView *)view {}
- (void)addSubelementViews:(NSSet *)views {}
- (void)removeSubelementViews:(NSSet *)views {}
- (NSArray *)subelementViews { return nil; }


#pragma mark Initialization
////////////////////////////////////////////////////////////////////////////////


- (void)initializeIVARs {
  self.cornerRadii    = (CGSize) { 5.0f, 5.0f };
  [super initializeIVARs];
}

- (void)initializeViewFromModel {
  [super initializeViewFromModel];

  self.longPressGesture.enabled = (self.model.longPressCommand != nil);
  self.labelView.attributedText = self.model.title;

  [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
}

#pragma mark Key-value observing
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)kvoRegistration {

  MSDictionary * reg = [super kvoRegistration];

//    reg[@"selected"] = ^(MSKVOReceptionist * receptionist) {
//      [(__bridge ButtonView *)receptionist.context updateState];
//    };

//    reg[@"enabled"] = ^(MSKVOReceptionist * receptionist) {
//      ButtonView * buttonView = (__bridge ButtonView *)receptionist.context;
//      buttonView.enabled = [receptionist.change[NSKeyValueChangeNewKey] boolValue];
//    };

//    reg[@"highlighted"] = ^(MSKVOReceptionist * receptionist) {
//      [(__bridge ButtonView *)receptionist.context setNeedsDisplay];
//    };

    reg[@"title"] = ^(MSKVOReceptionist * receptionist) {
      ButtonView         * buttonView = (ButtonView *)receptionist.observer;
      NSAttributedString * title      = NilSafe(receptionist.change[NSKeyValueChangeNewKey]);
      buttonView.labelView.attributedText = title;
      [buttonView invalidateIntrinsicContentSize];
      [buttonView setNeedsDisplay];
    };

//    reg[@"image"] = ^(MSKVOReceptionist * receptionist) {
//      assert(NO);
//    };

    reg[@"icon"] = ^(MSKVOReceptionist * receptionist) {
      ButtonView * buttonView = (ButtonView *)receptionist.observer;
      [buttonView invalidateIntrinsicContentSize];
      [buttonView setNeedsDisplay];
    };

  return reg;
}

#pragma mark Editing
////////////////////////////////////////////////////////////////////////////////


- (void)setEditingMode:(REEditingMode)editingMode {
  [super setEditingMode:editingMode];
  BOOL enabled = !self.isEditing;
  self.tapGesture.enabled       = enabled;
  self.longPressGesture.enabled = enabled;
}

#pragma mark Drawing
////////////////////////////////////////////////////////////////////////////////


- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  UIImage * icon = self.model.icon.colorImage;
  if (icon) {
    UIGraphicsPushContext(ctx);
    CGRect insetRect = UIEdgeInsetsInsetRect(self.bounds, self.model.imageEdgeInsets);
    CGSize imageSize = (CGSizeContainsSize(insetRect.size, icon.size)
                        ? icon.size
                        : CGSizeAspectMappedToSize(icon.size, insetRect.size, YES));
    CGRect imageRect = CGRectMake(CGRectGetMidX(insetRect) - imageSize.width / 2.0,
                                  CGRectGetMidY(insetRect) - imageSize.height / 2.0,
                                  imageSize.width,
                                  imageSize.height);

    [icon drawInRect:imageRect];
    UIGraphicsPopContext();
  }
}

@end
