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

// #define DEBUG_BV_COLOR_BG

#define MIN_HIGHLIGHT_INTERVAL 1.0
#define CORNER_RADII           CGSizeMake(5.0f, 5.0f)

MSNAMETAG_DEFINITION(REButtonViewInternal);
MSNAMETAG_DEFINITION(REButtonViewLabel);
MSNAMETAG_DEFINITION(REButtonViewActivityIndicator);

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

#pragma unused(ddLogLevel, msLogContext)


@implementation ButtonView


////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal subviews and constraints
////////////////////////////////////////////////////////////////////////////////


- (void)addInternalSubviews {
  [super addInternalSubviews];

  self.subelementInteractionEnabled = NO;
  self.contentInteractionEnabled    = NO;

  _labelView = [UILabel newForAutolayout];
  [self addViewToContent:_labelView];

  _activityIndicator = [UIActivityIndicatorView newForAutolayout];
  _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  _activityIndicator.color                      = defaultTitleHighlightColor();
  [self addViewToOverlay:_activityIndicator];
}

- (void)updateConstraints {
  [super updateConstraints];

  if (![self constraintsWithNametagPrefix:REButtonViewInternalNametag]) {
    UIEdgeInsets titleInsets = self.model.titleEdgeInsets;
    NSString   * constraints =
      $(@"'%1$@' _labelView.left = self.left + %3$f @900\n"
        "'%1$@' _labelView.top = self.top + %4$f @900\n"
        "'%1$@' _labelView.bottom = self.bottom - %5$f @900\n"
        "'%1$@' _labelView.right = self.right - %6$f @900\n"
        "'%2$@' _activityIndicator.centerX = self.centerX\n"
        "'%2$@' _activityIndicator.centerY = self.centerY",
        $(@"%@-%@", REButtonViewInternalNametag, REButtonViewLabelNametag),
        $(@"%@-%@", REButtonViewInternalNametag, REButtonViewActivityIndicatorNametag),
        titleInsets.left, titleInsets.top,
        titleInsets.bottom, titleInsets.right);

    NSDictionary * views = NSDictionaryOfVariableBindings(self, _labelView, _activityIndicator);

    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Gestures
////////////////////////////////////////////////////////////////////////////////


- (void)attachGestureRecognizers {
  [super attachGestureRecognizers];

  _longPressGesture = [MSLongPressGestureRecognizer gestureWithTarget:self
                                                               action:@selector(handleLongPress:)];
  _longPressGesture.delaysTouchesBegan = NO;
  _longPressGesture.delegate           = self;
  [self addGestureRecognizer:_longPressGesture];

  _tapGesture                         = [UITapGestureRecognizer gestureWithTarget:self action:@selector(handleTap:)];
  _tapGesture.numberOfTapsRequired    = 1;
  _tapGesture.numberOfTouchesRequired = 1;
  _tapGesture.delaysTouchesBegan      = NO;
  _tapGesture.delegate                = self;
  [self addGestureRecognizer:_tapGesture];
}

/**
   Single tap action executes the primary button command
 */
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
    self.highlighted = YES;
    assert(self.model.highlighted);

    MSDelayedRunOnMain(_options.minHighlightInterval,
                       ^{
      _flags.highlightActionQueued = NO;
      self.highlighted = NO;
      [self setNeedsDisplay];
    });

    REActionHandler handler = _actionHandlers[@(RESingleTapAction)];

    if (handler)
      handler();

    else
      [self buttonActionWithOptions:CommandOptionDefault];
  } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled && !_flags.longPressActive) {
//        self.highlighted = NO;
//        [self setNeedsDisplay];
  }
}

/**
   Long press action executes the secondary button command
 */
- (void)handleLongPress:(MSLongPressGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    REActionHandler handler = _actionHandlers[@(RELongPressAction)];

    if (handler)
      handler();

    else
      [self buttonActionWithOptions:CommandOptionLongPress];
  } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
    _flags.longPressActive = YES;
    self.highlighted       = YES;
    [self setNeedsDisplay];
  }
}

/**
   Enables or disables tap and long press gestures
 */
