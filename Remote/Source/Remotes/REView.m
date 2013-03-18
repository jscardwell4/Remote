//
// REView.m
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "REView_Private.h"
#import "RELayoutConfiguration.h"
#import "RERemoteView.h"
#import "MSRemoteConstants.h"
#import "REButtonGroup.h"
#import "REButtonGroupView.h"
#import "Painter.h"
#import "REButtonView.h"
#import <MSKit/MSKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 *  Generic view that initializes some basic settings
 *******************************************************************************/
@interface REViewInternal : UIView {
    __weak REView * _delegate;
}

@end

/*******************************************************************************
 *  View that holds any subelement views and draws primary content
 *******************************************************************************/
@interface REViewContent : REViewInternal @end

/*******************************************************************************
 *  View that draws any background decoration
 *******************************************************************************/
@interface REViewBackdrop : REViewInternal @end

/*******************************************************************************
 *  View that draws top level style elements such as gloss and editing indicators
 *******************************************************************************/
@interface REViewOverlay : REViewInternal

@property (nonatomic, assign) BOOL      showAlignmentIndicators;
@property (nonatomic, assign) BOOL      showContentBoundary;
@property (nonatomic, strong) UIColor * boundaryColor;

@end

#define UPDATE_FROM_MODEL_TRICKLES_DOWN NO
#define VIEW_CLIPS_TO_BOUNDS            NO


@interface REView ()

@property (nonatomic, strong) REViewContent           * contentView;
@property (nonatomic, strong) REViewBackdrop          * backdropView;
@property (nonatomic, strong) REViewOverlay           * overlayView;

@end

static const int   ddLogLevel               = LOG_LEVEL_DEBUG;
static const int   msLogContext             = REMOTE_F;
CGSize const       RemoteElementMinimumSize = (CGSize) { .width = 44.0f, .height = 44.0f };

@implementation REView {
    @private
    NSDictionary  * _kvoReceptionists;
    __weak REView * _weakself;
}

+ (REView *)viewWithModel:(RemoteElement *)model
{
    model = (RemoteElement *)[model.managedObjectContext existingObjectWithID:model.objectID
                                                                       error:nil];

    switch ((uint64_t)model.type)
    {
        case RETypeRemote:

            return [[RERemoteView alloc] initWithModel:model];

        case REButtonGroupTypeSelectionPanel:

            return [[RESelectionPanelButtonGroupView alloc] initWithModel:model];

        case REButtonGroupTypePickerLabel:

            return [[REPickerLabelButtonGroupView alloc] initWithModel:model];

        case REButtonGroupTypeRoundedPanel:

            return [[RERoundedPanelButtonGroupView alloc] initWithModel:model];

        case REButtonGroupTypeToolbar:
        case REButtonGroupTypeCommandSetManager:
        case REButtonGroupTypeTransport:
        case REButtonGroupTypeDPad:
        case RETypeButtonGroup:

            return [[REButtonGroupView alloc] initWithModel:model];

        case REButtonTypeConnectionStatus:

            return [[REConnectionStatusButtonView alloc] initWithModel:model];

        case REButtonTypeBatteryStatus:

            return [[REBatteryStatusButtonView alloc] initWithModel:model];

        case REButtonTypeActivityButton:
        case RETypeButton:

            return [[REButtonView alloc] initWithModel:model];

        case RETypeUndefined:
        default:
            assert(NO); return nil;
    }
}

/**
 * Default initializer for subclasses.
 */
- (id)initWithModel:(RemoteElement *)model
{
    if (model && (self = [super init]))
    {
        _model = model;
        [self registerForChangeNotification];
        [self initializeIVARs];
    }

    return self;
}

/**
 * Called from `initWithRemoteElement:`, subclasses that override should include a call to `super`.
 */
- (void)initializeIVARs
{
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
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id   target = (_model && [_model respondsToSelector:aSelector]
                   ? _model
                   : [super forwardingTargetForSelector:aSelector]);

    return target;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return (_model
            ? [_model valueForKey:key]
            : [super valueForUndefinedKey:key]);
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }

MSKIT_STATIC_STRING_CONST kRemoteElementViewInternalNametag = @"RemoteElementViewInternal";

