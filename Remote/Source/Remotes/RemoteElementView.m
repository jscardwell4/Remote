//
// RemoteElementView.m
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "RemoteElementView_Private.h"
#import "RemoteElementViewConstraintManager.h"
#import "RemoteView.h"
#import "MSRemoteConstants.h"
#import "ButtonGroup.h"
#import "ButtonGroupView.h"
#import "Painter.h"
#import "ButtonView.h"
#import <MSKit/MSKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

#define AUTO_REMOVE_FROM_SUPERVIEW      NO
#define NEEDS_DISPLAY_TRICKLES_DOWN     YES
#define UPDATE_FROM_MODEL_TRICKLES_DOWN NO
#define VIEW_CLIPS_TO_BOUNDS            NO

// static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int   ddLogLevel               = DefaultDDLogLevel;
CGSize const       RemoteElementMinimumSize = (CGSize) {.width = 44.0f, .height = 44.0f};

@implementation RemoteElementView {
    NSMutableDictionary    * _kvoReceptionists;
    NSManagedObjectContext * _context;
}

+ (RemoteElementView *)remoteElementViewWithElement:(RemoteElement *)element {
                assert(element && ![element isFault]);
    switch ((uint64_t)element.type) {
        case RemoteElementRemoteType :

            return [[RemoteView alloc] initWithRemoteElement:element];

        case ButtonGroupTypeSelectionPanel :

            return [[SelectionPanelButtonGroupView alloc] initWithRemoteElement:element];

        case ButtonGroupTypePickerLabel :

            return [[PickerLabelButtonGroupView alloc] initWithRemoteElement:element];

        case ButtonGroupTypeRoundedPanel :

            return [[RoundedPanelButtonGroupView alloc] initWithRemoteElement:element];

        case ButtonGroupTypeToolbar :
        case ButtonGroupTypeCommandSetManager :
        case ButtonGroupTypeTransport :
        case ButtonGroupTypeDPad :
        case RemoteElementButtonGroupType :

            return [[ButtonGroupView alloc] initWithRemoteElement:element];

        case ButtonTypeConnectionStatus :

            return [[ConnectionStatusButtonView alloc] initWithRemoteElement:element];

        case ButtonTypeBatteryStatus :

            return [[BatteryStatusButtonView alloc] initWithRemoteElement:element];

        case ButtonTypeActivityButton :
        case RemoteElementButtonType :

            return [[ButtonView alloc] initWithRemoteElement:element];

        case RemoteElementUnspecifiedType :
        default :
                assert(NO); return nil;
    }  /* switch */
}

/**
 * Default initializer for subclasses.
 */
- (id)initWithRemoteElement:(RemoteElement *)element {
    if (self = [super init]) {
        self.remoteElement = element;
        [self initializeIVARs];
    }

    return self;
}

/**
 * Called from `initWithRemoteElement:`, subclasses that override should include a call to `super`.
 */
- (void)initializeIVARs {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds                             = VIEW_CLIPS_TO_BOUNDS;
    self.opaque                                    = NO;
    self.multipleTouchEnabled                      = YES;
    self.userInteractionEnabled                    = YES;
    self.constraintManager                         = [RemoteElementViewConstraintManager constraintManagerForView:self];
    [self addInternalSubviews];
    [self attachGestureRecognizers];
    [self initializeViewFromModel];
}

/**
 * Forwards to `RemoteElement` model.
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    id   target = (_remoteElement && [_remoteElement respondsToSelector:aSelector]
                   ? _remoteElement
                   :[super forwardingTargetForSelector:aSelector]);

    return target;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return (_remoteElement
            ?[_remoteElement valueForKey:key]
            :[super valueForUndefinedKey:key]);
}

/**
 * Unregisters as observer for model KVO notifications.
 */
- (void)dealloc {
    [self unregisterForChangeNotification];
}

/**
 * Override point for subclasses to return an array of KVO registration dictionaries for observing
 * model keypaths.
 */
- (NSArray *)kvoRegistration {
    __weak RemoteElementView * weakSelf        = self;
    __strong NSArray         * kvoRegistration = @[
                                                   @[@"constraints", ^(MSKVOReceptionist * receptionist,
                                                                       NSString * keyPath,
                                                                       id object,
                                                                       NSDictionary * change,
                                                                       void * context)
        {
            [weakSelf setNeedsUpdateConstraints];
            [weakSelf updateConstraintsIfNeeded];
        }

                                                   ],
                                                   @[@"backgroundColor", ^(MSKVOReceptionist * receptionist,
                                                                           NSString * keyPath,
                                                                           id object,
                                                                           NSDictionary * change,
                                                                           void * context)
        {
            if ([change[NSKeyValueChangeNewKey] isKindOfClass:[UIColor class]]) weakSelf.backgroundColor = change[NSKeyValueChangeNewKey];
            else weakSelf.backgroundColor = nil;
        }

                                                   ],
                                                   @[@"backgroundImage", ^(MSKVOReceptionist * receptionist,
                                                                           NSString * keyPath,
                                                                           id object,
                                                                           NSDictionary * change,
                                                                           void * context)
        {
            if ([change[NSKeyValueChangeNewKey] isKindOfClass:[GalleryImage class]])
                weakSelf.backgroundImageView.image = [(GalleryImage *)change[NSKeyValueChangeNewKey]
                                                      stretchableImage];
            else
                weakSelf.backgroundImageView.image = nil;
        }

                                                   ],
                                                   @[@"backgroundImageAlpha", ^(MSKVOReceptionist * receptionist,
                                                                                NSString * keyPath,
                                                                                id object,
                                                                                NSDictionary * change,
                                                                                void * context)
        {
            if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]]) _backgroundImageView.alpha = [change[NSKeyValueChangeNewKey] floatValue];
        }

                                                   ],
                                                   @[@"shape", ^(MSKVOReceptionist * receptionist,
                                                                 NSString * keyPath,
                                                                 id object,
                                                                 NSDictionary * change,
                                                                 void * context)
        {
            weakSelf.bounds = weakSelf.bounds;
        }

                                                   ]
                                                 ];

    return kvoRegistration;
}  /* kvoRegistration */

