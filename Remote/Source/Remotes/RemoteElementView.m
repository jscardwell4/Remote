//
// RemoteElementView.m
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "RemoteElementView_Private.h"
#import "RemoteElementLayoutConfiguration.h"
#import "RemoteView.h"
#import "MSRemoteConstants.h"
#import "ButtonGroup.h"
#import "ButtonGroupView.h"
#import "Painter.h"
#import "ButtonView.h"
#import <MSKit/MSKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementViewInternalSubview : UIView {
    __weak RemoteElementView * _remoteElementView;
}

@property (nonatomic, weak, readonly) RemoteElementView * remoteElementView;
- (id)initWithRemoteElementView:(RemoteElementView *)remoteElementView;

@end

/*******************************************************************************
 *  View that holds any subelement views and draws primary content
 *******************************************************************************/
@interface RemoteElementContentView : RemoteElementViewInternalSubview @end

/*******************************************************************************
 *  View that draws any background decoration
 *******************************************************************************/
@interface RemoteElementBackdropView : RemoteElementViewInternalSubview @end

/*******************************************************************************
 *  View that draws top level style elements such as gloss and editing indicators
 *******************************************************************************/
@interface RemoteElementOverlayView : RemoteElementViewInternalSubview

@property (nonatomic, assign) BOOL      showAlignmentIndicators;
@property (nonatomic, assign) BOOL      showContentBoundary;
@property (nonatomic, strong) UIColor * boundaryColor;

@end

#define NEEDS_DISPLAY_TRICKLES_DOWN     YES
#define UPDATE_FROM_MODEL_TRICKLES_DOWN NO
#define VIEW_CLIPS_TO_BOUNDS            NO


@interface RemoteElementView ()

@property (nonatomic, strong) RemoteElementContentView           * contentView;
@property (nonatomic, strong) RemoteElementBackdropView          * backdropView;
@property (nonatomic, strong) RemoteElementOverlayView           * overlayView;

@end

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = REMOTE_F;
CGSize const       RemoteElementMinimumSize = (CGSize) {.width = 44.0f, .height = 44.0f};

@implementation RemoteElementView {
@private
    NSDictionary           * _kvoReceptionists;
    __weak RemoteElementView * _weakself;
}

+ (RemoteElementView *)remoteElementViewWithElement:(RemoteElement *)element {
    element = (RemoteElement *)[element.managedObjectContext existingObjectWithID:element.objectID
                                                                            error:nil];
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
    }
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
    _weakself = self;
    self.appliedScale = 1.0;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds                             = VIEW_CLIPS_TO_BOUNDS;
    self.opaque                                    = NO;
    self.multipleTouchEnabled                      = YES;
    self.userInteractionEnabled                    = YES;
    
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
                   : [super forwardingTargetForSelector:aSelector]);

    return target;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return (_remoteElement
            ?[_remoteElement valueForKey:key]
            :[super valueForUndefinedKey:key]);
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }

MSKIT_STATIC_STRING_CONST kRemoteElementViewInternalNametag = @"RemoteElementViewInternal";