- (void)updateGesturesEnabled:(BOOL)enabled {
  _tapGesture.enabled       = enabled;
  _longPressGesture.enabled = enabled;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark ￼Button state
////////////////////////////////////////////////////////////////////////////////


- (void)updateState {
  UIControlState currentState = self.state;

  self.userInteractionEnabled = ((currentState & UIControlStateDisabled) ? NO : YES);

  BOOL invalidate = NO;

  NSAttributedString * title = self.model.title;

  if (![_labelView.attributedText isEqualToAttributedString:title]) {
    _labelView.attributedText = title;
    invalidate                = YES;
  }

  UIImage * icon = self.model.icon.colorImage;

  if (_icon != icon) {
    _icon      = icon;
    invalidate = YES;
  }

  self.backgroundColor = self.model.backgroundColor;

  if (invalidate) {
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
  }

}

- (UIControlState)state { return (UIControlState)self.model.state; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Button actions
////////////////////////////////////////////////////////////////////////////////


- (void)setActionHandler:(REActionHandler)handler forAction:(REAction)action {
  _actionHandlers[@(action)] = handler;
}

- (void)buttonActionWithOptions:(CommandOptions)options {
  assert(self.model);

  if (!self.editing && _flags.commandsActive) {
    if (_flags.longPressActive) {
      _flags.longPressActive = NO;
      [self setNeedsDisplay];
    }

    if (_flags.activityIndicator) [_activityIndicator startAnimating];

    CommandCompletionHandler completion =
      ^(BOOL success, NSError * error)
    {
      if ([_activityIndicator isAnimating])
        MSRunAsyncOnMain(^{ [_activityIndicator stopAnimating]; });
    };

    [self.model executeCommandWithOptions:options completion:completion];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Content size
////////////////////////////////////////////////////////////////////////////////


- (CGSize)intrinsicContentSize { return self.minimumSize; }

- (CGSize)minimumSize {
  CGRect frame = (CGRect) {
    .size = REMinimumSize
  };
  NSAttributedString * title = self.model.title;

  if (title) {
    CGSize       titleSize   = [title size];
    UIEdgeInsets titleInsets = self.titleEdgeInsets;

    titleSize.width  += titleInsets.left + titleInsets.right;
    titleSize.height += titleInsets.top + titleInsets.bottom;
    frame             = CGRectUnion(frame, (CGRect) {.size = titleSize });
  }

  if (_icon) {
    CGSize       iconSize    = [_icon size];
    UIEdgeInsets imageInsets = self.imageEdgeInsets;

    iconSize.width  += imageInsets.left + imageInsets.right;
    iconSize.height += imageInsets.top + imageInsets.bottom;
    frame            = CGRectUnion(frame, (CGRect) {.size = iconSize });
  }

  UIEdgeInsets contentInsets = self.contentEdgeInsets;

  frame.size.width  += contentInsets.left + contentInsets.right;
  frame.size.height += contentInsets.top + contentInsets.bottom;

  if (self.proportionLock && !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
    CGSize currentSize = self.bounds.size;

    if (currentSize.width > currentSize.height)
      frame.size.height = (frame.size.width * currentSize.height) / currentSize.width;

    else
      frame.size.width = (frame.size.height * currentSize.width) / currentSize.height;
  }

  return frame.size;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Subelement views
////////////////////////////////////////////////////////////////////////////////


- (void)addSubelementView:(RemoteElementView *)view {}

- (void)removeSubelementView:(RemoteElementView *)view {}

- (void)addSubelementViews:(NSSet *)views {}

- (void)removeSubelementViews:(NSSet *)views {}

- (NSArray *)subelementViews { return nil; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Initialization
////////////////////////////////////////////////////////////////////////////////


- (void)initializeIVARs {
  _actionHandlers               = [@{} mutableCopy];
  self.cornerRadii              = CORNER_RADII;
  _options.minHighlightInterval = MIN_HIGHLIGHT_INTERVAL;
  _flags.commandsActive         = YES;

  [super initializeIVARs];
}

- (void)initializeViewFromModel {
  [super initializeViewFromModel];

  _longPressGesture.enabled = (self.model.longPressCommand != nil);
  _flags.activityIndicator  = self.model.command.indicator;
  [self updateState];
  [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Key-value observing
////////////////////////////////////////////////////////////////////////////////


- (NSDictionary *)kvoRegistration {

  NSDictionary * kvoRegistration =
    @{

      @"selected" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        [(__bridge ButtonView *)context updateState];
      },

      @"enabled" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        BOOL         enabled    = [change[NSKeyValueChangeNewKey] boolValue];
        buttonView.enabled = enabled;
      },

      @"highlighted" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        [(__bridge ButtonView *)context updateState];
      },

      @"command" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        buttonView->_flags.activityIndicator = buttonView.model.command.indicator;
      },

      @"style" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        [buttonView setNeedsDisplay];
      },

      @"title" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView         * buttonView = (__bridge ButtonView *)context;
        NSAttributedString * title      = NilSafe(change[NSKeyValueChangeNewKey]);
        buttonView->_labelView.attributedText = title;
      },

      @"image" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        [(__bridge ButtonView *)context updateState];
      },

      @"icon" :
        ^(MSKVOReceptionist * receptionist,
          NSString          * keyPath,
          id                  object,
          NSDictionary      * change,
          void              * context)
      {
        ButtonView * buttonView = (__bridge ButtonView *)context;
        ImageView  * icon       = NilSafe(change[NSKeyValueChangeNewKey]);
        buttonView->_icon = icon.colorImage;
        [buttonView setNeedsDisplay];
      }
      
    };

  return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Editing
////////////////////////////////////////////////////////////////////////////////


- (void)setEditingMode:(REEditingMode)editingMode {
  [super setEditingMode:editingMode];
  _flags.commandsActive = (editingMode == REEditingModeNotEditing) ? YES : NO;
  [self updateGesturesEnabled:_flags.commandsActive];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Drawing
////////////////////////////////////////////////////////////////////////////////


- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  if (_icon) {
    UIGraphicsPushContext(ctx);
    CGRect insetRect = UIEdgeInsetsInsetRect(self.bounds, self.imageEdgeInsets);
    CGSize imageSize = (CGSizeContainsSize(insetRect.size, _icon.size)
                        ? _icon.size
                        : CGSizeAspectMappedToSize(_icon.size, insetRect.size, YES));
    CGRect imageRect = CGRectMake(CGRectGetMidX(insetRect) - imageSize.width / 2.0,
                                  CGRectGetMidY(insetRect) - imageSize.height / 2.0,
                                  imageSize.width,
                                  imageSize.height);

    if (_options.antialiasIcon) {
      CGContextSetAllowsAntialiasing(ctx, YES);
      CGContextSetShouldAntialias(ctx, YES);
    }

    [_icon drawInRect:imageRect];
    UIGraphicsPopContext();
  }
}

@end