/**
 * Override point for subclasses to attach gestures. Called from `initWithRemoteElement`.
 */
- (void)attachGestureRecognizers
{}

/**
 * Registers as observer for keypaths of model that appear in the array retained by subclass for
 * `kvoKeypaths`.
 */
- (void)registerForChangeNotification {
    if (_remoteElement) {
        NSArray * keyPathRegistration = [self kvoRegistration];

        if (!_kvoReceptionists)
            _kvoReceptionists = [NSMutableDictionary
                                 dictionaryWithCapacity:keyPathRegistration.count];

        if (keyPathRegistration)
            for (NSArray * keyHandlerPair in keyPathRegistration) {
                MSKVOReceptionist * receptionist =
                    [MSKVOReceptionist receptionistForObject:_remoteElement
                                                     keyPath:keyHandlerPair[0]
                                                     options:NSKeyValueObservingOptionNew
                                                     context:NULL
                                                     handler:keyHandlerPair[1]
                                                       queue:[NSOperationQueue mainQueue]];

                assert(receptionist);
                _kvoReceptionists[keyHandlerPair[0]] = receptionist;
            }
    }
}

/**
 * Removes registration for keypaths observed via `registerForChangeNotification`.
 */
- (void)unregisterForChangeNotification {
    [_kvoReceptionists removeAllObjects];
}

/**
 * Override point for subclasses to update themselves with data from the model.
 */