- (void)updateConstraints {

    if (![self constraintsWithNametagPrefix:kRemoteElementViewInternalNametag]) {
        NSDictionary * views = NSDictionaryOfVariableBindings(self,
                                                              _backdropView,
                                                              _backgroundImageView,
                                                              _contentView,
                                                              _overlayView);
        NSString * constraints =
            $(@"'%1$@' _backdropView.width = self.width\n"
             "'%1$@' _backdropView.height = self.height\n"
             "'%1$@' _backdropView.centerX = self.centerX\n"
             "'%1$@' _backdropView.centerY = self.centerY\n"
             "'%1$@' _backgroundImageView.width = self.width\n"
             "'%1$@' _backgroundImageView.height = self.height\n"
             "'%1$@' _backgroundImageView.centerX = self.centerX\n"
             "'%1$@' _backgroundImageView.centerY = self.centerY\n"
             "'%1$@' _contentView.width = self.width\n"
             "'%1$@' _contentView.height = self.height\n"
             "'%1$@' _contentView.centerX = self.centerX\n"
             "'%1$@' _contentView.centerY = self.centerY\n"
             "'%1$@' _overlayView.width = self.width\n"
             "'%1$@' _overlayView.height = self.height\n"
             "'%1$@' _overlayView.centerX = self.centerX\n"
             "'%1$@' _overlayView.centerY = self.centerY",
              kRemoteElementViewInternalNametag);

        [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                      views:views]];
    }

    NSSet * newREConstraints = [_remoteElement.constraints
                                setByRemovingObjectsFromSet:
                                [[[self constraintsOfType:[RELayoutConstraint class]] set]
                                 valueForKeyPath:@"modelConstraint"]];

    [self addConstraints:[[newREConstraints setByMappingToBlock:
                           ^RELayoutConstraint * (RemoteElementLayoutConstraint * constraint) {
                               return [RELayoutConstraint constraintWithModel:constraint
                                                                      forView:_weakself];
                           }] allObjects]];

    [super updateConstraints];
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
- (NSDictionary *)kvoRegistration {
    NSDictionary * kvoRegistration =
    @{
      @"constraints" :
        ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
        {
            [_weakself setNeedsUpdateConstraints];
        },
      @"firstItemConstraints" :
      ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
      {
          [_weakself.parentElementView setNeedsUpdateConstraints];
      },
      @"backgroundColor" :
        ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
        {
            if ([c[NSKeyValueChangeNewKey] isKindOfClass:[UIColor class]])
                _weakself.backgroundColor = c[NSKeyValueChangeNewKey];
            else
                _weakself.backgroundColor = nil;
        },
      @"backgroundImage" :
        ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
        {
            if ([c[NSKeyValueChangeNewKey] isKindOfClass:[GalleryImage class]])
                _weakself.backgroundImageView.image = [(GalleryImage *)c[NSKeyValueChangeNewKey]
                                                      stretchableImage];
            else
                _weakself.backgroundImageView.image = nil;
        },
      @"backgroundImageAlpha" :
        ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
        {
            if ([c[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]])
                _backgroundImageView.alpha = [c[NSKeyValueChangeNewKey] floatValue];
        },
      @"shape" :
        ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx)
        {
            _weakself.bounds = _weakself.bounds;
        }
      };

    return kvoRegistration;
}

/**
 * Override point for subclasses to attach gestures. Called from `initWithRemoteElement`.
 */
- (void)attachGestureRecognizers
{}

/**
 * Registers as observer for keypaths of model that appear in the array retained by subclass for
 * `kvoKeypaths`.
 */
- (void)registerForChangeNotification
{
    if (_remoteElement)
    {
        assert(_kvoReceptionists == nil);

        _kvoReceptionists = [[self kvoRegistration]
                             dictionaryByMappingObjectsToBlock:
                             ^MSKVOReceptionist *(NSString * keypath, MSKVOHandler handler) {
                                 return [MSKVOReceptionist
                                         receptionistForObject:_remoteElement
                                         keyPath:keypath
                                         options:NSKeyValueObservingOptionNew
                                         context:NULL
                                         queue:MainQueue
                                         handler:handler];
                             }];
    }
}

/**
 * Removes registration for keypaths observed via `registerForChangeNotification`.
 */
- (void)unregisterForChangeNotification {
    _kvoReceptionists = nil;
}

/**
 * Override point for subclasses to update themselves with data from the model.
 */