- (void)updateConstraints {

    if (![self constraintsWithNametagPrefix:kRemoteElementViewInternalNametag])
    {
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

    NSSet * newREConstraints = [_model.constraints
                                setByRemovingObjectsFromSet:
                                [[[self constraintsOfType:[RELayoutConstraint class]] set]
                                 valueForKeyPath:@"modelConstraint"]];

    [self addConstraints:[[newREConstraints setByMappingToBlock:
                           ^RELayoutConstraint * (REConstraint * constraint) {
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
- (NSDictionary *)kvoRegistration
{
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
            if ([c[NSKeyValueChangeNewKey] isKindOfClass:[REImage class]])
                _weakself.backgroundImageView.image = [(REImage*)c[NSKeyValueChangeNewKey]
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
- (void)attachGestureRecognizers {}

/**
 * Registers as observer for keypaths of model that appear in the array retained by subclass for
 * `kvoKeypaths`.
 */
- (void)registerForChangeNotification
{
    if (_model)
    {
        assert(_kvoReceptionists == nil);

        _kvoReceptionists = [[self kvoRegistration]
                             dictionaryByMappingObjectsToBlock:
                             ^MSKVOReceptionist *(NSString * keypath, MSKVOHandler handler)
                             {
                                 return [MSKVOReceptionist
                                         receptionistForObject:_model
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
    assert(_model);

    self.backgroundColor       = _model.backgroundColor;
    _backgroundImageView.image = (_model.backgroundImage
                                  ?[_model.backgroundImage stretchableImage]
                                  : nil);

    [self.subelementViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (RemoteElement * re in _model.subelements)
        [self addSubelementView:[REView viewWithModel:re]];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing constraints
////////////////////////////////////////////////////////////////////////////////

- (void)scale:(CGFloat)scale {
    CGSize currentSize = self.bounds.size;
    CGSize newSize = CGSizeApplyScale(currentSize, scale / _appliedScale);
    _appliedScale = scale;
    [_model.constraintManager resizeElement:_model
                                   fromSize:currentSize
                                     toSize:newSize
                                    metrics:viewFramesByIdentifier(self)];
    [self setNeedsUpdateConstraints];
}

- (void)updateSubelementOrderFromView
{
    _model.subelements = [NSOrderedSet orderedSetWithArray:
                          [self.subelementViews valueForKey:@"remoteElement"]];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation
{
    [_model.constraintManager
     translateSubelements:[subelementViews valueForKeyPath:@"model"]
     translation:translation
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [self.subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale
{
    for (REView * subelementView in subelementViews)
    {
        CGSize   maxSize    = subelementView.maximumSize;
        CGSize   minSize    = subelementView.minimumSize;
        CGSize   scaledSize = CGSizeApplyScale(subelementView.bounds.size, scale);
        CGSize   newSize    = (CGSizeContainsSize(maxSize, scaledSize)
                               ? (CGSizeContainsSize(scaledSize, minSize)
                                  ? scaledSize
                                  : minSize)
                               : maxSize);

        [_model.constraintManager
                 resizeElement:subelementView.model
                      fromSize:subelementView.bounds.size
                        toSize:newSize
                       metrics:viewFramesByIdentifier(self)];
    }

    if (self.shrinkwrap)
        [_model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(REView *)siblingView
               attribute:(NSLayoutAttribute)attribute
{
    [_model.constraintManager
     alignSubelements:[subelementViews valueForKeyPath:@"model"]
            toSibling:siblingView.model
            attribute:attribute
              metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(REView *)siblingView
                attribute:(NSLayoutAttribute)attribute
{
    [_model.constraintManager
     resizeSubelements:[subelementViews valueForKeyPath:@"model"]
             toSibling:siblingView.model
             attribute:attribute
               metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [_model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

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
- (NSString *)displayName
{
    return (_model ? _model.displayName : nil);
}

/**
 * Returns the model's key or nil if no model.
 */
- (NSString *)key
{
    return (_model ? _model.key : nil);
}

- (BOOL)isEditing
{
    return (self.type & _editingMode);
}

/**
 * Searches content view for subviews of the appropriate type and returns them as an array.
 */
- (NSArray *)subelementViews
{
    return [_contentView subviewsOfKind:[REView class]];
}

- (REView *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.subelementViews[idx];
}

- (BOOL)isSubscriptKey:(NSString *)key
{
    return (  StringIsNotEmpty(key)
           && ([key isEqualToString:self.uuid] || [key isEqualToString:self.key]));
}

- (REView *)objectForKeyedSubscript:(NSString *)key
{
    if ([self isSubscriptKey:key]) return self;
    else
        return [self.subelementViews objectPassingTest:^BOOL (REView * obj, NSUInteger idx)
                                                       {
                                                           return [obj isSubscriptKey:key];
                                                       }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - EditableView Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (CGSize)minimumSize
{
    // TODO: Constraints will need to be handled eventually
    if (!self.subelementViews.count) return RemoteElementMinimumSize;

    NSMutableArray * xAxisRanges = [@[] mutableCopy];
    NSMutableArray * yAxisRanges = [@[] mutableCopy];

    // build collections holding ranges that represent x and y axis coverage for subelement frames
    [self.subelementViews enumerateObjectsUsingBlock:^(REView * obj, NSUInteger idx, BOOL * stop)
     {
         CGSize min = obj.minimumSize;
         CGPoint org = obj.frame.origin;
         [xAxisRanges addObject:NSValueWithNSRange(NSMakeRange(org.x, min.width))];
         [yAxisRanges addObject:NSValueWithNSRange(NSMakeRange(org.y, min.height))];
     }];
    
    // sort collections by range location
    [xAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2)
     {
         NSRange r1 = NSRangeValue(obj1);
         NSRange r2 = NSRangeValue(obj2);
         
         return (r1.location < r2.location
                 ? NSOrderedAscending
                 : (r1.location > r2.location
                    ? NSOrderedDescending
                    : NSOrderedSame));
     }];
    
    [yAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2)
     {
         NSRange r1 = NSRangeValue(obj1);
         NSRange r2 = NSRangeValue(obj2);
         
         return (r1.location < r2.location
                 ? NSOrderedAscending
                 : (r1.location > r2.location
                    ? NSOrderedDescending
                    : NSOrderedSame));
     }];

    // join ranges that intersect to create collections of non-intersecting ranges
    int   joinCount;

    do
    {
        NSRange   tmpRange = NSRangeValue(xAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < xAxisRanges.count; i++)
        {
            NSRange   r = NSRangeValue(xAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0)
            {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            }
            
            else
            {
                [a addObject:NSValueWithNSRange(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:NSValueWithNSRange(tmpRange)];
        xAxisRanges = a;
    } while (joinCount);

    do
    {
        NSRange   tmpRange = NSRangeValue(yAxisRanges[0]);

        joinCount = 0;

        NSMutableArray * a = [@[] mutableCopy];

        for (int i = 1; i < yAxisRanges.count; i++)
        {
            NSRange   r = NSRangeValue(yAxisRanges[i]);
            NSRange   j = NSIntersectionRange(tmpRange, r);

            if (j.length > 0)
            {
                joinCount++;
                tmpRange = NSUnionRange(tmpRange, r);
            }
            
            else
            {
                [a addObject:NSValueWithNSRange(tmpRange)];
                tmpRange = r;
            }
        }

        [a addObject:NSValueWithNSRange(tmpRange)];
        yAxisRanges = a;
        
    } while (joinCount);

    // calculate min size and width by summing range lengths
    CGFloat   minWidth = CGFloatValue([[xAxisRanges arrayByMappingToBlock:
                                        ^id (NSValue * obj, NSUInteger idx){
                                            return @(NSRangeValue(obj).length);
                                        }] valueForKeyPath:@"@sum.self"]);
    
    CGFloat   minHeight = CGFloatValue([[yAxisRanges arrayByMappingToBlock:
                                         ^id (NSValue * obj, NSUInteger idx){
                                             return @(NSRangeValue(obj).length);
                                         }] valueForKeyPath:@"@sum.self"]);
    
    CGSize   s = CGSizeMake(minWidth, minHeight);

    if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, NO);

    return s;
}

- (CGSize)maximumSize
{
    // FIXME: Doesn't account for maximum sizes of subelement views
    // to begin with, view must fit inside its superview
    CGSize   s = self.superview.bounds.size;

    // TODO: Eventually must handle size-related constraints
    if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, YES);

    return s;
}

/**
 * Sets border color according to current editing style.
 */
- (void)setEditingStyle:(EditingStyle)editingStyle
{
    _editingStyle = editingStyle;

    _overlayView.showAlignmentIndicators = (_editingStyle == EditingStyleMoving ? YES : NO);
    _overlayView.showContentBoundary     = (_editingStyle ? YES : NO);

    switch (_editingStyle)
    {
        case EditingStyleSelected:
            _overlayView.boundaryColor = YellowColor;
            break;

        case EditingStyleMoving:
            _overlayView.boundaryColor = BlueColor;
            break;

        case EditingStyleFocus:
            _overlayView.boundaryColor = RedColor;
            break;

        default:
            _overlayView.boundaryColor = ClearColor;
            break;
    }

    assert([self.subviews objectAtIndex:self.subviews.count - 1] == _overlayView);
    [_overlayView.layer setNeedsDisplay];
}

/**
 * Adds the backdrop, content, and overlay views. Subclasses that override should call `super`.
 */
- (void)addInternalSubviews
{
    self.backdropView = [REViewBackdrop new];
    [self addSubview:_backdropView];

    _backgroundImageView                                           = [UIImageView new];
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImageView.contentMode                               = UIViewContentModeScaleToFill;
    _backgroundImageView.opaque                                    = NO;
    _backgroundImageView.backgroundColor                           = ClearColor;
    [self.backdropView addSubview:_backgroundImageView];

    self.contentView = [REViewContent new];
    [self addSubview:_contentView];

    self.overlayView = [REViewOverlay new];
    [self addSubview:_overlayView];
}

- (void)addViewToContent:(UIView *)view
{
    [self.contentView addSubview:view];
}

- (void)addViewToOverlay:(UIView *)view
{
    [self.overlayView addSubview:view];
}

- (void)addViewToBackdrop:(UIView *)view
{
    [self.backdropView addSubview:view];
}

- (void)addSubelementView:(REView *)view
{
    view.parentElementView = self;
    [self.contentView addSubview:view];
}

- (void)removeSubelementView:(REView *)view
{
    [view removeFromSuperview];
}

- (void)addSubelementViews:(NSSet *)views
{
    for (REView * view in views)
        [self addSubelementView:view];
}

- (void)removeSubelementViews:(NSSet *)views
{
    for (REView * view in views)
        [self removeSubelementView:view];
}

- (void)bringSubviewToFront:(UIView *)view
{
    if ([view isKindOfClass:[REView class]])
        [_contentView bringSubviewToFront:view];
    else
        [super bringSubviewToFront:view];
}

- (void)sendSubviewToBack:(UIView *)view
{
    if ([view isKindOfClass:[REView class]])
        [_contentView sendSubviewToBack:view];
    else
        [super sendSubviewToBack:view];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    if ([view isKindOfClass:[REView class]])
        [_contentView insertSubview:view aboveSubview:siblingSubview];
    else
        [super insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    if ([view isKindOfClass:[REView class]])
        [_contentView insertSubview:view atIndex:index];
    else
        [super insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    if ([view isKindOfClass:[REView class]])
        [_contentView insertSubview:view belowSubview:siblingSubview];
    else
        [super insertSubview:view belowSubview:siblingSubview];
}

/**
 * Overridden to also call `setNeedsDisplay` on backdrop, content, and overlay subviews.
 */
- (void)setNeedsDisplay
{
    [super setNeedsDisplay];

    [_backdropView setNeedsDisplay];
    [_contentView setNeedsDisplay];
    [_overlayView setNeedsDisplay];
}

- (void)setContentInteractionEnabled:(BOOL)contentInteractionEnabled
{
    self.contentView.userInteractionEnabled = contentInteractionEnabled;
}

- (BOOL)contentInteractionEnabled
{
    return self.contentView.userInteractionEnabled;
}

- (void)setContentClipsToBounds:(BOOL)contentClipsToBounds
{
    self.contentView.clipsToBounds = contentClipsToBounds;
}

- (BOOL)contentClipsToBounds
{
    return self.contentView.clipsToBounds;
}

- (void)setOverlayClipsToBounds:(BOOL)overlayClipsToBounds
{
    self.overlayView.clipsToBounds = overlayClipsToBounds;
}

- (BOOL)overlayClipsToBounds
{
    return self.overlayView.clipsToBounds;
}

/**
 * Override point for subclasses to draw into the content subview.
 */
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    switch (self.shape)
    {
        case REShapeRectangle:
            self.borderPath = [UIBezierPath bezierPathWithRect:self.bounds];
            break;

        case REShapeRoundedRectangle:
            self.borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    byRoundingCorners:UIRectCornerAllCorners
                                                          cornerRadii:_cornerRadii];
            break;

        case REShapeOval:
            self.borderPath = [Painter stretchedOvalFromRect:self.bounds];
            break;

        case REShapeTriangle:
        case REShapeDiamond:
        default:
            self.borderPath = nil;
            break;
    }

}

- (void)setBorderPath:(UIBezierPath *)borderPath
{
    _borderPath = borderPath;

    if (_borderPath)
    {
        self.layer.mask                       = [CAShapeLayer layer];
        ((CAShapeLayer*)self.layer.mask).path = [_borderPath CGPath];
    }
    else
        self.layer.mask = nil;
}

/**
 * Override point for subclasses to draw into the backdrop subview.
 */
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    if (_borderPath)
    {
        UIGraphicsPushContext(ctx);
        [self.backgroundColor setFill];
        [_borderPath fill];
        UIGraphicsPopContext();
    }
}

/**
 * Override point for subclasses to draw into the overlay subview.
 */
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    UIBezierPath * path = (_borderPath
                           ? [UIBezierPath bezierPathWithCGPath:_borderPath.CGPath]
                           : [UIBezierPath bezierPathWithRect:self.bounds]);

    UIGraphicsPushContext(ctx);
    [path addClip];

    if (self.style & REStyleApplyGloss)
        [Painter drawGlossGradientWithColor:defaultGlossColor()
                                     inRect:self.bounds
                                  inContext:UIGraphicsGetCurrentContext()];

    path.lineWidth     = 3.0;
    path.lineJoinStyle = kCGLineJoinRound;

    if (self.style & REStyleDrawBorder)
    {
        [BlackColor setStroke];
        [path stroke];
    }

    UIGraphicsPopContext();
}

@end
#define SUBVIEW_CLIPS_TO_BOUNDS     NO
#define SUBVIEW_AUTORESIZE_SUBVIEWS NO
#define SUBVIEW_CONTENT_MODE        UIViewContentModeRedraw

@implementation REViewInternal

- (id)init
{
    if ((self = [super init]))
    {
        self.userInteractionEnabled                    = [self isMemberOfClass:[REViewContent class]];
        self.backgroundColor                           = ClearColor;
        self.clipsToBounds                             = SUBVIEW_CLIPS_TO_BOUNDS;
        self.contentMode                               = SUBVIEW_CONTENT_MODE;
        self.autoresizesSubviews                       = SUBVIEW_AUTORESIZE_SUBVIEWS;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return self;
}

- (void)willMoveToSuperview:(REView *)newSuperview
{
    assert(!newSuperview || [newSuperview isKindOfClass:[REView class]]);
    _delegate = newSuperview;
}

@end

@implementation REViewContent {}

/**
 * Calls `drawContentInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect
{
    [_delegate drawContentInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation REViewBackdrop {}

/**
 * Calls `drawBackdropInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect
{
    [_delegate drawBackdropInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@interface REViewOverlay ()

@property (nonatomic, strong) CAShapeLayer * boundaryOverlay;
@property (nonatomic, strong) CALayer      * alignmentOverlay;

@end

@implementation REViewOverlay {
    CGSize   _renderedSize;
}

#define PAINT_WITH_STROKE

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    assert(object == _delegate);

    if ([@"borderPath" isEqualToString : keyPath])
    {
        __weak REViewOverlay * weakself = self;
        [MainQueue addOperationWithBlock:^{ _boundaryOverlay.path = [weakself boundaryPath]; }];
    }
}

- (CGPathRef)boundaryPath
{
    assert(_boundaryOverlay);

    UIBezierPath * path = _delegate.borderPath;

    if (!path) path = [UIBezierPath bezierPathWithRect:self.bounds];

    CGSize         size         = self.bounds.size;
    CGFloat        lineWidth    = _boundaryOverlay.lineWidth;
    UIBezierPath * innerPath    = [UIBezierPath bezierPathWithCGPath:path.CGPath];
    CGPathRef      boundaryPath = NULL;

#ifdef PAINT_WITH_STROKE
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - lineWidth) / size.width,
                                                         (size.height - lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth / 2, lineWidth / 2)];
    boundaryPath = innerPath.CGPath;
#else
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - 2 * lineWidth) / size.width,
                                                         (size.height - 2 * lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth, lineWidth)];
    [path appendPath:innerPath];
    boundaryPath = path.CGPath;
#endif

    return boundaryPath;
}

- (CALayer *)boundaryOverlay
{
    if (!_boundaryOverlay)
    {
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

        [_delegate
         addObserver:self
          forKeyPath:@"borderPath"
             options:NSKeyValueObservingOptionNew
             context:NULL];
    }

    return _boundaryOverlay;
}

- (void)dealloc
{
    [_delegate removeObserver:self forKeyPath:@"borderPath"];
}

- (void)setShowContentBoundary:(BOOL)showContentBoundary
{
    _showContentBoundary    = showContentBoundary;
    _boundaryOverlay.hidden = !_showContentBoundary;
}

- (void)setBoundaryColor:(UIColor *)boundaryColor
{
    _boundaryColor = boundaryColor;
#ifdef PAINT_WITH_STROKE
    self.boundaryOverlay.strokeColor = _boundaryColor.CGColor;
#else
    self.boundaryOverlay.fillColor = _boundaryColor.CGColor;
#endif
    [_boundaryOverlay setNeedsDisplay];
}

- (CALayer *)alignmentOverlay
{
    if (!_alignmentOverlay)
    {
        self.alignmentOverlay    = [CALayer layer];
        _alignmentOverlay.frame  = self.layer.bounds;
        _alignmentOverlay.hidden = !_showAlignmentIndicators;
        
        [self.layer addSublayer:_alignmentOverlay];
    }

    return _alignmentOverlay;
}

- (void)setShowAlignmentIndicators:(BOOL)showAlignmentIndicators
{
    _showAlignmentIndicators = showAlignmentIndicators;
    [self renderAlignmentOverlayIfNeeded];
}

- (void)renderAlignmentOverlayIfNeeded
{
    self.alignmentOverlay.hidden = !_showAlignmentIndicators;

    if (!_showAlignmentIndicators) return;

    RELayoutConfiguration * layoutConfiguration = _delegate.layoutConfiguration;

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
    CGRect   leftBarRect = CGRectMake(CGRectGetMinX(frame) + 1,
                                      CGRectGetMinY(frame) + 3,
                                      2,
                                      CGRectGetHeight(frame) - 6);
    CGFloat   leftBarCornerRadius = 1;
    CGRect    rightBarRect        = CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 3,
                                               CGRectGetMinY(frame) + 3,
                                               2,
                                               CGRectGetHeight(frame) - 6);
    CGFloat   rightBarCornerRadius = 1;
    CGRect    topBarRect           = CGRectMake(CGRectGetMinX(frame) + 4,
                                                CGRectGetMinY(frame) + 1,
                                                CGRectGetWidth(frame) - 8,
                                                2);
    CGFloat   topBarCornerRadius = 1;
    CGRect    bottomBarRect      = CGRectMake(CGRectGetMinX(frame) + 4,
                                              CGRectGetMinY(frame) + CGRectGetHeight(frame) - 3,
                                              CGRectGetWidth(frame) - 8,
                                              2);
    CGFloat   bottomBarCornerRadius = 1;
    CGRect    centerXBarRect        = CGRectMake(CGRectGetMinX(frame)
                                                 + floor((CGRectGetWidth(frame) - 2) * 0.50000) + 0.5,
                                                 CGRectGetMinY(frame) + 4,
                                                 2,
                                                 CGRectGetHeight(frame) - 7);
    CGFloat   centerXBarCornerRadius = 1;
    CGRect    centerYBarRect         = CGRectMake(CGRectGetMinX(frame) + 3.5,
                                                  CGRectGetMinY(frame)
                                                  + floor((CGRectGetHeight(frame) - 2) * 0.50000 + 0.5),
                                                  CGRectGetWidth(frame) - 8,
                                                  2);
    CGFloat   centerYBarCornerRadius = 1;

    if (layoutConfiguration[NSLayoutAttributeLeft])
    {
        //// Left Bar Drawing
        UIBezierPath * leftBarPath = [UIBezierPath bezierPathWithRoundedRect:leftBarRect
                                                                cornerRadius:leftBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeLeft]] setFill];
        [leftBarPath fill];

        ////// Left Bar Inner Shadow
        CGRect   leftBarBorderRect = CGRectInset([leftBarPath bounds],
                                                 -innerHighlightLeftBlurRadius,
                                                 -innerHighlightLeftBlurRadius);

        leftBarBorderRect = CGRectOffset(leftBarBorderRect,
                                         -innerHighlightLeftOffset.width,
                                         -innerHighlightLeftOffset.height);
        leftBarBorderRect = CGRectInset(CGRectUnion(leftBarBorderRect, [leftBarPath bounds]), -1, -1);

        UIBezierPath * leftBarNegativePath = [UIBezierPath bezierPathWithRect:leftBarBorderRect];

        [leftBarNegativePath appendPath:leftBarPath];
        leftBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightLeftOffset.width + round(leftBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightLeftOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightLeftBlurRadius,
                                        innerHighlightLeft.CGColor);

            [leftBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(leftBarBorderRect.size.width), 0);

            [leftBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [leftBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeRight])
    {
        //// Right Bar Drawing
        UIBezierPath * rightBarPath = [UIBezierPath bezierPathWithRoundedRect:rightBarRect
                                                                 cornerRadius:rightBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeRight]] setFill];
        [rightBarPath fill];

        ////// Right Bar Inner Shadow
        CGRect   rightBarBorderRect = CGRectInset([rightBarPath bounds],
                                                  -innerHighlightRightBlurRadius,
                                                  -innerHighlightRightBlurRadius);

        rightBarBorderRect = CGRectOffset(rightBarBorderRect,
                                          -innerHighlightRightOffset.width,
                                          -innerHighlightRightOffset.height);
        rightBarBorderRect = CGRectInset(CGRectUnion(rightBarBorderRect, [rightBarPath bounds]), -1, -1);

        UIBezierPath * rightBarNegativePath = [UIBezierPath bezierPathWithRect:rightBarBorderRect];

        [rightBarNegativePath appendPath:rightBarPath];
        rightBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightRightOffset.width + round(rightBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightRightOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightRightBlurRadius,
                                        innerHighlightRight.CGColor);

            [rightBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(rightBarBorderRect.size.width), 0);

            [rightBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [rightBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeTop])
    {
        //// Top Bar Drawing
        UIBezierPath * topBarPath = [UIBezierPath bezierPathWithRoundedRect:topBarRect
                                                               cornerRadius:topBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeTop]] setFill];
        [topBarPath fill];

        ////// Top Bar Inner Shadow
        CGRect   topBarBorderRect = CGRectInset([topBarPath bounds],
                                                -innerHighlightTopBlurRadius,
                                                -innerHighlightTopBlurRadius);

        topBarBorderRect = CGRectOffset(topBarBorderRect,
                                        -innerHighlightTopOffset.width,
                                        -innerHighlightTopOffset.height);
        topBarBorderRect = CGRectInset(CGRectUnion(topBarBorderRect, [topBarPath bounds]), -1, -1);

        UIBezierPath * topBarNegativePath = [UIBezierPath bezierPathWithRect:topBarBorderRect];

        [topBarNegativePath appendPath:topBarPath];
        topBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightTopOffset.width + round(topBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightTopOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightTopBlurRadius,
                                        innerHighlightTop.CGColor);

            [topBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(topBarBorderRect.size.width), 0);

            [topBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [topBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeBottom])
    {
        //// Bottom Bar Drawing
        UIBezierPath * bottomBarPath = [UIBezierPath bezierPathWithRoundedRect:bottomBarRect
                                                                  cornerRadius:bottomBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeBottom]] setFill];
        [bottomBarPath fill];

        ////// Bottom Bar Inner Shadow
        CGRect   bottomBarBorderRect = CGRectInset([bottomBarPath bounds],
                                                   -innerHighlightBottomBlurRadius,
                                                   -innerHighlightBottomBlurRadius);

        bottomBarBorderRect = CGRectOffset(bottomBarBorderRect,
                                           -innerHighlightBottomOffset.width,
                                           -innerHighlightBottomOffset.height);
        bottomBarBorderRect = CGRectInset(CGRectUnion(bottomBarBorderRect, [bottomBarPath bounds]),
                                          -1, -1);

        UIBezierPath * bottomBarNegativePath = [UIBezierPath bezierPathWithRect:bottomBarBorderRect];

        [bottomBarNegativePath appendPath:bottomBarPath];
        bottomBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightBottomOffset.width + round(bottomBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightBottomOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightBottomBlurRadius,
                                        innerHighlightBottom.CGColor);

            [bottomBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(bottomBarBorderRect.size.width), 0);

            [bottomBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [bottomBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeCenterX])
    {
        //// Center X Bar Drawing
        UIBezierPath * centerXBarPath = [UIBezierPath bezierPathWithRoundedRect:centerXBarRect
                                                                   cornerRadius:centerXBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterX]] setFill];
        [centerXBarPath fill];

        ////// Center X Bar Inner Shadow
        CGRect   centerXBarBorderRect = CGRectInset([centerXBarPath bounds],
                                                    -innerHighlightCenterBlurRadius,
                                                    -innerHighlightCenterBlurRadius);

        centerXBarBorderRect = CGRectOffset(centerXBarBorderRect,
                                            -innerHighlightCenterOffset.width,
                                            -innerHighlightCenterOffset.height);
        centerXBarBorderRect = CGRectInset(CGRectUnion(centerXBarBorderRect,
                                                       [centerXBarPath bounds]),
                                           -1, -1);

        UIBezierPath * centerXBarNegativePath = [UIBezierPath bezierPathWithRect:centerXBarBorderRect];

        [centerXBarNegativePath appendPath:centerXBarPath];
        centerXBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerXBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerXBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(centerXBarBorderRect.size.width), 0);

            [centerXBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [centerXBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeCenterY])
    {
        //// Center Y Bar Drawing
        UIBezierPath * centerYBarPath = [UIBezierPath bezierPathWithRoundedRect:centerYBarRect
                                                                   cornerRadius:centerYBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterY]] setFill];
        [centerYBarPath fill];

        ////// Center Y Bar Inner Shadow
        CGRect   centerYBarBorderRect = CGRectInset([centerYBarPath bounds],
                                                    -innerHighlightCenterBlurRadius,
                                                    -innerHighlightCenterBlurRadius);

        centerYBarBorderRect = CGRectOffset(centerYBarBorderRect,
                                            -innerHighlightCenterOffset.width,
                                            -innerHighlightCenterOffset.height);
        centerYBarBorderRect = CGRectInset(CGRectUnion(centerYBarBorderRect,
                                                       [centerYBarPath bounds]),
                                           -1, -1);

        UIBezierPath * centerYBarNegativePath = [UIBezierPath bezierPathWithRect:centerYBarBorderRect];

        [centerYBarNegativePath appendPath:centerYBarPath];
        centerYBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerYBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerYBarPath addClip];

            CGAffineTransform   transform =
                CGAffineTransformMakeTranslation(-round(centerYBarBorderRect.size.width), 0);

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
- (void)drawRect:(CGRect)rect
{
    [_delegate drawOverlayInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation REView (Debugging)

- (NSString *)shortDescription { return self.displayName; }

- (NSString *)framesDescription
{
    NSArray * frames = [[@[self] arrayByAddingObjectsFromArray : self.subelementViews]
                        arrayByMappingToBlock:^id (REView * obj, NSUInteger idx)
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

- (NSString *)constraintsDescription
{
    return $(@"%@\n%@\n\n%@",
             [$(@"%@", self.displayName) singleBarMessageBox],
             [_model constraintsDescription],
             [self viewConstraintsDescription]);
}

- (NSString *)modelConstraintsDescription
{
    return [_model constraintsDescription];
}

- (NSString *)viewConstraintsDescription
{
    NSMutableString * description        = [@"" mutableCopy];
    NSArray         * modeledConstraints = [self constraintsOfType:[RELayoutConstraint class]];

    if (modeledConstraints.count)
        [description appendFormat:@"\nview constraints (modeled):\n\t%@",
         [[modeledConstraints valueForKeyPath:@"description"]
                                    componentsJoinedByString:@"\n\t"]];

    NSArray * unmodeledConstraints = [self constraintsOfType:[NSLayoutConstraint class]];

    if (unmodeledConstraints.count)
        [description appendFormat:@"\n\nview constraints (unmodeled):\n\t%@",
         [[unmodeledConstraints arrayByMappingToBlock:
           ^id (id obj, NSUInteger idx){
                    return prettyRemoteElementConstraint(obj);
                }] componentsJoinedByString:@"\n\t"]];

    if (!modeledConstraints.count && !unmodeledConstraints.count)
        [description appendString:@"no constraints"];

    return description;
}

@end

NSString *prettyRemoteElementConstraint(NSLayoutConstraint * constraint)
{
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view){
        return (view
                ? ([view isKindOfClass:[REView class]]
                   ?[((REView*)view).displayName camelCaseString]
                   : (view.accessibilityIdentifier
                      ? view.accessibilityIdentifier
                      : $(@"<%@:%p>", ClassString([view class]), view)
                      )
                   )
                : (NSString *)nil);
    };
    
    NSString     * firstItem     = itemNameForView(constraint.firstItem);
    NSString     * secondItem    = itemNameForView(constraint.secondItem);
    NSDictionary * substitutions = nil;

    if (firstItem && secondItem)
        substitutions = @{
            MSExtendedVisualFormatItem1Name : firstItem,
            MSExtendedVisualFormatItem2Name : secondItem
        };
    else if (firstItem)
        substitutions = @{
            MSExtendedVisualFormatItem1Name : firstItem
        };

    return [constraint stringRepresentationWithSubstitutions:substitutions];
}