- (void)initializeViewFromModel {
    if (!_remoteElement) {
        if (AUTO_REMOVE_FROM_SUPERVIEW) {
            DDLogDebug(@"%@\n\tnil button group model, removing self from superview",
                       ClassTagSelectorString);
            [self removeFromSuperview];
        }

        return;
    }

    self.accessibilityLabel = self.displayName;
    if (!self.accessibilityLabel) self.accessibilityLabel = self.key;

    __weak RemoteElementView * weakSelf = self;

    // *** block was causing deadlock
    // [_remoteElement.managedObjectContext performBlockAndWait:^{
    weakSelf.backgroundColor   = _remoteElement.backgroundColor;
    _backgroundImageView.image = (_remoteElement.backgroundImage
                                  ?[_remoteElement.backgroundImage stretchableImage]
                                  : nil);
    // }];

    [self.subelementViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (RemoteElement * re in _remoteElement.subelements) {
        [self addSubelementView:[RemoteElementView remoteElementViewWithElement:
                                 (RemoteElement *)[re.managedObjectContext
                                                   existingObjectWithID:re.objectID
                                                                  error:nil]]];
    }

    [self.constraintManager refreshConstraints];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing constraints
////////////////////////////////////////////////////////////////////////////////

- (void)updateSubelementOrderFromView {
    _remoteElement.subelements = [NSOrderedSet orderedSetWithArray:
                                  [self.subelementViews
                                   valueForKey:@"remoteElement"]];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation {
    [self.constraintManager translateSubelements:subelementViews translation:translation];
}

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale
{}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute {
    [self.constraintManager alignSubelements:subelementViews toSibling:siblingView attribute:attribute];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute {
    [self.constraintManager resizeSubelements:subelementViews toSibling:siblingView attribute:attribute];
}

/**
 * Returns the model's display name or nil if no model.
 */
- (NSString *)displayName {
    return (_remoteElement ? _remoteElement.displayName : nil);
}

/**
 * Returns the model's key or nil if no model.
 */
- (NSString *)key {
    return (_remoteElement ? _remoteElement.key : nil);
}

- (BOOL)isEditing {
    return (self.type & _editingMode);
}

/**
 * Searches content view for subviews of the appropriate type and returns them as an array.
 */
- (NSArray *)subelementViews {
    return [_contentView.subviews
            filteredArrayUsingPredicateWithBlock:^BOOL (id evaluatedObject, NSDictionary * bindings) {
        return [evaluatedObject isKindOfClass:[RemoteElementView class]];
    }

    ];
}

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx {
    NSArray * subelements = self.subelementViews;

    if (subelements.count > 0 && idx < subelements.count) return subelements[idx];
    else return nil;
}

- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key {
    return [self.subelementViews
            objectPassingTest:^BOOL (RemoteElementView * obj, NSUInteger idx, BOOL * stop) {
        return (([key isEqualToString:obj.key] || [key isEqualToString:obj.identifier]) && (*stop = YES));
    }

    ];
}

- (RemoteElementView *)subelementViewForIdentifier:(NSString *)identifier {
    return [self.subelementViews
            objectPassingTest:^BOOL (RemoteElementView * obj, NSUInteger idx, BOOL * stop) {
        return ([identifier isEqualToString:obj.identifier] && (*stop = YES));
    }

    ];
}

/**
 * Sets the model and registers for KVO.
 */
- (void)setRemoteElement:(RemoteElement *)remoteElement {
    if (_remoteElement == remoteElement) return;

    if (_remoteElement) [self unregisterForChangeNotification];

    NSError * error = nil;

    _remoteElement = (RemoteElement *)[remoteElement.managedObjectContext
                                       existingObjectWithID:remoteElement.objectID
                                                      error:&error];

    if (error) {
        DDLogError(@"%@ failed to set remote", ClassTagSelectorString);
        _remoteElement = nil;
    } else
        _context = _remoteElement.managedObjectContext;

    if ([_remoteElement isFault]) DDLogDebug(@"%@ remote is faulted, possibly a new context insertion", ClassTagSelectorString);

    _remoteElement = remoteElement;
    [self registerForChangeNotification];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - EditableView Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (CGSize)minimumSize {
    // TODO: Constraints will need to be handled eventually
    if (!self.subelementViews.count) return RemoteElementMinimumSize;

    NSMutableArray * xAxisRanges = [@[] mutableCopy];
    NSMutableArray * yAxisRanges = [@[] mutableCopy];

    // build collections holding ranges that represent x and y axis coverage for subelement frames
    [self.subelementViews
     enumerateObjectsUsingBlock:^(ButtonView * obj, NSUInteger idx, BOOL * stop) {
         CGSize min = obj.minimumSize;
         CGPoint org = obj.frame.origin;
         [xAxisRanges addObject:RangeValue(NSMakeRange(org.x, min.width))];
         [yAxisRanges addObject:RangeValue(NSMakeRange(org.y, min.height))];
     }

    ];

    // sort collections by range location
    [xAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2) {
        NSRange r1 = Range(obj1);
        NSRange r2 = Range(obj2);

        return (r1.location < r2.location
                ? NSOrderedAscending
                : (r1.location > r2.location
                   ? NSOrderedDescending
                   : NSOrderedSame));
    }

    ];

    [yAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2) {
        NSRange r1 = Range(obj1);
        NSRange r2 = Range(obj2);

        return (r1.location < r2.location
                ? NSOrderedAscending
                : (r1.location > r2.location
                   ? NSOrderedDescending
                   : NSOrderedSame));
    }

    ];

    // join ranges that intersect to create collections of non-intersecting ranges
    int   joinCount;

    do {
        NSRange   tmpRange = Range(xAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < xAxisRanges.count; i++) {
            NSRange   r = Range(xAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0) {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            } else {
                [a addObject:RangeValue(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:RangeValue(tmpRange)];
        xAxisRanges = a;
    } while (joinCount);

    do {
        NSRange   tmpRange = Range(yAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < yAxisRanges.count; i++) {
            NSRange   r = Range(yAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0) {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            } else {
                [a addObject:RangeValue(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:RangeValue(tmpRange)];
        yAxisRanges = a;
    } while (joinCount);

    // calculate min size and width by summing range lengths
    CGFloat   minWidth = Float([[xAxisRanges
                                 arrayByMappingToBlock:^id (NSValue * obj, NSUInteger idx) {
                return @(Range(obj).length);
            }

                                ]
                                valueForKeyPath:@"@sum.self"]);
    CGFloat   minHeight = Float([[yAxisRanges
                                  arrayByMappingToBlock:
                                  ^id (NSValue * obj, NSUInteger idx) {
                NSRange r = Range(obj);

                return @(r.length);
            }

                                 ]
                                 valueForKeyPath:@"@sum.self"]);
    CGSize   s = CGSizeMake(minWidth, minHeight);

    if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, NO);

// MSLogDebug(REMOTE_F_C,
// @"%@\nxAxisRanges:%@\nyAxisRanges:%@\nminWidth:%.2f\nminHeight:%.2f\nproportionLock? %@\ns:%@",
// ClassTagSelectorStringForInstance(self.displayName),
// xAxisRanges,
// yAxisRanges,
// minWidth,
// minHeight,
// NSStringFromBOOL(self.proportionLock),
// NSStringFromCGSize(s));

    return s;
}  /* minimumSize */

- (CGSize)maximumSize {
    // FIXME: Doesn't account for maximum sizes of subelement views
    // to begin with, view must fit inside its superview
    CGSize   s = self.superview.bounds.size;

    // TODO: Eventually must handle size-related constraints
    if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, YES);

    return s;
// return CGSizeMax;
}

/**
 * Sets border color according to current editing style.
 */
- (void)setEditingStyle:(EditingStyle)editingStyle {
    _editingStyle = editingStyle;

    _overlayView.showAlignmentIndicators = (_editingStyle == EditingStyleMoving ? YES : NO);
    _overlayView.showContentBoundary     = (_editingStyle ? YES : NO);
    switch (_editingStyle) {
        case EditingStyleSelected :
            _overlayView.boundaryColor = YellowColor;
            break;

        case EditingStyleMoving :
            _overlayView.boundaryColor = BlueColor;
            break;

        case EditingStyleFocus :
            _overlayView.boundaryColor = RedColor;
            break;

        default :
            _overlayView.boundaryColor = ClearColor;
            break;
    }

    assert([self.subviews objectAtIndex:self.subviews.count - 1] == _overlayView);
    [_overlayView.layer setNeedsDisplay];
}

/**
 * Adds the backdrop, content, and overlay views. Subclasses that override should call `super`.
 */
- (void)addInternalSubviews {
    self.backdropView = [[RemoteElementBackdropView alloc] initWithRemoteElementView:self];
    [self addSubview:_backdropView];
    _backgroundImageView                                           = [UIImageView new];
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImageView.contentMode                               = UIViewContentModeScaleToFill;
    _backgroundImageView.opaque                                    = NO;
    _backgroundImageView.backgroundColor                           = ClearColor;
    [self.backdropView addSubview:_backgroundImageView];
    self.contentView = [[RemoteElementContentView alloc] initWithRemoteElementView:self];
    [self addSubview:_contentView];
    self.overlayView = [[RemoteElementOverlayView alloc] initWithRemoteElementView:self];
    [self addSubview:_overlayView];

    NSDictionary * views = NSDictionaryOfVariableBindings(self,
                                                          _backdropView,
                                                          _backgroundImageView,
                                                          _contentView,
                                                          _overlayView);
    NSString * constraints =
        @"_backdropView.width = self.width\n"
        "_backdropView.height = self.height\n"
        "_backdropView.centerX = self.centerX\n"
        "_backdropView.centerY = self.centerY\n"
        "_backgroundImageView.width = self.width\n"
        "_backgroundImageView.height = self.height\n"
        "_backgroundImageView.centerX = self.centerX\n"
        "_backgroundImageView.centerY = self.centerY\n"
        "_contentView.width = self.width\n"
        "_contentView.height = self.height\n"
        "_contentView.centerX = self.centerX\n"
        "_contentView.centerY = self.centerY\n"
        "_overlayView.width = self.width\n"
        "_overlayView.height = self.height\n"
        "_overlayView.centerX = self.centerX\n"
        "_overlayView.centerY = self.centerY";

    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                  views:views]];
}

- (void)addSubelementView:(RemoteElementView *)view {
    view.parentElementView = self;
    [self.contentView addSubview:view];
}

- (void)removeSubelementView:(RemoteElementView *)view {
    [view removeFromSuperview];
}

- (void)addSubelementViews:(NSSet *)views {
    for (RemoteElementView * view in views) {
        [self addSubelementView:view];
    }
}

- (void)removeSubelementViews:(NSSet *)views {
    for (RemoteElementView * view in views) {
        [self removeSubelementView:view];
    }
}

/**
 * Overridden to also call `setNeedsDisplay` on backdrop, content, and overlay subviews.
 */
- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    if (NEEDS_DISPLAY_TRICKLES_DOWN) {
        [_backdropView setNeedsDisplay];
        [_contentView setNeedsDisplay];
        [_overlayView setNeedsDisplay];
    }
}

/**
 * Override point for subclasses to draw into the content subview.
 */
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect
{}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    switch (self.shape) {
        case RemoteElementShapeRectangle :
            self.borderPath = [UIBezierPath bezierPathWithRect:self.bounds];
            break;

        case RemoteElementShapeRoundedRectangle :
            self.borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    byRoundingCorners:UIRectCornerAllCorners
                                                          cornerRadii:_options.cornerRadii];
            break;

        case RemoteElementShapeOval :
            self.borderPath = [Painter stretchedOvalFromRect:self.bounds];
            break;

        case RemoteElementShapeTriangle :
        case RemoteElementShapeDiamond :
        default :
            self.borderPath = nil;
            break;
    }  /* switch */
}

- (void)setBorderPath:(UIBezierPath *)borderPath {
    _borderPath = borderPath;
    if (_borderPath) {
        self.layer.mask                        = [CAShapeLayer layer];
        ((CAShapeLayer *)self.layer.mask).path = [_borderPath CGPath];
    } else
        self.layer.mask = nil;
}

/**
 * Override point for subclasses to draw into the backdrop subview.
 */
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    if (_borderPath) {
        UIGraphicsPushContext(ctx);
        [self.backgroundColor setFill];
        [_borderPath fill];
        UIGraphicsPopContext();
    }
}

/**
 * Override point for subclasses to draw into the overlay subview.
 */
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    UIBezierPath * path = (_borderPath
                           ?[UIBezierPath bezierPathWithCGPath:_borderPath.CGPath]
                           :[UIBezierPath bezierPathWithRect:self.bounds]);

    UIGraphicsPushContext(ctx);
    [path addClip];
    if (self.style & RemoteElementStyleApplyGloss)
        [Painter drawGlossGradientWithColor:defaultGlossColor()
                                     inRect:self.bounds
                                  inContext:UIGraphicsGetCurrentContext()];

    path.lineWidth     = 3.0;
    path.lineJoinStyle = kCGLineJoinRound;
    if (self.style & RemoteElementStyleDrawBorder) {
        [BlackColor setStroke];
        [path stroke];
    }

    UIGraphicsPopContext();
}