- (void)initializeViewFromModel {
    if (!_remoteElement) return;

    self.backgroundColor   = _remoteElement.backgroundColor;
    _backgroundImageView.image = (_remoteElement.backgroundImage
                                  ? [_remoteElement.backgroundImage stretchableImage]
                                  : nil);

    [self.subelementViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (RemoteElement * re in _remoteElement.subelements)
        [self addSubelementView:[RemoteElementView remoteElementViewWithElement:re]];

//    [self setNeedsUpdateConstraints];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing constraints
////////////////////////////////////////////////////////////////////////////////

- (void)scale:(CGFloat)scale {
    CGSize currentSize = self.bounds.size;
    CGSize newSize = CGSizeApplyScale(currentSize, scale / _appliedScale);
    MSLogDebugInContext(EDITOR_F,
                        @"current size:%.2f x %.2f; new size:%.2f x %.2f",
                        currentSize.width,
                        currentSize.height,
                        newSize.width,
                        newSize.height);
    _appliedScale = scale;
    [_remoteElement.constraintManager resizeElement:_remoteElement
                                           fromSize:currentSize
                                             toSize:newSize
                                            metrics:viewFramesByIdentifier(self)];
    [self setNeedsUpdateConstraints];
}

- (void)updateSubelementOrderFromView
{
    _remoteElement.subelements = [NSOrderedSet orderedSetWithArray:
                                  [self.subelementViews
                                   valueForKey:@"remoteElement"]];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation
{
    [_remoteElement.constraintManager
     translateSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
     translation:translation
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_remoteElement.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [self.subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale
{
    for (RemoteElementView * subelementView in subelementViews)
    {
        CGSize   maxSize    = subelementView.maximumSize;
        CGSize   minSize    = subelementView.minimumSize;
        CGSize   scaledSize = CGSizeApplyScale(subelementView.bounds.size, scale);
        CGSize   newSize    = (CGSizeContainsSize(maxSize, scaledSize)
                               ? (CGSizeContainsSize(scaledSize, minSize)
                                  ? scaledSize
                                  : minSize)
                               : maxSize);

        [_remoteElement.constraintManager
         resizeElement:subelementView.remoteElement
         fromSize:subelementView.bounds.size
         toSize:newSize
         metrics:viewFramesByIdentifier(self)];
    }

    if (self.shrinkwrap)
        [_remoteElement.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute
{
    [_remoteElement.constraintManager
     alignSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
     toSibling:siblingView.remoteElement
     attribute:attribute
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_remoteElement.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute
{
    [_remoteElement.constraintManager
     resizeSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
     toSibling:siblingView.remoteElement
     attribute:attribute
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_remoteElement.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];

}

- (void)willResizeViews:(NSSet *)views {}

- (void)didResizeViews:(NSSet *)views {}

- (void)willScaleViews:(NSSet *)views {}

- (void)didScaleViews:(NSSet *)views {}

- (void)willAlignViews:(NSSet *)views {}

- (void)didAlignViews:(NSSet *)views {}

- (void)willMoveViews:(NSSet *)views {}

- (void)didMoveViews:(NSSet *)views {}

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
    return [_contentView subviewsOfKind:[RemoteElementView class]];
}

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.subelementViews[idx];
}

- (BOOL)isSubscriptKey:(NSString *)key
{
    return (StringIsNotEmpty(key)
            && ([key isEqualToString:self.identifier] || [key isEqualToString:self.key]));
}

- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key {
    if ([self isSubscriptKey:key]) return self;
    else
        return [self.subelementViews
                objectPassingTest:^BOOL (RemoteElementView * obj, NSUInteger idx) {
                    return [obj isSubscriptKey:key];
            }];
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
        MSLogError(@"failed to set remote");
        _remoteElement = nil;
    }

    if ([_remoteElement isFault]) MSLogDebug(@"remote is faulted, possibly a new context insertion");

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
     enumerateObjectsUsingBlock:^(RemoteElementView * obj, NSUInteger idx, BOOL * stop) {
         CGSize min = obj.minimumSize;
         CGPoint org = obj.frame.origin;
         [xAxisRanges addObject:NSValueWithNSRange(NSMakeRange(org.x, min.width))];
         [yAxisRanges addObject:NSValueWithNSRange(NSMakeRange(org.y, min.height))];
     }

    ];

    // sort collections by range location
    [xAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2) {
        NSRange r1 = NSRangeValue(obj1);
        NSRange r2 = NSRangeValue(obj2);

        return (r1.location < r2.location
                ? NSOrderedAscending
                : (r1.location > r2.location
                   ? NSOrderedDescending
                   : NSOrderedSame));
    }

    ];

    [yAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2) {
        NSRange r1 = NSRangeValue(obj1);
        NSRange r2 = NSRangeValue(obj2);

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
        NSRange   tmpRange = NSRangeValue(xAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < xAxisRanges.count; i++) {
            NSRange   r = NSRangeValue(xAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0) {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            } else {
                [a addObject:NSValueWithNSRange(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:NSValueWithNSRange(tmpRange)];
        xAxisRanges = a;
    } while (joinCount);

    do {
        NSRange   tmpRange = NSRangeValue(yAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < yAxisRanges.count; i++) {
            NSRange   r = NSRangeValue(yAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0) {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            } else {
                [a addObject:NSValueWithNSRange(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:NSValueWithNSRange(tmpRange)];
        yAxisRanges = a;
    } while (joinCount);

    // calculate min size and width by summing range lengths
    CGFloat   minWidth = CGFloatValue([[xAxisRanges
                                 arrayByMappingToBlock:^id (NSValue * obj, NSUInteger idx) {
                return @(NSRangeValue(obj).length);
            }

                                ]
                                valueForKeyPath:@"@sum.self"]);
    CGFloat   minHeight = CGFloatValue([[yAxisRanges
                                  arrayByMappingToBlock:
                                  ^id (NSValue * obj, NSUInteger idx) {
                NSRange r = NSRangeValue(obj);

                return @(r.length);
            }

                                 ]
                                 valueForKeyPath:@"@sum.self"]);
    CGSize   s = CGSizeMake(minWidth, minHeight);

    if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, NO);

    return s;
}

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
}

- (void)addViewToContent:(UIView *)view { [self.contentView addSubview:view]; }
- (void)addViewToOverlay:(UIView *)view { [self.overlayView addSubview:view]; }
- (void)addViewToBackdrop:(UIView *)view { [self.backdropView addSubview:view]; }

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

- (void)bringSubviewToFront:(UIView *)view {
    if ([view isKindOfClass:[RemoteElementView class]])
        [_contentView bringSubviewToFront:view];
    else
        [super bringSubviewToFront:view];
}

- (void)sendSubviewToBack:(UIView *)view {
    if ([view isKindOfClass:[RemoteElementView class]])
        [_contentView sendSubviewToBack:view];
    else
        [super sendSubviewToBack:view];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    if ([view isKindOfClass:[RemoteElementView class]])
        [_contentView insertSubview:view aboveSubview:siblingSubview];
    else
        [super insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    if ([view isKindOfClass:[RemoteElementView class]])
        [_contentView insertSubview:view atIndex:index];
    else
        [super insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    if ([view isKindOfClass:[RemoteElementView class]])
        [_contentView insertSubview:view belowSubview:siblingSubview];
    else
        [super  insertSubview:view belowSubview:siblingSubview];
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

- (void)setContentInteractionEnabled:(BOOL)contentInteractionEnabled {
    self.contentView.userInteractionEnabled = contentInteractionEnabled;
}

- (BOOL)contentInteractionEnabled { return self.contentView.userInteractionEnabled; }

- (void)setContentClipsToBounds:(BOOL)contentClipsToBounds {
    self.contentView.clipsToBounds = contentClipsToBounds;
}

- (BOOL)contentClipsToBounds { return self.contentView.clipsToBounds; }

- (void)setOverlayClipsToBounds:(BOOL)overlayClipsToBounds {
    self.overlayView.clipsToBounds = overlayClipsToBounds;
}

- (BOOL)overlayClipsToBounds { return self.overlayView.clipsToBounds; }

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
                                                          cornerRadii:_cornerRadii];
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

- (id)initWithRemoteElementView:(RemoteElementView *)remoteElementView
{
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
    [_remoteElementView drawContentInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation RemoteElementBackdropView {}

/**
 * Calls `drawBackdropInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect {
    [_remoteElementView drawBackdropInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@interface RemoteElementOverlayView ()

@property (nonatomic, strong) CAShapeLayer * boundaryOverlay;
@property (nonatomic, strong) CALayer      * alignmentOverlay;

@end

@implementation RemoteElementOverlayView {
    CGSize     _renderedSize;
}

#define PAINT_WITH_STROKE

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    assert(object == _remoteElementView);
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

    UIBezierPath * path = _remoteElementView.borderPath;

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
#endif
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
#endif
        _boundaryOverlay.path = [self boundaryPath];
        [self.layer addSublayer:_boundaryOverlay];
        _boundaryOverlay.hidden = !_showContentBoundary;
        [_remoteElementView
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

- (void)renderAlignmentOverlayIfNeeded
{
    self.alignmentOverlay.hidden = !_showAlignmentIndicators;

    if (!_showAlignmentIndicators) return;

    RemoteElementLayoutConfiguration * layoutConfiguration = self.remoteElementView.layoutConfiguration;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    //// General Declarations
    CGContextRef   context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor * gentleHighlight = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor * parent          = [UIColor colorWithRed:0.899 green:0.287 blue:0.238 alpha:1];
    UIColor * sibling         = [UIColor colorWithRed:0.186 green:0.686 blue:0.661 alpha:1];
    UIColor * intrinsic       = [UIColor colorWithRed:0.686 green:0.186 blue:0.899 alpha:1];
    UIColor * colors[4]       = { gentleHighlight, parent, sibling, intrinsic };


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

    if (layoutConfiguration[NSLayoutAttributeLeft]) {
        //// Left Bar Drawing
        UIBezierPath * leftBarPath = [UIBezierPath bezierPathWithRoundedRect:leftBarRect cornerRadius:leftBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeLeft]] setFill];
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

    if (layoutConfiguration[NSLayoutAttributeRight]) {
        //// Right Bar Drawing
        UIBezierPath * rightBarPath = [UIBezierPath bezierPathWithRoundedRect:rightBarRect cornerRadius:rightBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeRight]] setFill];
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

    if (layoutConfiguration[NSLayoutAttributeTop]) {
        //// Top Bar Drawing
        UIBezierPath * topBarPath = [UIBezierPath bezierPathWithRoundedRect:topBarRect cornerRadius:topBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeTop]] setFill];
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

    if (layoutConfiguration[NSLayoutAttributeBottom]) {
        //// Bottom Bar Drawing
        UIBezierPath * bottomBarPath = [UIBezierPath bezierPathWithRoundedRect:bottomBarRect cornerRadius:bottomBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeBottom]] setFill];
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

    if (layoutConfiguration[NSLayoutAttributeCenterX]) {
        //// Center X Bar Drawing
        UIBezierPath * centerXBarPath = [UIBezierPath bezierPathWithRoundedRect:centerXBarRect cornerRadius:centerXBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterX]] setFill];
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

    if (layoutConfiguration[NSLayoutAttributeCenterY]) {
        //// Center Y Bar Drawing
        UIBezierPath * centerYBarPath = [UIBezierPath bezierPathWithRoundedRect:centerYBarRect cornerRadius:centerYBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset, outerHighlightBlurRadius, outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterY]] setFill];
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

}

/**
 * Calls `drawOverlayInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect {
    [_remoteElementView drawOverlayInContext:UIGraphicsGetCurrentContext() inRect:rect];
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

- (NSString *)shortDescription { return self.displayName; }

- (NSString *)framesDescription {
    NSArray * frames = [[@[self] arrayByAddingObjectsFromArray:self.subelementViews]
                                  arrayByMappingToBlock:^id (RemoteElementView * obj, NSUInteger idx)
    {
        NSString * nameString = [obj.displayName camelCaseString];

        NSString * originString = $(@"(%6s,%6s)",
                                   UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.x))),
                                   UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.y))));

        NSString * sizeString = $(@"%6s x %6s",
                                 UTF8(StripTrailingZeros($(@"%f", obj.frame.size.width))),
                                 UTF8(StripTrailingZeros($(@"%f", obj.frame.size.height))));

        return $(@"%@\t%@\t%@", nameString, originString, sizeString);
    }];

    return [[@"Element\t    Origin       \t      Size        \n" stringByAppendingString :
             [frames componentsJoinedByString:@"\n"]] singleBarHeaderBox:20];
}

- (NSString *)constraintsDescription {
    return $(@"%@\n%@\n\n%@",
             [$(@"%@", self.displayName) singleBarMessageBox],
             [self modelConstraintsDescription],
             [self viewConstraintsDescription]);
}

- (NSString *)modelConstraintsDescription {
    return [_remoteElement constraintsDescription];
}

- (NSString *)viewConstraintsDescription {
    NSMutableString * description = [@"" mutableCopy];
    NSArray * modeledConstraints = [self constraintsOfType:[RELayoutConstraint class]];

    if (modeledConstraints.count) [description appendFormat:@"\nview constraints (modeled):\n\t%@",
                                   [[modeledConstraints valueForKeyPath:@"description"]
                                    componentsJoinedByString:@"\n\t"]];

    NSArray * unmodeledConstraints = [self constraintsOfType:[NSLayoutConstraint class]];

    if (unmodeledConstraints.count) [description appendFormat:@"\n\nview constraints (unmodeled):\n\t%@",
                                     [[unmodeledConstraints arrayByMappingToBlock:^id(id obj, NSUInteger idx) {
                                        return prettyRemoteElementConstraint(obj);
                                      }] componentsJoinedByString:@"\n\t"]];

    if (!modeledConstraints.count && !unmodeledConstraints.count)
        [description appendString:@"no constraints"];

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
                      :$(@"<%@:%p>", ClassString([view class]), view)
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

