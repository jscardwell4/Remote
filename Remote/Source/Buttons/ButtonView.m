#import "Button.h"
#import "ButtonView.h"
#import "RemoteElementView_Private.h"
#import "ButtonGroup.h"
#import "Painter.h"
#import "MSRemoteConstants.h"

// #define DEBUG_BV_COLOR_BG
#define ANTIALIASTEXT              NO
#define ANTIALIASICON              NO
#define MIN_HIGHLIGHT_DURATION     0.5
#define AUTO_REMOVE_FROM_SUPERVIEW NO
#define RESIZABLE                  NO
#define MOVEABLE                   NO
#define CORNER_RADII               CGSizeMake(5.0f, 5.0f)
#define MIN_LINE_HEIGHT            44

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

// static const int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel)

@implementation ButtonView {
    NSMutableDictionary          * _actionHandlers;
    UITapGestureRecognizer       * _tapGesture;
    MSLongPressGestureRecognizer * _longPressGesture;
    RemoteElementLabelView       * _labelView;
    UIImage                      * _icon;
    UIActivityIndicatorView      * _activityIndicator;
    @protected
        struct {
        BOOL             activityIndicator;
        UIControlState   state;
        BOOL             longPressActive;
        BOOL             commandsActive;
        BOOL             highlightActionQueued;
        BOOL             initialized;
        BOOL             scaleTitleText;
    }
    _bvflags;

    struct {
        BOOL             antialiasIcon;
        BOOL             antialiasText;
        NSTimeInterval   minHighlightInterval;
    }
    _bvoptions;

    __weak Button * _button;
}

- (void)updateConstraints {
    MSKIT_STATIC_STRING_CONST   kButtonViewInternalNametag = @"ButtonViewInternal";
    MSKIT_STATIC_STRING_CONST   kButtonLabelNametag = @"ButtonViewLabel";
    MSKIT_STATIC_STRING_CONST   kButtonActivityIndicatorNametag = @"ButtonViewActivityIndicator";
    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:kButtonViewInternalNametag])
    {
        UIEdgeInsets   titleInsets = _button.titleEdgeInsets;
        NSString * constraints =
            [NSString stringWithFormat:
             @"'%1$@' _labelView.left = self.left + %3$f @900\n"
              "'%1$@' _labelView.top = self.top + %4$f @900\n"
              "'%1$@' _labelView.bottom = self.bottom - %5$f @900\n"
              "'%1$@' _labelView.right = self.right - %6$f @900\n"
              "'%2$@' _activityIndicator.centerX = self.centerX\n"
              "'%2$@' _activityIndicator.centerY = self.centerY",
              $(@"%@-%@", kButtonViewInternalNametag, kButtonLabelNametag),
              $(@"%@-%@", kButtonViewInternalNametag, kButtonActivityIndicatorNametag),
              titleInsets.left, titleInsets.top,
              titleInsets.bottom, titleInsets.right];

        NSDictionary * views = NSDictionaryOfVariableBindings(self, _labelView, _activityIndicator);

        [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

- (BOOL)                             gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

/*******************************************************************************
*  Single tap action executes the primary button command
*******************************************************************************/
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded : {
            self.highlighted = YES;

            int64_t           delayInSeconds = _bvoptions.minHighlightInterval * NSEC_PER_SEC;
            dispatch_time_t   popTime        = dispatch_time(DISPATCH_TIME_NOW,
                                                             delayInSeconds);

            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                _bvflags.highlightActionQueued = NO;
                self.highlighted = NO;
                [self setNeedsDisplay];
            }

                           );

            ButtonViewActionHandler   handler = _actionHandlers[@(ButtonViewSingleTapAction)];

            if (handler) handler();
            else [self buttonActionWithOptions:CommandOptionsDefault];
        }
        break;

        case UIGestureRecognizerStateCancelled : {
            if (!_bvflags.longPressActive) {
                self.highlighted = NO;
                [self setNeedsDisplay];
            }
        }
        break;

        case UIGestureRecognizerStateChanged :
        case UIGestureRecognizerStateBegan :
        case UIGestureRecognizerStateFailed :
        case UIGestureRecognizerStatePossible :
            break;
    }  /* switch */
}