@end
#define SUBVIEW_CLIPS_TO_BOUNDS     NO
#define SUBVIEW_AUTORESIZE_SUBVIEWS NO
#define SUBVIEW_CONTENT_MODE        UIViewContentModeRedraw

@implementation RemoteElementViewInternalSubview

@synthesize remoteElementView = _remoteElementView;

- (id)initWithRemoteElementView:(RemoteElementView *)remoteElementView {
    if (remoteElementView && (self = [super init])) {
        _remoteElementView                             = remoteElementView;
        self.userInteractionEnabled                    = [self isMemberOfClass:[RemoteElementContentView class]];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor                           = ClearColor;
        self.clipsToBounds                             = SUBVIEW_CLIPS_TO_BOUNDS;
        self.contentMode                               = SUBVIEW_CONTENT_MODE;
        self.autoresizesSubviews                       = SUBVIEW_AUTORESIZE_SUBVIEWS;
    }

    return self;
}

@end

@implementation RemoteElementContentView {}

/**
 * Calls `drawContentInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect {
    [self.remoteElementView drawContentInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation RemoteElementBackdropView {}

/**
 * Calls `drawBackdropInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect {
    [self.remoteElementView drawBackdropInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@interface RemoteElementOverlayView ()
@property (nonatomic, strong) CAShapeLayer * boundaryOverlay;
@property (nonatomic, strong) CALayer      * alignmentOverlay;

@end

@implementation RemoteElementOverlayView {
    CGSize     _renderedSize;
    uint64_t   _renderedAlignmentOptions;
}

#define PAINT_WITH_STROKE

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    assert(object == self.remoteElementView);
    if ([@"borderPath" isEqualToString : keyPath]) {
        __weak RemoteElementOverlayView * weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          _boundaryOverlay.path = [weakSelf boundaryPath];
                                      }

        ];
    }
}

- (CGPathRef)boundaryPath {
    assert(_boundaryOverlay);

    UIBezierPath * path = self.remoteElementView.borderPath;

    if (!path) path = [UIBezierPath bezierPathWithRect:self.bounds];

    CGSize         size         = self.bounds.size;
    CGFloat        lineWidth    = _boundaryOverlay.lineWidth;
    UIBezierPath * innerPath    = [UIBezierPath bezierPathWithCGPath:path.CGPath];
    CGPathRef      boundaryPath = NULL;

#ifdef PAINT_WITH_STROKE
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - lineWidth) / size.width, (size.height - lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth / 2, lineWidth / 2)];
    boundaryPath = innerPath.CGPath;
#else
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - 2 * lineWidth) / size.width, (size.height - 2 * lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth, lineWidth)];
    [path appendPath:innerPath];
    boundaryPath = path.CGPath;
#endif /* ifdef PAINT_WITH_STROKE */
    return boundaryPath;
}

