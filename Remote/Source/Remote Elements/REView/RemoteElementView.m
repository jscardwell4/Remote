//
// REView.m
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "RemoteElementView_Private.h"
#import "LayoutConfiguration.h"
#import "RemoteElementView.h"
#import "MSRemoteConstants.h"

#import "Painter.h"
#import <MSKit/MSKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Global Variables
////////////////////////////////////////////////////////////////////////////////

static const int   ddLogLevel               = LOG_LEVEL_DEBUG;
static const int   msLogContext             = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
CGSize const       REMinimumSize = (CGSize) { .width = 44.0f, .height = 44.0f };

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation RemoteElementView

+ (instancetype)viewWithModel:(RemoteElement *)model
{
    static NSDictionary const * kClassMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kClassMap = @{ @(RETypeUndefined)                 : NullObject,
                       @(RETypeRemote)                    : @"RemoteView",
                       @(RETypeButtonGroup)               : @"ButtonGroupView",
                       @(RETypeButton)                    : @"ButtonView",
                       @(REButtonGroupTypePanel)          : @"ButtonGroupView",
                       @(REButtonGroupTypeSelectionPanel) : @"SelectionPanelButtonGroupView",
                       @(REButtonGroupTypeToolbar)        : @"ButtonGroupView",
                       @(REButtonGroupTypeDPad)           : @"ButtonGroupView",
                       @(REButtonGroupTypeNumberpad)      : @"ButtonGroupView",
                       @(REButtonGroupTypeTransport)      : @"ButtonGroupView",
                       @(REButtonGroupTypePickerLabel)    : @"PickerLabelButtonGroupView",
                       @(REButtonTypeToolbar)             : @"ButtonView",
                       @(REButtonTypeConnectionStatus)    : @"ConnectionStatusButtonView",
                       @(REButtonTypeBatteryStatus)       : @"BatteryStatusButtonView",
                       @(REButtonTypePickerLabel)         : @"ButtonView",
                       @(REButtonTypePickerLabelTop)      : @"ButtonView",
                       @(REButtonTypePickerLabelBottom)   : @"ButtonView",
                       @(REButtonTypePanel)               : @"ButtonView",
                       @(REButtonTypeTuck)                : @"ButtonView",
                       @(REButtonTypeSelectionPanel)      : @"ButtonView",
                       @(REButtonTypeDPad)                : @"ButtonView",
                       @(REButtonTypeDPadUp)              : @"ButtonView",
                       @(REButtonTypeDPadDown)            : @"ButtonView",
                       @(REButtonTypeDPadLeft)            : @"ButtonView",
                       @(REButtonTypeDPadRight)           : @"ButtonView",
                       @(REButtonTypeDPadCenter)          : @"ButtonView",
                       @(REButtonTypeNumberpad)           : @"ButtonView",
                       @(REButtonTypeNumberpad1)          : @"ButtonView",
                       @(REButtonTypeNumberpad2)          : @"ButtonView",
                       @(REButtonTypeNumberpad3)          : @"ButtonView",
                       @(REButtonTypeNumberpad4)          : @"ButtonView",
                       @(REButtonTypeNumberpad5)          : @"ButtonView",
                       @(REButtonTypeNumberpad6)          : @"ButtonView",
                       @(REButtonTypeNumberpad7)          : @"ButtonView",
                       @(REButtonTypeNumberpad8)          : @"ButtonView",
                       @(REButtonTypeNumberpad9)          : @"ButtonView",
                       @(REButtonTypeNumberpad0)          : @"ButtonView",
                       @(REButtonTypeNumberpadAux1)       : @"ButtonView",
                       @(REButtonTypeNumberpadAux2)       : @"ButtonView",
                       @(REButtonTypeTransport)           : @"ButtonView",
                       @(REButtonTypeTransportPlay)       : @"ButtonView",
                       @(REButtonTypeTransportStop)       : @"ButtonView",
                       @(REButtonTypeTransportPause)      : @"ButtonView",
                       @(REButtonTypeTransportSkip)       : @"ButtonView",
                       @(REButtonTypeTransportReplay)     : @"ButtonView",
                       @(REButtonTypeTransportFF)         : @"ButtonView",
                       @(REButtonTypeTransportRewind)     : @"ButtonView",
                       @(REButtonTypeTransportRecord)     : @"ButtonView" };

    });

    model = (RemoteElement *)[model.managedObjectContext existingObjectWithID:model.objectID
                                                                       error:nil];

    REType type = model.type;
    NSString * className = kClassMap[@(type)];
    if (!className && ((type & REButtonGroupTypePanel) == REButtonGroupTypePanel))
    {
        type &= ~REButtonGroupTypePanel|RETypeButtonGroup;
        className = kClassMap[@(type)];
    }
    
    return (className ? [[NSClassFromString(className) alloc] initWithModel:model] : nil);
}

/**
 * Default initializer for subclasses.
 */