- (void)handleLongPress:(MSLongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan : {
            ButtonViewActionHandler   handler =
                _actionHandlers[@(ButtonViewLongPressAction)];

            if (handler) handler();
            else [self buttonActionWithOptions:CommandOptionsLongPress];
        }
        break;

        case UIGestureRecognizerStatePossible : {
            _bvflags.longPressActive = YES;
            self.highlighted         = YES;
            [self setNeedsDisplay];
        }
        break;

        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateCancelled :
        case UIGestureRecognizerStateChanged :
        case UIGestureRecognizerStateFailed :
            break;
    }  /* switch */
}

- (void)updateGesturesEnabled:(BOOL)enabled {
    _tapGesture.enabled       = enabled;
    _longPressGesture.enabled = enabled;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications
////////////////////////////////////////////////////////////////////////////////

/**
 * Context change notification handler.
 * @param note The `NSNotification` object containing the context changes.
 */
- (void)contextNotification:(NSNotification *)note {
    NSSet * deletedObjects = [note.userInfo valueForKey:NSDeletedObjectsKey];

    if ([deletedObjects containsObject:_button]) {
        self.remoteElement = nil;
        [self removeFromSuperview];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ￼Button State
////////////////////////////////////////////////////////////////////////////////

- (void)updateState {
    UIControlState   currentState = UIControlStateNormal;

    if (self.selected) currentState |= UIControlStateSelected;

    if (!self.enabled) currentState |= UIControlStateDisabled;

    if (self.highlighted) currentState |= UIControlStateHighlighted;

    if (_bvflags.state != currentState) {
        if ((_bvflags.state & UIControlStateDisabled) != (currentState & UIControlStateDisabled)) self.userInteractionEnabled = !self.userInteractionEnabled;

        _labelView.attributedText = [self titleForState:currentState];
        _icon                     = [self iconForState:currentState];
        _bvflags.state            = currentState;
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Actions
////////////////////////////////////////////////////////////////////////////////

- (void)setActionHandler:(ButtonViewActionHandler)handler
               forAction:(ButtonViewAction)action {
    _actionHandlers[@(action)] = handler;
}

- (void)buttonActionWithOptions:(CommandOptions)options {
    assert(_button);
    if (!self.editing && _bvflags.commandsActive) {
        if (_bvflags.longPressActive) {
            _bvflags.longPressActive = NO;
            [self setNeedsDisplay];
        }

        if (_bvflags.activityIndicator) [_activityIndicator startAnimating];

        [_button executeCommandWithOptions:options delegate:self];
    }
}

- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    if (_activityIndicator && [_activityIndicator isAnimating]) {
        MSRunAsyncOnMain (^{[_activityIndicator stopAnimating]; }

                          );
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementView Overrides
////////////////////////////////////////////////////////////////////////////////

- (CGSize)intrinsicContentSize {
    return (CGSize) {UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric};
}

/*
 * - (void)updateConstraints {
 *  [super updateConstraints];
 *  MSLogDebug(REMOTE_F_C, @"%@\n%@",
 * ClassTagSelectorStringForInstance(self.displayName), self.constraints);
 * }
 */

- (CGSize)minimumSize {
    UIEdgeInsets   i = self.titleEdgeInsets;
    CGSize         s = CGSizeMake(i.left + i.right, i.top + i.bottom);

    if (_labelView.text) s.height += MIN_LINE_HEIGHT + _labelView.lineBreaks * MIN_LINE_HEIGHT;

    s.width  = MAX(s.width, RemoteElementMinimumSize.width);
    s.height = MAX(s.height, RemoteElementMinimumSize.height);
    if (self.proportionLock) {
        CGSize   c = self.bounds.size;

        if (c.width > c.height) s.height = (s.width * c.height) / c.width;
        else s.width = (s.height * c.width) / c.height;
    }

// MSLogDebug(REMOTE_F_C,
// @"%@\ni:%@\nproportionLock? %@\ns:%@",
// ClassTagSelectorStringForInstance(self.displayName),
// UIEdgeInsetsString(i),
// BOOLString(self.proportionLock),

// CGSizeString(s));
    return s;
}

- (void)addSubelementView:(RemoteElementView *)view
{}

- (void)removeSubelementView:(RemoteElementView *)view
{}

- (void)addSubelementViews:(NSSet *)views
{}

- (void)removeSubelementViews:(NSSet *)views
{}

- (NSArray *)subelementViews {
    return nil;
}

- (void)initializeIVARs {
    _bvflags.scaleTitleText = YES;
    _actionHandlers         = [@{} mutableCopy];
    _bvoptions.antialiasIcon        = ANTIALIASICON;
    _bvoptions.antialiasText        = ANTIALIASTEXT;
    self.cornerRadii                = CORNER_RADII;
    _bvoptions.minHighlightInterval = MIN_HIGHLIGHT_DURATION;
    _bvflags.commandsActive         = YES;
    self.resizable                  = RESIZABLE;
    self.moveable                   = MOVEABLE;
    [super initializeIVARs];
#ifdef DEBUG_BV_COLOR_BG
    self.backgroundColor = OrangeColor;
#endif
}

- (void)setRemoteElement:(RemoteElement *)remoteElement {
    [super setRemoteElement:remoteElement];
    _button = (Button *)self.remoteElement;
}

- (void)addInternalSubviews {
    [super addInternalSubviews];
    self.contentInteractionEnabled                       = NO;
    self.contentClipsToBounds                            = NO;
    self.clipsToBounds                                   = NO;
    _labelView                                           = [RemoteElementLabelView new];
    _labelView.translatesAutoresizingMaskIntoConstraints = NO;
    _labelView.numberOfLines                             = 0;
    _labelView.opaque                                    = NO;
    _labelView.minimumScaleFactor                        = 0;

#ifdef BUTTON_VIEW_DEBUG_LABELS
    _labelView.backgroundColor = [GreenColor colorWithAlphaComponent:0.5];
#else
    _labelView.backgroundColor = ClearColor;
#endif
    [self addViewToContent:_labelView];

    _activityIndicator =
        [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped                          = YES;
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _activityIndicator.color                                     = defaultTitleHighlightColor();
    [self addViewToOverlay:_activityIndicator];

}

- (void)attachGestureRecognizers {
    [super attachGestureRecognizers];
    _longPressGesture =
        [[MSLongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    _longPressGesture.delaysTouchesBegan = NO;
    _longPressGesture.delegate           = self;
    [self addGestureRecognizer:_longPressGesture];

    _tapGesture                         = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGesture.numberOfTapsRequired    = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    _tapGesture.delaysTouchesBegan      = NO;
    _tapGesture.delegate                = self;
    [self addGestureRecognizer:_tapGesture];
}

- (void)initializeViewFromModel {
    if (!self.remoteElement) return;

    [super initializeViewFromModel];

    _longPressGesture.enabled  = (_button.longPressCommand != nil);
    _bvflags.activityIndicator = [_button.command isKindOfClass:[MacroCommand class]];

    _labelView.attributedText = [_button titleForState:_bvflags.state];
    _icon                     = [_button iconForState:_bvflags.state];
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (NSDictionary *)kvoRegistration {
    __weak ButtonView * weakSelf        = self;
    __strong NSDictionary  * kvoRegistration = @{
                                            @"selected" : ^(MSKVOReceptionist * receptionist,
                                                             NSString * keyPath,
                                                             id object,
                                                             NSDictionary * change,
                                                             void * context)
        {
            [weakSelf updateState];
        },
                                            @"enabled" : ^(MSKVOReceptionist * receptionist,
                                                            NSString * keyPath,
                                                            id object,
                                                            NSDictionary * change,
                                                            void * context)
        {
            [weakSelf updateState];
        },
                                            @"highlighted" : ^(MSKVOReceptionist * receptionist,
                                                                NSString * keyPath,
                                                                id object,
                                                                NSDictionary * change,
                                                                void * context)
        {
            [weakSelf updateState];
        },
                                            @"command" : ^(MSKVOReceptionist * receptionist,
                                                            NSString * keyPath,
                                                            id object,
                                                            NSDictionary * change,
                                                            void * context)
        {
            _bvflags.activityIndicator = [_button.command isKindOfClass:[MacroCommand class]];
        },
                                            @"style" : ^(MSKVOReceptionist * receptionist,
                                                          NSString * keyPath,
                                                          id object,
                                                          NSDictionary * change,
                                                          void * context)
        {
            [weakSelf setNeedsDisplay];
        },
                                            @"titles" : ^(MSKVOReceptionist * receptionist,
                                                           NSString * keyPath,
                                                           id object,
                                                           NSDictionary * change,
                                                           void * context)
        {
            _labelView.attributedText = [weakSelf titleForState:_bvflags.state];
        }
                                          };

    return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}  /* kvoRegistration */

- (UIColor *)backgroundColor {
    return [self backgroundColorForState:_bvflags.state];
}

- (void)setEditingMode:(EditingMode)editingMode {
    [super setEditingMode:editingMode];
    _bvflags.commandsActive = (editingMode == EditingModeEditingNone) ? YES : NO;
    [self updateGesturesEnabled:_bvflags.commandsActive];
}

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    if (_icon) {
        CGRect   insetRect = UIEdgeInsetsInsetRect(self.bounds, self.imageEdgeInsets);
        CGSize   imageSize = CGSizeFitToSize(_icon.size, insetRect.size);
        CGRect   imageRect = CGRectMake(CGRectGetMidX(insetRect) - imageSize.width / 2.0,
                                        CGRectGetMidY(insetRect) - imageSize.height / 2.0,
                                        imageSize.width,
                                        imageSize.height);

        if (_bvoptions.antialiasIcon) {
            CGContextSetAllowsAntialiasing(ctx, YES);
            CGContextSetShouldAntialias(ctx, YES);
        }

        [_icon drawInRect:imageRect];
    }
}

@end

#import "GalleryImage.h"

#define kLightningTag      6
#define kFrameTag          5
#define kPlugTag           4
#define kDefaultFrameColor WhiteColor
#define kDefaultPlugColor  LightGrayColor
#define kDefaultFillColor  [UIColor lightTextColor]
#define kFrameState        UIControlStateNormal
#define kPlugState         UIControlStateSelected
#define kLightningState    UIControlStateDisabled

@implementation BatteryStatusButtonView {
    CGFloat                _batteryLevel; // How much of a charge the battery currently has.
    UIDeviceBatteryState   _batteryState; // What state the battery is currently in, i.e. charging,
                                          // full.
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)initializeIVARs {
    [super initializeIVARs];
    _frameColor     = kDefaultFrameColor;
    _fillColor      = kDefaultFillColor;
    _plugColor      = kDefaultPlugColor;
    _lightningColor = self.plugColor;
    _frameIcon      = [GalleryIconImage
                       fetchIconWithTag:kFrameTag
                                context:_button.managedObjectContext];
    [_button setIcon:self.frameIcon forState:kFrameState];
    [_button setIconColor:self.frameColor forState:kFrameState];
    _plugIcon = [GalleryIconImage
                 fetchIconWithTag:kPlugTag
                          context:_button.managedObjectContext];
    [_button setIcon:self.plugIcon forState:kPlugState];
    [_button setIconColor:self.plugColor forState:kPlugState];
    _lightingIcon = [GalleryIconImage
                     fetchIconWithTag:kLightningTag
                              context:_button.managedObjectContext];
    [_button setIcon:self.lightingIcon forState:kLightningState];
    [_button setIconColor:self.lightningColor forState:kLightningState];

    [self invalidateIntrinsicContentSize];

    if (TARGET_IPHONE_SIMULATOR) {
        _batteryLevel = 0.75;
        _batteryState = UIDeviceBatteryStateCharging;
    } else {
        _batteryLevel = [[UIDevice currentDevice] batteryLevel];
        _batteryState = [[UIDevice currentDevice] batteryState];
    }

    [CurrentDevice setBatteryMonitoringEnabled:YES];

    __weak BatteryStatusButtonView * bsBV = self;

    [NotificationCenter addObserverForName:UIDeviceBatteryLevelDidChangeNotification
                                    object:CurrentDevice
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification * note) {
                                    _batteryLevel = [CurrentDevice batteryLevel];
                                    [bsBV setNeedsDisplay];
                                }

    ];
    [NotificationCenter addObserverForName:UIDeviceBatteryStateDidChangeNotification
                                    object:CurrentDevice
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification * note) {
                                    _batteryState = [CurrentDevice batteryState];
                                    [bsBV setNeedsDisplay];
                                }

    ];
}  /* initializeIVARs */

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (CGSize)intrinsicContentSize {
    UIImage * iconImage = [self iconForState:kFrameState];

    return (iconImage
            ? iconImage.size
            : (CGSize) {UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric}
            );
}

/**
 * Overrides the `ButtonView` implementation to perform custom drawing of the 'battery' frame,
 * the fill color that indicates battery level, and the icon that indicates battery state.
 */
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    if (_batteryLevel == -1) {
        _batteryLevel = CurrentDevice.batteryLevel;
        _batteryState = CurrentDevice.batteryState;
    }

    UIImage * frameImage = [self iconForState:kFrameState];
    CGSize    frameSize  = CGSizeFitToSize(frameImage.size, rect.size);
    CGRect    frameRect  = CGRectMake(CGRectGetMidX(rect) - frameSize.width / 2.0,
                                      CGRectGetMidY(rect) - frameSize.height / 2.0,
                                      frameSize.width,
                                      frameSize.height);

    [frameImage drawInRect:frameRect];

    CGSize    iconSize    = frameRect.size;
    CGFloat   padding     = iconSize.width * 0.06;
    CGPoint   imageOrigin = frameRect.origin;
    CGRect    paintRect   = CGRectMake(imageOrigin.x + padding,
                                       imageOrigin.y + 1.5 * padding,
                                       iconSize.width - 4 * padding,
                                       iconSize.height - 3 * padding);

    paintRect.size.width *= _batteryLevel;

    UIBezierPath * path = [UIBezierPath bezierPathWithRect:paintRect];

    [self.fillColor setFill];
    [path fill];

    if (_batteryState == UIDeviceBatteryStateFull) {
        UIImage * plugImage = [self iconForState:kPlugState];

        [plugImage drawInRect:CGRectInset(frameRect, padding, padding)];
    } else if (_batteryState == UIDeviceBatteryStateCharging) {
        UIImage * lightningImage = [self iconForState:kLightningState];
        CGSize    lightingSize   = CGSizeFitToSize(lightningImage.size, CGRectInset(frameRect, padding, padding).size);
        CGRect    lightingRect   = frameRect;

        lightingRect.size     = lightingSize;
        lightingRect.origin.x = CGRectGetMidX(frameRect) - lightingSize.width / 2.0;
        lightingRect.origin.y = CGRectGetMidY(frameRect) - lightingSize.height / 2.0;
        [lightningImage drawInRect:lightingRect];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

- (void)attachGestureRecognizers
{}

@end

#define kDefaultIconTag 182

#import "ConnectionManager.h"

@implementation ConnectionStatusButtonView {}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)initializeIVARs {
    if (![self iconForState:UIControlStateNormal]) {
        [self setIcon:[GalleryIconImage fetchIconWithTag:kDefaultIconTag
                                                 context:_button.managedObjectContext]
             forState:UIControlStateNormal];
        [self setIconColor:GrayColor forState:UIControlStateNormal];
        [self setIconColor:WhiteColor forState:UIControlStateSelected];
        [self invalidateIntrinsicContentSize];
    }

    self.selected = [[ConnectionManager sharedConnectionManager] isWifiAvailable];

    __weak ConnectionStatusButtonView * csBV = self;

    [NotificationCenter addObserverForName:kConnectionStatusNotification
                                    object:[ConnectionManager sharedConnectionManager]
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification * note) {
                                    BOOL connected = [[note.userInfo
                                    valueForKey:kConnectionStatusWifiAvailable] boolValue];
                                    if (csBV.selected != connected) ((Button *)csBV.remoteElement).selected = connected;
                                }

    ];
    [super initializeIVARs];
}

- (CGSize)intrinsicContentSize {
    UIImage * iconImage = [self iconForState:UIControlStateNormal];

    return (iconImage
            ? iconImage.size
            : (CGSize) {UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric}
            );
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

- (void)attachGestureRecognizers
{}

@end