- (CALayer *)boundaryOverlay {
    if (!_boundaryOverlay) {
        self.boundaryOverlay = [CAShapeLayer layer];
#ifdef PAINT_WITH_STROKE
        _boundaryOverlay.lineWidth   = 2.0;
        _boundaryOverlay.lineJoin    = kCALineJoinRound;
        _boundaryOverlay.fillColor   = NULL;
        _boundaryOverlay.strokeColor = _boundaryColor.CGColor;
#else
        _boundaryOverlay.fillColor   = _boundaryColor.CGColor;
        _boundaryOverlay.strokeColor = nil;
        _boundaryOverlay.fillRule    = kCAFillRuleEvenOdd;
#endif  /* ifdef PAINT_WITH_STROKE */
        _boundaryOverlay.path = [self boundaryPath];
        [self.layer addSublayer:_boundaryOverlay];
        _boundaryOverlay.hidden = !_showContentBoundary;
        [self.remoteElementView
         addObserver:self
          forKeyPath:@"borderPath"
             options:NSKeyValueObservingOptionNew
             context:NULL];
    }

    return _boundaryOverlay;
}

- (void)dealloc {
    [self.remoteElementView removeObserver:self forKeyPath:@"borderPath"];
}

- (void)setShowContentBoundary:(BOOL)showContentBoundary {
    _showContentBoundary    = showContentBoundary;
    _boundaryOverlay.hidden = !_showContentBoundary;
}

- (void)setBoundaryColor:(UIColor *)boundaryColor {
    _boundaryColor = boundaryColor;
#ifdef PAINT_WITH_STROKE
    self.boundaryOverlay.strokeColor = _boundaryColor.CGColor;
#else
    self.boundaryOverlay.fillColor = _boundaryColor.CGColor;
#endif
    [_boundaryOverlay setNeedsDisplay];
}

- (CALayer *)alignmentOverlay {
    if (!_alignmentOverlay) {
        self.alignmentOverlay   = [CALayer layer];
        _alignmentOverlay.frame = self.layer.bounds;
        [self.layer addSublayer:_alignmentOverlay];
        _alignmentOverlay.hidden = !_showAlignmentIndicators;
    }

    return _alignmentOverlay;
}

- (void)setShowAlignmentIndicators:(BOOL)showAlignmentIndicators {
    _showAlignmentIndicators = showAlignmentIndicators;
    [self renderAlignmentOverlayIfNeeded];
}

