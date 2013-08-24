//
// REButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "REView_Private.h"

// #define DEBUG_BV_COLOR_BG
MSKIT_NAMETAG_DEFINITION(REButtonViewInternal);
MSKIT_NAMETAG_DEFINITION(REButtonViewLabel);
MSKIT_NAMETAG_DEFINITION(REButtonViewActivityIndicator);

static const int   ddLogLevel = LOG_LEVEL_DEBUG;
static const int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation REButtonView

- (void)updateConstraints
{
    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:REButtonViewInternalNametag])
    {
        UIEdgeInsets   titleInsets = self.model.titleEdgeInsets;
        NSString     * constraints =
            [NSString stringWithFormat:
             @"'%1$@' _labelView.left = self.left + %3$f @900\n"
              "'%1$@' _labelView.top = self.top + %4$f @900\n"
              "'%1$@' _labelView.bottom = self.bottom - %5$f @900\n"
              "'%1$@' _labelView.right = self.right - %6$f @900\n"
              "'%2$@' _activityIndicator.centerX = self.centerX\n"
              "'%2$@' _activityIndicator.centerY = self.centerY",
             $(@"%@-%@", REButtonViewInternalNametag, REButtonViewLabelNametag),
             $(@"%@-%@", REButtonViewInternalNametag, REButtonViewActivityIndicatorNametag),
             titleInsets.left, titleInsets.top,
             titleInsets.bottom, titleInsets.right];

        NSDictionary * views = NSDictionaryOfVariableBindings(self, _labelView, _activityIndicator);

        [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*  Single tap action executes the primary button command
*******************************************************************************/
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            self.highlighted = YES;

            int64_t           delayInSeconds = _options.minHighlightInterval * NSEC_PER_SEC;
            dispatch_time_t   popTime        = dispatch_time(DISPATCH_TIME_NOW,
                                                             delayInSeconds);

            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                _flags.highlightActionQueued = NO;
                self.highlighted = NO;
                [self setNeedsDisplay];
            }

                           );

            REActionHandler   handler = _actionHandlers[@(RESingleTapAction)];

            if (handler) handler();
            else [self buttonActionWithOptions:RECommandOptionDefault];
        }
        break;

        case UIGestureRecognizerStateCancelled:
        {
            if (!_flags.longPressActive)
            {
                self.highlighted = NO;
                [self setNeedsDisplay];
            }
        }
        break;

        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