- (instancetype)initWithModel:(RemoteElement *)model
{
    if (model && (self = [super initForAutoLayout]))
    {
        self.model = model;
//        NSLog(@"%@", [model deepDescription]);
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
    self.appliedScale = 1.0;
    self.clipsToBounds = NO;
//    self.translatesAutoresizingMaskIntoConstraints = NO;
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
    return (_model  ? : [super forwardingTargetForSelector:aSelector]);
}


- (id)valueForUndefinedKey:(NSString *)key
{
    return (_model ? [_model valueForKey:key] : [super valueForUndefinedKey:key]);
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }

MSSTATIC_STRING_CONST REViewInternalNametag = @"REViewInternal";

- (void)updateConstraints {

    if (![self constraintsWithNametagPrefix:REViewInternalNametag])
    {
        NSDictionary * views = NSDictionaryOfVariableBindings(self,
                                                              _backdropView,
                                                              _backgroundImageView,
                                                              _contentView,
                                                              _subelementsView,
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
             "'%1$@' _subelementsView.width = self.width\n"
             "'%1$@' _subelementsView.height = self.height\n"
             "'%1$@' _subelementsView.centerX = self.centerX\n"
             "'%1$@' _subelementsView.centerY = self.centerY\n"
             "'%1$@' _overlayView.width = self.width\n"
             "'%1$@' _overlayView.height = self.height\n"
             "'%1$@' _overlayView.centerX = self.centerX\n"
             "'%1$@' _overlayView.centerY = self.centerY",
              REViewInternalNametag);

        [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                      views:views]];
    }

    NSSet * newREConstraints = [_model.constraints
                                setByRemovingObjectsFromSet:
                                [[[self constraintsOfType:[LayoutConstraint class]] set]
                                 valueForKeyPath:@"modelConstraint"]];

    [self addConstraints:[[newREConstraints setByMappingToBlock:
                           ^LayoutConstraint * (Constraint * constraint) {
                               return [LayoutConstraint constraintWithModel:constraint
                                                                      forView:self];
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
        @{@"constraints" : MSMakeKVOHandler({
            [(__bridge RemoteElementView *)context setNeedsUpdateConstraints];
          }),
          @"backgroundColor" : MSMakeKVOHandler({
              if ([change[NSKeyValueChangeNewKey] isKindOfClass:[UIColor class]])
                  ((__bridge RemoteElementView *)context).backgroundColor = change[NSKeyValueChangeNewKey];
              else
                  ((__bridge RemoteElementView *)context).backgroundColor = nil;
          }),
          @"backgroundImage" : MSMakeKVOHandler({
              if ([change[NSKeyValueChangeNewKey] isKindOfClass:[Image class]])
                  ((__bridge RemoteElementView *)context).backgroundImageView.image = [(Image*)change[NSKeyValueChangeNewKey]
                                                         stretchableImage];
              else
                  ((__bridge RemoteElementView *)context).backgroundImageView.image = nil;
          }),
          @"backgroundImageAlpha" : MSMakeKVOHandler({
              if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]])
                  _backgroundImageView.alpha = [(NSNumber *)change[NSKeyValueChangeNewKey] floatValue];
          }),
          @"shape" : MSMakeKVOHandler({
              [(__bridge RemoteElementView *)context refreshBorderPath];
          })};

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
        _kvoReceptionists = [[self kvoRegistration]
                             dictionaryByMappingObjectsToBlock:
                             ^MSKVOReceptionist *(NSString * keypath, MSKVOHandler handler)
                             {
                                 return [MSKVOReceptionist
                                         receptionistForObject:_model
                                                       keyPath:keypath
                                                       options:NSKeyValueObservingOptionNew
                                                       context:(__bridge void *)self
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
- (void)initializeViewFromModel
{
    [super setBackgroundColor:[_model backgroundColor]];
    _backgroundImageView.image = (_model.backgroundImage
                                  ?[_model.backgroundImage stretchableImage]
                                  : nil);
    [self refreshBorderPath];

    for (RemoteElement * re in _model.subelements)
        [self addSubelementView:[RemoteElementView viewWithModel:re]];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing constraints
////////////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if ([newSuperview isKindOfClass:[REViewSubelements class]])
        self.parentElementView = (RemoteElementView *)newSuperview.superview;
}

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return _subelementsView.subviews[idx];
}

- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key
{
    if (REStringIdentifiesREView(key, self)) return self;
    else
        return [self.subelementViews objectPassingTest:
                ^BOOL (RemoteElementView * obj, NSUInteger idx) {
                    return REStringIdentifiesREView(key, obj);
                }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - EditableView Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (CGSize)minimumSize
{
    // TODO: Constraints will need to be handled eventually
    if (!self.subelementViews.count) return REMinimumSize;

    NSMutableArray * xAxisRanges = [@[] mutableCopy];
    NSMutableArray * yAxisRanges = [@[] mutableCopy];

    // build collections holding ranges that represent x and y axis coverage for subelement frames
    [self.subelementViews enumerateObjectsUsingBlock:^(RemoteElementView * obj, NSUInteger idx, BOOL * stop)
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

- (UIColor *)backgroundColor { return ([super backgroundColor] ?: _model.backgroundColor); }

/**
 * Overridden to also call `setNeedsDisplay` on backdrop, content, and overlay subviews.
 */
- (void)setNeedsDisplay
{
    [super setNeedsDisplay];

    [_backdropView setNeedsDisplay];
    [_contentView setNeedsDisplay];
    [_subelementsView setNeedsDisplay];
    [_overlayView setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds { [super setBounds:bounds]; [self refreshBorderPath]; }

@end