- (void)renderAlignmentOverlayIfNeeded {
    self.alignmentOverlay.hidden = !_showAlignmentIndicators;

    RemoteElementAlignmentOptions   alignmentOptions = self.remoteElementView.alignmentOptions;

    if (!_showAlignmentIndicators || alignmentOptions == _renderedAlignmentOptions) return;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    //// General Declarations
    CGContextRef   context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor * gentleHighlight = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor * parentAligned   = [UIColor colorWithRed:0.899 green:0.287 blue:0.238 alpha:1];
    UIColor * focusAligned    = [UIColor colorWithRed:0.186 green:0.686 blue:0.661 alpha:1];

    //// Shadow Declarations
    UIColor * outerHighlight                 = gentleHighlight;
    CGSize    outerHighlightOffset           = CGSizeMake(0.1, -0.1);
    CGFloat   outerHighlightBlurRadius       = 2.5;
    UIColor * innerHighlightLeft             = gentleHighlight;
    CGSize    innerHighlightLeftOffset       = CGSizeMake(-1.1, -0.1);
    CGFloat   innerHighlightLeftBlurRadius   = 0.5;
    UIColor * innerHighlightRight            = gentleHighlight;
    CGSize    innerHighlightRightOffset      = CGSizeMake(1.1, -0.1);
    CGFloat   innerHighlightRightBlurRadius  = 0.5;
    UIColor * innerHighlightTop              = gentleHighlight;
    CGSize    innerHighlightTopOffset        = CGSizeMake(0.1, -1.1);
    CGFloat   innerHighlightTopBlurRadius    = 0.5;
    UIColor * innerHighlightBottom           = gentleHighlight;
    CGSize    innerHighlightBottomOffset     = CGSizeMake(0.1, 1.1);
    CGFloat   innerHighlightBottomBlurRadius = 0.5;
    UIColor * innerHighlightCenter           = gentleHighlight;
    CGSize    innerHighlightCenterOffset     = CGSizeMake(0.1, -0.1);
    CGFloat   innerHighlightCenterBlurRadius = 0.5;

    //// Frames
    CGRect   frame = CGRectInset(self.bounds, 3.0, 3.0);

    //// Abstracted Attributes
    CGRect    leftBarRect            = CGRectMake(CGRectGetMinX(frame) + 1, CGRectGetMinY(frame) + 3, 2, CGRectGetHeight(frame) - 6);
    CGFloat   leftBarCornerRadius    = 1;
    CGRect    rightBarRect           = CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 3, CGRectGetMinY(frame) + 3, 2, CGRectGetHeight(frame) - 6);
    CGFloat   rightBarCornerRadius   = 1;
    CGRect    topBarRect             = CGRectMake(CGRectGetMinX(frame) + 4, CGRectGetMinY(frame) + 1, CGRectGetWidth(frame) - 8, 2);
    CGFloat   topBarCornerRadius     = 1;
    CGRect    bottomBarRect          = CGRectMake(CGRectGetMinX(frame) + 4, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 3, CGRectGetWidth(frame) - 8, 2);
    CGFloat   bottomBarCornerRadius  = 1;
    CGRect    centerXBarRect         = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 2) * 0.50000) + 0.5, CGRectGetMinY(frame) + 4, 2, CGRectGetHeight(frame) - 7);
    CGFloat   centerXBarCornerRadius = 1;
    CGRect    centerYBarRect         = CGRectMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 2) * 0.50000 + 0.5), CGRectGetWidth(frame) - 8, 2);
    CGFloat   centerYBarCornerRadius = 1;

    if (alignmentOptions & RemoteElementAlignmentOptionLeftMask) {
        //// Left Bar Drawing
        UIBezierPath * leftBarPath = [UIBezierPath bezierPathWithRoundedRect:leftBarRect cornerRadius:leftBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionLeftFocus) ? focusAligned : parentAligned setFill];
        [leftBarPath fill];

        ////// Left Bar Inner Shadow
        CGRect   leftBarBorderRect = CGRectInset([leftBarPath bounds], -innerHighlightLeftBlurRadius, -innerHighlightLeftBlurRadius);

        leftBarBorderRect = CGRectOffset(leftBarBorderRect, -innerHighlightLeftOffset.width, -innerHighlightLeftOffset.height);
        leftBarBorderRect = CGRectInset(CGRectUnion(leftBarBorderRect, [leftBarPath bounds]), -1, -1);

        UIBezierPath * leftBarNegativePath = [UIBezierPath bezierPathWithRect:leftBarBorderRect];

        [leftBarNegativePath appendPath:leftBarPath];
        leftBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightLeftOffset.width + round(leftBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightLeftOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightLeftBlurRadius,
                                        innerHighlightLeft.CGColor);

            [leftBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(leftBarBorderRect.size.width), 0);

            [leftBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [leftBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (alignmentOptions & RemoteElementAlignmentOptionRightMask) {
        //// Right Bar Drawing
        UIBezierPath * rightBarPath = [UIBezierPath bezierPathWithRoundedRect:rightBarRect cornerRadius:rightBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionRightFocus) ? focusAligned : parentAligned setFill];
        [rightBarPath fill];

        ////// Right Bar Inner Shadow
        CGRect   rightBarBorderRect = CGRectInset([rightBarPath bounds], -innerHighlightRightBlurRadius, -innerHighlightRightBlurRadius);

        rightBarBorderRect = CGRectOffset(rightBarBorderRect, -innerHighlightRightOffset.width, -innerHighlightRightOffset.height);
        rightBarBorderRect = CGRectInset(CGRectUnion(rightBarBorderRect, [rightBarPath bounds]), -1, -1);

        UIBezierPath * rightBarNegativePath = [UIBezierPath bezierPathWithRect:rightBarBorderRect];

        [rightBarNegativePath appendPath:rightBarPath];
        rightBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightRightOffset.width + round(rightBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightRightOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightRightBlurRadius,
                                        innerHighlightRight.CGColor);

            [rightBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(rightBarBorderRect.size.width), 0);

            [rightBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [rightBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (alignmentOptions & RemoteElementAlignmentOptionTopMask) {
        //// Top Bar Drawing
        UIBezierPath * topBarPath = [UIBezierPath bezierPathWithRoundedRect:topBarRect cornerRadius:topBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionTopFocus) ? focusAligned : parentAligned setFill];
        [topBarPath fill];

        ////// Top Bar Inner Shadow
        CGRect   topBarBorderRect = CGRectInset([topBarPath bounds], -innerHighlightTopBlurRadius, -innerHighlightTopBlurRadius);

        topBarBorderRect = CGRectOffset(topBarBorderRect, -innerHighlightTopOffset.width, -innerHighlightTopOffset.height);
        topBarBorderRect = CGRectInset(CGRectUnion(topBarBorderRect, [topBarPath bounds]), -1, -1);

        UIBezierPath * topBarNegativePath = [UIBezierPath bezierPathWithRect:topBarBorderRect];

        [topBarNegativePath appendPath:topBarPath];
        topBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightTopOffset.width + round(topBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightTopOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightTopBlurRadius,
                                        innerHighlightTop.CGColor);

            [topBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(topBarBorderRect.size.width), 0);

            [topBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [topBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (alignmentOptions & RemoteElementAlignmentOptionBottomMask) {
        //// Bottom Bar Drawing
        UIBezierPath * bottomBarPath = [UIBezierPath bezierPathWithRoundedRect:bottomBarRect cornerRadius:bottomBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionBottomFocus) ? focusAligned : parentAligned setFill];
        [bottomBarPath fill];

        ////// Bottom Bar Inner Shadow
        CGRect   bottomBarBorderRect = CGRectInset([bottomBarPath bounds], -innerHighlightBottomBlurRadius, -innerHighlightBottomBlurRadius);

        bottomBarBorderRect = CGRectOffset(bottomBarBorderRect, -innerHighlightBottomOffset.width, -innerHighlightBottomOffset.height);
        bottomBarBorderRect = CGRectInset(CGRectUnion(bottomBarBorderRect, [bottomBarPath bounds]), -1, -1);

        UIBezierPath * bottomBarNegativePath = [UIBezierPath bezierPathWithRect:bottomBarBorderRect];

        [bottomBarNegativePath appendPath:bottomBarPath];
        bottomBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightBottomOffset.width + round(bottomBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightBottomOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightBottomBlurRadius,
                                        innerHighlightBottom.CGColor);

            [bottomBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(bottomBarBorderRect.size.width), 0);

            [bottomBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [bottomBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (alignmentOptions & RemoteElementAlignmentOptionCenterXMask) {
        //// Center X Bar Drawing
        UIBezierPath * centerXBarPath = [UIBezierPath bezierPathWithRoundedRect:centerXBarRect cornerRadius:centerXBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionCenterXFocus) ? focusAligned : parentAligned setFill];
        [centerXBarPath fill];

        ////// Center X Bar Inner Shadow
        CGRect   centerXBarBorderRect = CGRectInset([centerXBarPath bounds], -innerHighlightCenterBlurRadius, -innerHighlightCenterBlurRadius);

        centerXBarBorderRect = CGRectOffset(centerXBarBorderRect, -innerHighlightCenterOffset.width, -innerHighlightCenterOffset.height);
        centerXBarBorderRect = CGRectInset(CGRectUnion(centerXBarBorderRect, [centerXBarPath bounds]), -1, -1);

        UIBezierPath * centerXBarNegativePath = [UIBezierPath bezierPathWithRect:centerXBarBorderRect];

        [centerXBarNegativePath appendPath:centerXBarPath];
        centerXBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerXBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerXBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(centerXBarBorderRect.size.width), 0);

            [centerXBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [centerXBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (alignmentOptions & RemoteElementAlignmentOptionCenterYMask) {
        //// Center Y Bar Drawing
        UIBezierPath * centerYBarPath = [UIBezierPath bezierPathWithRoundedRect:centerYBarRect cornerRadius:centerYBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [(alignmentOptions & RemoteElementAlignmentOptionCenterYFocus) ? focusAligned : parentAligned setFill];
        [centerYBarPath fill];

        ////// Center Y Bar Inner Shadow
        CGRect   centerYBarBorderRect = CGRectInset([centerYBarPath bounds], -innerHighlightCenterBlurRadius, -innerHighlightCenterBlurRadius);

        centerYBarBorderRect = CGRectOffset(centerYBarBorderRect, -innerHighlightCenterOffset.width, -innerHighlightCenterOffset.height);
        centerYBarBorderRect = CGRectInset(CGRectUnion(centerYBarBorderRect, [centerYBarPath bounds]), -1, -1);

        UIBezierPath * centerYBarNegativePath = [UIBezierPath bezierPathWithRect:centerYBarBorderRect];

        [centerYBarNegativePath appendPath:centerYBarPath];
        centerYBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerYBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerYBarPath addClip];

            CGAffineTransform   transform = CGAffineTransformMakeTranslation(-round(centerYBarBorderRect.size.width), 0);

            [centerYBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [centerYBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    _alignmentOverlay.contents = (__bridge id)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
    UIGraphicsEndImageContext();

    _renderedAlignmentOptions = alignmentOptions;
}  /* renderAlignmentOverlayIfNeeded */

/**
 * Calls `drawOverlayInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect {
    [self.remoteElementView drawOverlayInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation RemoteElementLabelView

- (id)init {
    if ((self = [super init])) {
        self.preserveLines = YES; self.clipsToBounds = NO;
    }

    return self;
}

- (void)setBaseWidth:(CGFloat)baseWidth {
    _baseWidth = baseWidth; _fontScale = 1.0f;
}

- (NSUInteger)lineBreaks {
    return [self.text numberOfMatchesForRegEx:@"\\n"];
}

- (void)drawTextInRect:(CGRect)rect {
    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    if (self.preserveLines) {
        CGFloat   w = rect.size.width;

        if (!_baseWidth)
// nsprintf(@"%@",ClassTagSelectorStringForInstance(self.text));
            self.baseWidth = rect.size.width;
        else if (w != _baseWidth)
            self.fontScale = w / _baseWidth;
        else
            _fontScale = 1.0f;

        if (_fontScale != 1.0f) {
            CGContextScaleCTM(UIGraphicsGetCurrentContext(), _fontScale, _fontScale);
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, rect.origin.y + (_baseWidth - w) / 2.0f);
            rect.size.width = _baseWidth;
        }
    }

    [super drawTextInRect:rect];
    UIGraphicsPopContext();
}

@end

@implementation RemoteElementView (Debugging)

- (NSString *)framesDescription {
    NSArray * subelementFrames = [self.subelementViews
                                  arrayByMappingToBlock:^id (RemoteElementView * obj, NSUInteger idx)
    {
        NSString * nameString = [obj.displayName camelCaseString];

        NSString * originString = [NSString stringWithFormat:@"(%6s,%6s)",
                                   [[[NSString stringWithFormat:@"%f", obj.frame.origin.x] stringByStrippingTrailingZeroes] UTF8String],
                                   [[[NSString stringWithFormat:@"%f", obj.frame.origin.y] stringByStrippingTrailingZeroes] UTF8String]];

        NSString * sizeString = [NSString stringWithFormat:@"%6s x %6s",
                                 [[[NSString stringWithFormat:@"%f", obj.frame.size.width] stringByStrippingTrailingZeroes] UTF8String],
                                 [[[NSString stringWithFormat:@"%f", obj.frame.size.height] stringByStrippingTrailingZeroes] UTF8String]];

        return [NSString stringWithFormat:@"%@\t%@\t%@", nameString, originString, sizeString];
    }];

    return [[@"Element\t    Origin       \t      Size        \n" stringByAppendingString :
             [subelementFrames componentsJoinedByString:@"\n"]] singleBarHeaderBox:20];
}

- (NSString *)constraintsDescription {
    return [NSString stringWithFormat:@"%@\n\n%@", [self modelConstraintsDescription], [self viewConstraintsDescription]];
}

- (NSString *)modelConstraintsDescription {
    NSMutableString * description = [[[NSString stringWithFormat:@"Model Constraints (%@)", self.displayName]
                                      singleBarMessageBox] mutableCopy];

    [description appendFormat:@"\tlayout config: %@\n\tproportion lock? %@",
     _remoteElement.layoutConfiguration,
     NSStringFromBOOL(_remoteElement.proportionLock)];
    [description appendString:[[self.remoteElement constraintsDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];

    return description;
}

- (NSString *)viewConstraintsDescription {
    NSMutableString * description = [[[NSString stringWithFormat:@"View Constraints (%@)", self.displayName]
                                      singleBarMessageBox] mutableCopy];
    NSArray * modeledConstraints =
        [[self constraintsOfType:[RELayoutConstraint class]]
         arrayByMappingToBlock:^NSString * (RELayoutConstraint * obj, NSUInteger idx) {
        return [obj description];
    }];

    if (modeledConstraints.count) [description appendFormat:@"\tmodeled:\n\t\t%@\n", [modeledConstraints componentsJoinedByString:@"\n\t\t"]];

    NSArray * unmodeledConstraints =
        [[self constraintsOfType:[NSLayoutConstraint class]]
         arrayByMappingToBlock:^NSString * (RELayoutConstraint * obj, NSUInteger idx) {
        return prettyRemoteElementConstraint(obj);
    }];

    if (unmodeledConstraints.count) [description appendFormat:@"\tunmodeled:\n\t\t%@\n", [unmodeledConstraints componentsJoinedByString:@"\n\t\t"]];

    if (!modeledConstraints.count && !unmodeledConstraints.count) [description appendString:@"\tno constraints\n"];

    return description;
}

@end

NSString * prettyRemoteElementConstraint(NSLayoutConstraint * constraint) {
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view) {
        return (view
                ? ([view isKindOfClass:[RemoteElementView class]]
                   ?[((RemoteElementView *)view).displayName camelCaseString]
                   : (view.accessibilityIdentifier
                      ? view.accessibilityIdentifier
                      :[NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([view class]), view]
                      )
                   )
                : (NSString *)nil
                );
    };
    NSString     * firstItem     = itemNameForView(constraint.firstItem);
    NSString     * secondItem    = itemNameForView(constraint.secondItem);
    NSDictionary * substitutions = nil;

    if (firstItem && secondItem) substitutions = @{MSExtendedVisualFormatItem1Name : firstItem, MSExtendedVisualFormatItem2Name : secondItem};
    else if (firstItem) substitutions = @{MSExtendedVisualFormatItem1Name : firstItem};

    return [constraint stringRepresentationWithSubstitutions:substitutions];
}