- (void)handleLongPress:(MSLongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            REActionHandler   handler = _actionHandlers[@(RELongPressAction)];

            if (handler) handler();
            else [self buttonActionWithOptions:RECommandOptionLongPress];
        }
        break;

        case UIGestureRecognizerStatePossible:
        {
            _flags.longPressActive = YES;
            self.highlighted       = YES;
            [self setNeedsDisplay];
        }
        break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void)updateGesturesEnabled:(BOOL)enabled
{
    _tapGesture.enabled       = enabled;
    _longPressGesture.enabled = enabled;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ￼Button State
////////////////////////////////////////////////////////////////////////////////

- (void)updateState
{

    UIControlState   currentState = self.state;

    self.userInteractionEnabled = ((currentState & UIControlStateDisabled) ? NO : YES);
    BOOL                 invalidate = NO;
    NSAttributedString * title      = self.model.title;
    if (![_labelView.attributedText isEqualToAttributedString:title])
    {
        _labelView.attributedText = title;
        invalidate                = YES;
    }
    UIImage * icon = self.model.icon;
    if (_icon != icon)
    {
        _icon      = icon;
        invalidate = YES;
    }

    self.backgroundColor = self.model.backgroundColor;

    if (invalidate)
    {
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
    }

}

- (UIControlState)state { return (UIControlState)self.model.state; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Actions
////////////////////////////////////////////////////////////////////////////////

- (void)setActionHandler:(REActionHandler)handler forAction:(REAction)action
{
    _actionHandlers[@(action)] = handler;
}

- (void)buttonActionWithOptions:(RECommandOptions)options
{
    assert(self.model);
    if (!self.editing && _flags.commandsActive)
    {
        if (_flags.longPressActive)
        {
            _flags.longPressActive = NO;
            [self setNeedsDisplay];
        }

        if (_flags.activityIndicator) [_activityIndicator startAnimating];

//        if (self.model.type == REButtonTypeTuck)
//            [self.parentElementView tuck];
//        else
        [self.model executeCommandWithOptions:options
                                   completion:^(BOOL success, NSError * error)
                                              {
                                                  if ([_activityIndicator isAnimating])
                                                      MSRunAsyncOnMain (^{
                                                          [_activityIndicator stopAnimating];
                                                      });
                                              }];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView Overrides
////////////////////////////////////////////////////////////////////////////////

- (CGSize)intrinsicContentSize
{
    return self.minimumSize;
}

- (CGSize)minimumSize
{
    CGRect               frame = (CGRect){.size = REMinimumSize };
    NSAttributedString * title = self.model.title;

    if (title)
    {
        CGSize         titleSize   = [title size];
        UIEdgeInsets   titleInsets = self.titleEdgeInsets;
        titleSize.width  += titleInsets.left + titleInsets.right;
        titleSize.height += titleInsets.top + titleInsets.bottom;
        frame             = CGRectUnion(frame, (CGRect){.size = titleSize });
    }

    if (_icon)
    {
        CGSize         iconSize    = [_icon size];
        UIEdgeInsets   imageInsets = self.imageEdgeInsets;
        iconSize.width  += imageInsets.left + imageInsets.right;
        iconSize.height += imageInsets.top + imageInsets.bottom;
        frame            = CGRectUnion(frame, (CGRect){.size = iconSize });
    }

    UIEdgeInsets   contentInsets = self.contentEdgeInsets;
    frame.size.width  += contentInsets.left + contentInsets.right;
    frame.size.height += contentInsets.top + contentInsets.bottom;

    if (self.proportionLock && !CGSizeEqualToSize(self.bounds.size, CGSizeZero))
    {
        CGSize   currentSize = self.bounds.size;

        if (currentSize.width > currentSize.height)
            frame.size.height = (frame.size.width * currentSize.height) / currentSize.width;

        else
            frame.size.width = (frame.size.height * currentSize.width) / currentSize.height;
    }

    return frame.size;
}

- (void)addSubelementView:(REView *)view {}

- (void)removeSubelementView:(REView *)view {}

- (void)addSubelementViews:(NSSet *)views {}

- (void)removeSubelementViews:(NSSet *)views {}

- (NSArray *)subelementViews { return nil; }

- (void)initializeIVARs
{
    _actionHandlers               = [@{} mutableCopy];
    self.cornerRadii              = CGSizeMake(5.0f, 5.0f);
    _options.minHighlightInterval = 0.5;
    _flags.commandsActive         = YES;
    [super initializeIVARs];
}

- (void)addInternalSubviews
{
    [super addInternalSubviews];
    self.subelementInteractionEnabled = NO;
    self.contentInteractionEnabled    = NO;
    _labelView                        = [UILabel newForAutolayout];  //[RELabelView newForAutolayout];
    [self addViewToContent:_labelView];

    _activityIndicator                            = [UIActivityIndicatorView newForAutolayout];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.color                      = defaultTitleHighlightColor();
    [self addViewToOverlay:_activityIndicator];
}

- (void)attachGestureRecognizers
{
    [super attachGestureRecognizers];
    _longPressGesture = [MSLongPressGestureRecognizer gestureWithTarget:self
                                                                 action:@selector(handleLongPress:)];
    _longPressGesture.delaysTouchesBegan = NO;
    _longPressGesture.delegate           = self;
    [self addGestureRecognizer:_longPressGesture];

    _tapGesture = [UITapGestureRecognizer gestureWithTarget:self action:@selector(handleTap:)];
    _tapGesture.numberOfTapsRequired    = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    _tapGesture.delaysTouchesBegan      = NO;
    _tapGesture.delegate                = self;
    [self addGestureRecognizer:_tapGesture];
}

- (void)initializeViewFromModel
{
    [super initializeViewFromModel];

    _longPressGesture.enabled = (self.model.longPressCommand != nil);
    _flags.activityIndicator  = self.model.command.indicator;
    [self updateState];
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (NSDictionary *)kvoRegistration
{
    __strong NSDictionary * kvoRegistration =
        @{/*
           @"selected"    : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 [(__bridge REButtonView *)context updateState];
                                             }
                                            ),
           */
           @"enabled"     : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 BOOL enabled = [change[NSKeyValueChangeNewKey] boolValue];
                                                 buttonView.enabled = enabled;
                                             }
                                            ),
           /*
           @"highlighted" : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 [(__bridge REButtonView *)context updateState];
                                             }
                                            ),
           */
           @"command"     : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 buttonView->_flags.activityIndicator = buttonView.model.command.indicator;
                                             }
                                            ),
           @"style"       : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 [buttonView setNeedsDisplay];
                                             }
                                            ),
           @"title"       : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 NSAttributedString * title = NilSafeValue(change[NSKeyValueChangeNewKey]);
                                                 buttonView->_labelView.attributedText = title;
                                             }
                                            ),
           @"image"       : MSMakeKVOHandler(
                                             {
//                                                 [(__bridge REButtonView *)context updateState];
                                             }
                                            ),
           @"icon"        : MSMakeKVOHandler(
                                             {
                                                 REButtonView * buttonView = (__bridge REButtonView *)context;
                                                 UIImage * icon = NilSafeValue(change[NSKeyValueChangeNewKey]);
                                                 buttonView->_icon = icon;
                                                 [buttonView setNeedsDisplay];
                                             }
                                            )
        };

    return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}

/*
- (UIColor *)backgroundColor
{
    return self.model.backgroundColor;
}
*/

- (void)setEditingMode:(REEditingMode)editingMode
{
    [super setEditingMode:editingMode];
    _flags.commandsActive = (editingMode == REEditingModeNotEditing) ? YES : NO;
    [self updateGesturesEnabled:_flags.commandsActive];
}

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    if (_icon)
    {
        UIGraphicsPushContext(ctx);
        CGRect   insetRect = UIEdgeInsetsInsetRect(self.bounds, self.imageEdgeInsets);
        CGSize   imageSize = (CGSizeContainsSize(insetRect.size, _icon.size)
                              ? _icon.size
                              : CGSizeAspectMappedToSize(_icon.size, insetRect.size, YES));
        CGRect   imageRect = CGRectMake(CGRectGetMidX(insetRect) - imageSize.width / 2.0,
                                        CGRectGetMidY(insetRect) - imageSize.height / 2.0,
                                        imageSize.width,
                                        imageSize.height);

        if (_options.antialiasIcon)
        {
            CGContextSetAllowsAntialiasing(ctx, YES);
            CGContextSetShouldAntialias(ctx, YES);
        }

        [_icon drawInRect:imageRect];
        UIGraphicsPopContext();
    }
}

@end
