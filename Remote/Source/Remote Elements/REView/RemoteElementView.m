//
// RemoteElementView.m
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "RemoteElementView_Private.h"
#import "RemoteElementView.h"
#import "MSRemoteConstants.h"
#import <MSKit/MSKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import "Image.h"
#import "Theme.h"
#import "RemoteElementLayoutConstraint.h"
#import "ConstraintManager.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Global Variables
////////////////////////////////////////////////////////////////////////////////

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

CGSize const REMinimumSize = (CGSize) { .width = 44.0f, .height = 44.0f };



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////

/// Generic view that initializes some basic settings
@interface REViewInternal : UIView {
  __weak RemoteElementView * _delegate;
} @end

/// View that holds any subelement views
@interface REViewSubelements : REViewInternal @end

/// View that draws primary content
@interface REViewContent : REViewInternal @end

/// View that draws any background decoration
@interface REViewBackdrop : REViewInternal @end

/// View that draws top level style elements such as gloss and editing indicators
@interface REViewOverlay : REViewInternal

@property (nonatomic, assign) BOOL      showAlignmentIndicators;
@property (nonatomic, assign) BOOL      showContentBoundary;
@property (nonatomic, strong) UIColor * boundaryColor;

@end





@interface RemoteElementView () {
@private
  struct {
    REEditingMode  editingMode;
    BOOL           editing;
    BOOL           locked;
    BOOL           resizable;
    BOOL           moveable;
    BOOL           shrinkwrap;
    REEditingState editingState;
    CGFloat        appliedScale;
  } _editingFlags;

}

@property (nonatomic, strong) NSDictionary      * kvoReceptionists;
@property (nonatomic, strong) REViewSubelements * subelementsView;
@property (nonatomic, strong) REViewContent     * contentView;
@property (nonatomic, strong) REViewBackdrop    * backdropView;
@property (nonatomic, strong) REViewOverlay     * overlayView;
@property (nonatomic, strong) UIBezierPath      * borderPath;

@property (nonatomic, assign) CGSize cornerRadii;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation RemoteElementView

+ (instancetype)viewWithModel:(RemoteElement *)model {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
                  index = @{                       // type
                            @(RETypeRemote) :
                              @{ @(RERoleUndefined) : @"RemoteView" },
                            @(RETypeButtonGroup) :
                              @{                                   // button group roles
                                @(RERoleUndefined) :
                                  @"ButtonGroupView",
                                @(REButtonGroupRoleRocker) :
                                  @"RockerView",
                                @(REButtonGroupRoleSelectionPanel) :
                                  @"ModeSelectionView"
                                },
                            @(RETypeButton) :
                              @{                                   // button roles
                                @(RERoleUndefined) :
                                  @"ButtonView",
                                @(REButtonRoleBatteryStatus) :
                                  @"BatteryStatusButtonView",
                                @(REButtonRoleConnectionStatus) :
                                  @"ConnectionStatusButtonView"
                                }
                            };
                });

  REType elementType = model.elementType;
  NSString * className = index[@(elementType)][@(model.role)];

  if (!className) className = index[@(elementType)][@(RERoleUndefined)];

  return (className ? [[NSClassFromString(className) alloc] initWithModel:model] : nil);
}

/// Default initializer for subclasses.
- (instancetype)initWithModel:(RemoteElement *)model {
  if (model && (self = [super initForAutoLayout])) {
    self.model = model;
    [self.model refresh];
    [self registerForChangeNotification];
    [self initializeIVARs];
  }

  return self;
}

- (void)dealloc {
  self.kvoReceptionists = nil;
}

/// Called from `initWithRemoteElement:`, subclasses that override should include a call to `super`.
- (void)initializeIVARs {
  self.appliedScale  = 1.0;
  self.clipsToBounds = NO;
//    self.translatesAutoresizingMaskIntoConstraints = NO;
  self.opaque                 = NO;
  self.multipleTouchEnabled   = YES;
  self.userInteractionEnabled = YES;

  [self addInternalSubviews];
  [self attachGestureRecognizers];
  [self initializeViewFromModel];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Model property bounces
////////////////////////////////////////////////////////////////////////////////

- (NSString *)uuid        { return self.model.uuid;           }
- (NSString *)key         { return self.model.key;            }
- (NSString *)name        { return self.model.name;           }
- (BOOL)proportionLock    { return self.model.proportionLock; }
- (NSString *)currentMode { return self.model.currentMode;    }

/// Forwards to `RemoteElement` model.
- (id)forwardingTargetForSelector:(SEL)aSelector {
  return (self.model  ?: [super forwardingTargetForSelector:aSelector]);
}

- (id)valueForUndefinedKey:(NSString *)key {
  return (self.model ? [self.model valueForKey:key] : [super valueForUndefinedKey:key]);
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }

- (NSDictionary *)viewFrames {
  NSMutableDictionary * viewFrames =
  [NSMutableDictionary dictionaryWithObjects:[self.subelementViews
                                              valueForKeyPath:@"frame"]
                                     forKeys:[self.subelementViews
                                              valueForKeyPath:@"uuid"]];

  viewFrames[self.uuid] = NSValueWithCGRect(self.frame);

  if (self.parentElementView)
    viewFrames[self.parentElementView.uuid] = NSValueWithCGRect(self.parentElementView.frame);

  return viewFrames;

}

MSSTATIC_STRING_CONST REViewInternalNametag = @"REViewInternal";

- (void)updateConstraints {

  NSString * nametag = ClassNametagWithSuffix(@"Internal");

  if (![self constraintsWithNametagPrefix:nametag]) {
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
        "'%1$@' _overlayView.centerY = self.centerY", nametag);

    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
  }

  NSSet * newREConstraints = [self.model.constraints setByRemovingObjectsFromSet:
                              [[[self constraintsOfType:[RemoteElementLayoutConstraint class]] set]
                               valueForKeyPath:@"modelConstraint"]];

  [self addConstraints:[[newREConstraints setByMappingToBlock:
                         ^RemoteElementLayoutConstraint *(Constraint * constraint) {
                           return [RemoteElementLayoutConstraint constraintWithModel:constraint
                                                                             forView:self];
                         }] allObjects]];

  [super updateConstraints];
}

/// Override point for subclasses to return an array of KVO registration dictionaries for observing
/// model keypaths.
- (MSDictionary *)kvoRegistration {

  MSDictionary * reg = [MSDictionary dictionary];

  reg[@"constraints"] = ^(MSKVOReceptionist * receptionist) {
    [(RemoteElementView *)receptionist.observer setNeedsUpdateConstraints];
  };

  reg[@"backgroundColor"] = ^(MSKVOReceptionist * receptionist) {
    RemoteElementView * view = (RemoteElementView *)receptionist.observer;
    view.backgroundColor = NilSafe(receptionist.change[NSKeyValueChangeNewKey]);
    [view setNeedsDisplay];
  };

  reg[@"backgroundImage"] = ^(MSKVOReceptionist * receptionist) {
    RemoteElementView * view = (RemoteElementView *)receptionist.observer;
    view.backgroundImageView.image =
      [(Image *)NilSafe(receptionist.change[NSKeyValueChangeNewKey]) stretchableImage];
    [view setNeedsDisplay];
  };

  reg[@"style"] = ^(MSKVOReceptionist * receptionist) {
    [(RemoteElementView *)receptionist.observer setNeedsDisplay];
  };


/*
  reg[@"backgroundImageAlpha"] = ^(MSKVOReceptionist * receptionist) {
    RemoteElementView * view = (__bridge RemoteElementView *)receptionist.context;
    view.backgroundImageView.alpha = [(NSNumber *)NilSafe(receptionist.change[NSKeyValueChangeNewKey]) floatValue];
    [view setNeedsDisplay];
  };
*/

  reg[@"shape"] = ^(MSKVOReceptionist * receptionist) {
    [(RemoteElementView *)receptionist.observer refreshBorderPath];
  };

  return reg;
}

/// Override point for subclasses to attach gestures. Called from `initWithRemoteElement`.
- (void)attachGestureRecognizers {}

/// Registers as observer for keypaths of model that appear in the array retained by subclass for
/// `kvoKeypaths`.
- (void)registerForChangeNotification {
  if (self.model) {
    __weak RemoteElementView * weakself = self;
    _kvoReceptionists =
    [[self kvoRegistration] dictionaryByMappingObjectsToBlock:
     ^MSKVOReceptionist *(NSString * keypath, void (^handler)(MSKVOReceptionist * receptionist)) {
       return [MSKVOReceptionist receptionistWithObserver:weakself
                                                forObject:weakself.model
                                                  keyPath:keypath
                                                  options:NSKeyValueObservingOptionNew
                                                    queue:MainQueue
                                                  handler:handler];
    }];
  }
}

/// Override point for subclasses to update themselves with data from the model.
- (void)initializeViewFromModel {
  [super setBackgroundColor:[self.model backgroundColor]];
  self.backgroundImageView.image = (self.model.backgroundImage
                                    ? [self.model.backgroundImage stretchableImage]
                                    : nil);
  [self refreshBorderPath];

  for (RemoteElement * element in self.model.subelements)
    [self addSubelementView:[RemoteElementView viewWithModel:element]];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing constraints
////////////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
  if ([newSuperview isKindOfClass:[REViewSubelements class]])
    self.parentElementView = (RemoteElementView *)newSuperview.superview;
}

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx {
  return _subelementsView.subviews[idx];
}

- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key {
  if ([self.model isIdentifiedByString:key]) return self;
  else
    return [self.subelementViews objectPassingTest:
            ^BOOL (RemoteElementView * obj, NSUInteger idx) {
              return [obj.model isIdentifiedByString:key];
            }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - EditableView Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (CGSize)minimumSize {
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
    NSRange r1 = RangeValue(obj1);
    NSRange r2 = RangeValue(obj2);

    return (r1.location < r2.location
            ? NSOrderedAscending
            : (r1.location > r2.location
               ? NSOrderedDescending
               : NSOrderedSame));
  }];

  [yAxisRanges sortUsingComparator:^NSComparisonResult (NSValue * obj1, NSValue * obj2)
  {
    NSRange r1 = RangeValue(obj1);
    NSRange r2 = RangeValue(obj2);

    return (r1.location < r2.location
            ? NSOrderedAscending
            : (r1.location > r2.location
               ? NSOrderedDescending
               : NSOrderedSame));
  }];

  // join ranges that intersect to create collections of non-intersecting ranges
  int joinCount;

  do {
    NSRange tmpRange = RangeValue(xAxisRanges[0]);

    joinCount = 0;

    NSMutableArray * a = [@[] mutableCopy];

    for (int i = 1; i < xAxisRanges.count; i++) {
      NSRange r = RangeValue(xAxisRanges[i]);
      NSRange j = NSIntersectionRange(tmpRange, r);

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
    NSRange tmpRange = RangeValue(yAxisRanges[0]);

    joinCount = 0;

    NSMutableArray * a = [@[] mutableCopy];

    for (int i = 1; i < yAxisRanges.count; i++) {
      NSRange r = RangeValue(yAxisRanges[i]);
      NSRange j = NSIntersectionRange(tmpRange, r);

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
  CGFloat minWidth = FloatValue([[xAxisRanges arrayByMappingToBlock:
                                  ^id (NSValue * obj, NSUInteger idx) {
    return @(RangeValue(obj).length);
  }] valueForKeyPath:@"@sum.self"]);

  CGFloat minHeight = FloatValue([[yAxisRanges arrayByMappingToBlock:
                                   ^id (NSValue * obj, NSUInteger idx) {
    return @(RangeValue(obj).length);
  }] valueForKeyPath:@"@sum.self"]);

  CGSize s = CGSizeMake(minWidth, minHeight);

  if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, NO);

  return s;
}

- (CGSize)maximumSize {
  // FIXME: Doesn't account for maximum sizes of subelement views
  // to begin with, view must fit inside its superview
  CGSize s = self.superview.bounds.size;

  // TODO: Eventually must handle size-related constraints
  if (self.proportionLock) s = CGSizeAspectMappedToSize(self.bounds.size, s, YES);

  return s;
}

- (UIColor *)backgroundColor { return ([super backgroundColor] ?: self.model.backgroundColor); }

/// Overridden to also call `setNeedsDisplay` on backdrop, content, and overlay subviews.
- (void)setNeedsDisplay {
  [super setNeedsDisplay];

  [_backdropView setNeedsDisplay];
  [_contentView setNeedsDisplay];
  [_subelementsView setNeedsDisplay];
  [_overlayView setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds { [super setBounds:bounds]; [self refreshBorderPath]; }


- (void)setBorderPath:(UIBezierPath *)borderPath {
  _borderPath = borderPath;

  if (_borderPath) {
    self.layer.mask                        = [CAShapeLayer layer];
    ((CAShapeLayer *)self.layer.mask).path = [_borderPath CGPath];
  } else
    self.layer.mask = nil;
}

@end

@implementation RemoteElementView (InternalSubviews)

/// Adds the backdrop, content, and overlay views. Subclasses that override should call `super`.
- (void)addInternalSubviews {

  _backdropView = [REViewBackdrop newForAutolayout];
  [self addSubview:_backdropView];

  _backgroundImageView                 = [UIImageView newForAutolayout];
  _backgroundImageView.contentMode     = UIViewContentModeScaleToFill;
  _backgroundImageView.opaque          = NO;
  _backgroundImageView.backgroundColor = ClearColor;
  [_backdropView addSubview:_backgroundImageView];

  _contentView = [REViewContent newForAutolayout];
  [self addSubview:_contentView];

  _subelementsView = [REViewSubelements newForAutolayout];
  [self addSubview:_subelementsView];

  _overlayView = [REViewOverlay newForAutolayout];
  [self addSubview:_overlayView];
}

- (void)setContentInteractionEnabled:(BOOL)contentInteractionEnabled {
  _contentView.userInteractionEnabled = contentInteractionEnabled;
}

- (BOOL)contentInteractionEnabled { return _contentView.userInteractionEnabled; }

- (void)setSubelementInteractionEnabled:(BOOL)subelementInteractionEnabled {
  _subelementsView.userInteractionEnabled = subelementInteractionEnabled;
}

- (BOOL)subelementInteractionEnabled { return _subelementsView.userInteractionEnabled; }

- (void)setContentClipsToBounds:(BOOL)contentClipsToBounds {
  _contentView.clipsToBounds = contentClipsToBounds;
}

- (BOOL)contentClipsToBounds { return _contentView.clipsToBounds; }

- (void)setOverlayClipsToBounds:(BOOL)overlayClipsToBounds {
  _overlayView.clipsToBounds = overlayClipsToBounds;
}

- (BOOL)overlayClipsToBounds { return _overlayView.clipsToBounds; }
- (void)addViewToContent:(UIView *)view { [_contentView addSubview:view]; }
- (void)addViewToOverlay:(UIView *)view { [_overlayView addSubview:view]; }
- (void)addViewToBackdrop:(UIView *)view { [_backdropView addSubview:view]; }
- (void)addLayerToContent:(CALayer *)layer { [_contentView.layer addSublayer:layer]; }
- (void)addLayerToOverlay:(CALayer *)layer { [_overlayView.layer addSublayer:layer]; }
- (void)addLayerToBackdrop:(CALayer *)layer { [_backdropView.layer addSublayer:layer]; }

@end

@implementation RemoteElementView (Drawing)

- (void)refreshBorderPath {
  switch (self.model.shape) {
    case REShapeRectangle:
      self.borderPath = [UIBezierPath bezierPathWithRect:self.bounds];
      break;

    case REShapeRoundedRectangle:
      self.borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                              byRoundingCorners:UIRectCornerAllCorners
                                                    cornerRadii:self.cornerRadii];
      break;

    case REShapeOval:
      self.borderPath = [MSPainter stretchedOvalFromRect:self.bounds];
      break;

    case REShapeTriangle:
    case REShapeDiamond:
    default:
      self.borderPath = nil;
      break;
  }

}

/// Override point for subclasses to draw into the content subview.
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {}

/// Override point for subclasses to draw into the backdrop subview.
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  if (self.model.shape == REShapeRoundedRectangle) {
    UIGraphicsPushContext(ctx);
    [MSPainter drawRoundedRectButtonBaseInContext:ctx
                                      buttonColor:self.model.backgroundColor
                                      shadowColor:nil
                                           opaque:YES
                                            frame:rect];
    UIGraphicsPopContext();
  } else if (_borderPath)   {
    UIGraphicsPushContext(ctx);
    [self.backgroundColor setFill];
    [_borderPath fill];
    UIGraphicsPopContext();
  }
}

/// Override point for subclasses to draw into the overlay subview.
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  UIBezierPath * path = (_borderPath
                         ? [UIBezierPath bezierPathWithCGPath:_borderPath.CGPath]
                         : [UIBezierPath bezierPathWithRect:rect]);

  UIGraphicsPushContext(ctx);
  [path addClip];

  if (self.model.style & REStyleApplyGloss) {
    switch ((self.model.style & REGlossStyleMask)) {
      case REStyleGlossStyle1:
        [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                         rect:self.bounds
                                      context:UIGraphicsGetCurrentContext()
                                       offset:0.0f];
        break;

      case REStyleGlossStyle2:
        [MSPainter drawRoundedRectButtonOverlayInContext:ctx shineColor:nil frame:rect];
        break;

      case REStyleGlossStyle3:
        [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                         rect:self.bounds
                                      context:UIGraphicsGetCurrentContext()
                                       offset:0.8f];
        break;

      case REStyleGlossStyle4:
        [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                         rect:self.bounds
                                      context:UIGraphicsGetCurrentContext()
                                       offset:-0.8f];
        break;

      default:
        // Other styles not yet implemented
        break;
    }
  }


  if (self.model.style & REStyleDrawBorder) {
    path.lineWidth     = 3.0;
    path.lineJoinStyle = kCGLineJoinRound;
    [BlackColor setStroke];
    [path stroke];
  }

  UIGraphicsPopContext();
}

@end

@implementation RemoteElementView (SubelementViews)

/// Searches content view for subviews of the appropriate type and returns them as an array.
- (NSArray *)subelementViews { return [_subelementsView subviews]; }

- (void)addSubelementView:(RemoteElementView *)view { [_subelementsView addSubview:view]; }
- (void)removeSubelementView:(RemoteElementView *)view { [view removeFromSuperview]; }

- (void)addSubelementViews:(NSSet *)views {
  for (RemoteElementView * view in views) [self addSubelementView:view];
}

- (void)removeSubelementViews:(NSSet *)views {[views makeObjectsPerformSelector:@selector(removeFromSuperview)]; }

- (void)bringSubelementViewToFront:(RemoteElementView *)subelementView {
  [_subelementsView bringSubviewToFront:subelementView];
}

- (void)sendSubelementViewToBack:(RemoteElementView *)subelementView {
  [_subelementsView sendSubviewToBack:subelementView];
}

- (void)insertSubelementView:(RemoteElementView *)subelementView
         aboveSubelementView:(RemoteElementView *)siblingSubelementView
{
  [_subelementsView insertSubview:subelementView aboveSubview:siblingSubelementView];
}

- (void)insertSubelementView:(RemoteElementView *)subelementView atIndex:(NSInteger)index {
  [_subelementsView insertSubview:subelementView atIndex:index];
}

- (void)insertSubelementView:(RemoteElementView *)subelementView
         belowSubelementView:(RemoteElementView *)siblingSubelementView
{
  [_subelementsView insertSubview:subelementView belowSubview:siblingSubelementView];
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal views
////////////////////////////////////////////////////////////////////////////////


@implementation REViewInternal

- (id)init {
  if (self = [super init]) {
    self.userInteractionEnabled = [self isMemberOfClass:[REViewSubelements class]];
    self.backgroundColor        = ClearColor;
    self.clipsToBounds          = NO;
    self.opaque                 = NO;
    self.contentMode            = UIViewContentModeRedraw;
    self.autoresizesSubviews    = NO;
  }

  return self;
}

- (void)willMoveToSuperview:(RemoteElementView *)newSuperview { _delegate = newSuperview; }

@end

@implementation REViewSubelements

- (void)addSubview:(RemoteElementView *)view {
  if ([view isKindOfClass:[RemoteElementView class]] && view.model.parentElement == _delegate.model)
    [super addSubview:view];
}

@end

@implementation REViewContent

/// Calls `drawContentInContext:inRect:`.
- (void)drawRect:(CGRect)rect {
  [_delegate drawContentInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation REViewBackdrop

/// Calls `drawBackdropInContext:inRect:`.
- (void)drawRect:(CGRect)rect {
  [_delegate drawBackdropInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@interface REViewOverlay ()

@property (nonatomic, strong) CAShapeLayer * boundaryOverlay;
@property (nonatomic, strong) CALayer      * alignmentOverlay;
@property (nonatomic, assign) CGSize         renderedSize;
@end

@implementation REViewOverlay

#define PAINT_WITH_STROKE

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  assert(object == _delegate);

  if ([@"borderPath" isEqualToString:keyPath]) {
    __weak REViewOverlay * weakself = self;
    [MainQueue addOperationWithBlock:^{ _boundaryOverlay.path = [weakself boundaryPath]; }];
  }
}

- (CGPathRef)boundaryPath {
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

    [_delegate
         addObserver:self
          forKeyPath:@"borderPath"
             options:NSKeyValueObservingOptionNew
             context:NULL];
  }

  return _boundaryOverlay;
}

- (void)dealloc {
  [_delegate removeObserver:self forKeyPath:@"borderPath"];
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
    self.alignmentOverlay    = [CALayer layer];
    _alignmentOverlay.frame  = self.layer.bounds;
    _alignmentOverlay.hidden = !_showAlignmentIndicators;

    [self.layer addSublayer:_alignmentOverlay];
  }

  return _alignmentOverlay;
}

- (void)setShowAlignmentIndicators:(BOOL)showAlignmentIndicators {
  _showAlignmentIndicators = showAlignmentIndicators;
  [self renderAlignmentOverlayIfNeeded];
}

- (void)renderAlignmentOverlayIfNeeded {
  self.alignmentOverlay.hidden = !_showAlignmentIndicators;

  if (!_showAlignmentIndicators) return;

  ConstraintManager * manager = _delegate.model.constraintManager;

  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

  //// General Declarations
  CGContextRef context = UIGraphicsGetCurrentContext();

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
  CGRect frame = CGRectInset(self.bounds, 3.0, 3.0);

  //// Abstracted Attributes
  CGRect leftBarRect = CGRectMake(CGRectGetMinX(frame) + 1,
                                  CGRectGetMinY(frame) + 3,
                                  2,
                                  CGRectGetHeight(frame) - 6);
  CGFloat leftBarCornerRadius = 1;
  CGRect  rightBarRect        = CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 3,
                                           CGRectGetMinY(frame) + 3,
                                           2,
                                           CGRectGetHeight(frame) - 6);
  CGFloat rightBarCornerRadius = 1;
  CGRect  topBarRect           = CGRectMake(CGRectGetMinX(frame) + 4,
                                            CGRectGetMinY(frame) + 1,
                                            CGRectGetWidth(frame) - 8,
                                            2);
  CGFloat topBarCornerRadius = 1;
  CGRect  bottomBarRect      = CGRectMake(CGRectGetMinX(frame) + 4,
                                          CGRectGetMinY(frame) + CGRectGetHeight(frame) - 3,
                                          CGRectGetWidth(frame) - 8,
                                          2);
  CGFloat bottomBarCornerRadius = 1;
  CGRect  centerXBarRect        = CGRectMake(CGRectGetMinX(frame)
                                             + floor((CGRectGetWidth(frame) - 2) * 0.50000) + 0.5,
                                             CGRectGetMinY(frame) + 4,
                                             2,
                                             CGRectGetHeight(frame) - 7);
  CGFloat centerXBarCornerRadius = 1;
  CGRect  centerYBarRect         = CGRectMake(CGRectGetMinX(frame) + 3.5,
                                              CGRectGetMinY(frame)
                                              + floor((CGRectGetHeight(frame) - 2) * 0.50000 + 0.5),
                                              CGRectGetWidth(frame) - 8,
                                              2);
  CGFloat centerYBarCornerRadius = 1;

  if (manager[NSLayoutAttributeLeft]) {
    //// Left Bar Drawing
    UIBezierPath * leftBarPath = [UIBezierPath bezierPathWithRoundedRect:leftBarRect
                                                            cornerRadius:leftBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeLeft]] setFill];
    [leftBarPath fill];

    ////// Left Bar Inner Shadow
    CGRect leftBarBorderRect = CGRectInset([leftBarPath bounds],
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
      CGFloat xOffset = innerHighlightLeftOffset.width + round(leftBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightLeftOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightLeftBlurRadius,
                                  innerHighlightLeft.CGColor);

      [leftBarPath addClip];

      CGAffineTransform transform =
        CGAffineTransformMakeTranslation(-round(leftBarBorderRect.size.width), 0);

      [leftBarNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [leftBarNegativePath fill];
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
  }

  if (manager[NSLayoutAttributeRight]) {
    //// Right Bar Drawing
    UIBezierPath * rightBarPath = [UIBezierPath bezierPathWithRoundedRect:rightBarRect
                                                             cornerRadius:rightBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeRight]] setFill];
    [rightBarPath fill];

    ////// Right Bar Inner Shadow
    CGRect rightBarBorderRect = CGRectInset([rightBarPath bounds],
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
      CGFloat xOffset = innerHighlightRightOffset.width + round(rightBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightRightOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightRightBlurRadius,
                                  innerHighlightRight.CGColor);

      [rightBarPath addClip];

      CGAffineTransform transform =
        CGAffineTransformMakeTranslation(-round(rightBarBorderRect.size.width), 0);

      [rightBarNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [rightBarNegativePath fill];
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
  }

  if (manager[NSLayoutAttributeTop]) {
    //// Top Bar Drawing
    UIBezierPath * topBarPath = [UIBezierPath bezierPathWithRoundedRect:topBarRect
                                                           cornerRadius:topBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeTop]] setFill];
    [topBarPath fill];

    ////// Top Bar Inner Shadow
    CGRect topBarBorderRect = CGRectInset([topBarPath bounds],
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
      CGFloat xOffset = innerHighlightTopOffset.width + round(topBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightTopOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightTopBlurRadius,
                                  innerHighlightTop.CGColor);

      [topBarPath addClip];

      CGAffineTransform transform =
        CGAffineTransformMakeTranslation(-round(topBarBorderRect.size.width), 0);

      [topBarNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [topBarNegativePath fill];
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
  }

  if (manager[NSLayoutAttributeBottom]) {
    //// Bottom Bar Drawing
    UIBezierPath * bottomBarPath = [UIBezierPath bezierPathWithRoundedRect:bottomBarRect
                                                              cornerRadius:bottomBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeBottom]] setFill];
    [bottomBarPath fill];

    ////// Bottom Bar Inner Shadow
    CGRect bottomBarBorderRect = CGRectInset([bottomBarPath bounds],
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
      CGFloat xOffset = innerHighlightBottomOffset.width + round(bottomBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightBottomOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightBottomBlurRadius,
                                  innerHighlightBottom.CGColor);

      [bottomBarPath addClip];

      CGAffineTransform transform =
        CGAffineTransformMakeTranslation(-round(bottomBarBorderRect.size.width), 0);

      [bottomBarNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [bottomBarNegativePath fill];
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
  }

  if (manager[NSLayoutAttributeCenterX]) {
    //// Center X Bar Drawing
    UIBezierPath * centerXBarPath = [UIBezierPath bezierPathWithRoundedRect:centerXBarRect
                                                               cornerRadius:centerXBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeCenterX]] setFill];
    [centerXBarPath fill];

    ////// Center X Bar Inner Shadow
    CGRect centerXBarBorderRect = CGRectInset([centerXBarPath bounds],
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
      CGFloat xOffset = innerHighlightCenterOffset.width + round(centerXBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightCenterOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightCenterBlurRadius,
                                  innerHighlightCenter.CGColor);

      [centerXBarPath addClip];

      CGAffineTransform transform =
        CGAffineTransformMakeTranslation(-round(centerXBarBorderRect.size.width), 0);

      [centerXBarNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [centerXBarNegativePath fill];
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
  }

  if (manager[NSLayoutAttributeCenterY]) {
    //// Center Y Bar Drawing
    UIBezierPath * centerYBarPath = [UIBezierPath bezierPathWithRoundedRect:centerYBarRect
                                                               cornerRadius:centerYBarCornerRadius];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerHighlightOffset,
                                outerHighlightBlurRadius,
                                outerHighlight.CGColor);
    [colors[[manager dependencyTypeForAttribute:NSLayoutAttributeCenterY]] setFill];
    [centerYBarPath fill];

    ////// Center Y Bar Inner Shadow
    CGRect centerYBarBorderRect = CGRectInset([centerYBarPath bounds],
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
      CGFloat xOffset = innerHighlightCenterOffset.width + round(centerYBarBorderRect.size.width);
      CGFloat yOffset = innerHighlightCenterOffset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset),
                                             yOffset + copysign(0.1, yOffset)),
                                  innerHighlightCenterBlurRadius,
                                  innerHighlightCenter.CGColor);

      [centerYBarPath addClip];

      CGAffineTransform transform =
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

/// Calls `drawOverlayInContext:inRect:`.
- (void)drawRect:(CGRect)rect {
  [_delegate drawOverlayInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation RemoteElementView (Editing)

- (void)setEditing:(BOOL)editing                  { _editingFlags.editing      = editing;      }
- (void)setResizable:(BOOL)resizable              { _editingFlags.resizable    = resizable;    }
- (void)setMoveable:(BOOL)moveable                { _editingFlags.moveable     = moveable;     }
- (void)setShrinkwrap:(BOOL)shrinkwrap            { _editingFlags.shrinkwrap   = shrinkwrap;   }
- (void)setAppliedScale:(CGFloat)appliedScale     { _editingFlags.appliedScale = appliedScale; }
- (void)setLocked:(BOOL)locked {
  _editingFlags.locked = locked;
  [self.subelementViews setValuesForKeysWithDictionary:@{ @"resizable": @(!locked),
                                                          @"moveable" : @(!locked) }];
}
- (void)setEditingMode:(REEditingMode)editingMode {
  _editingFlags.editingMode  = editingMode;
  [self.subelementViews setValue:@(editingMode) forKeyPath:@"editingMode"];
}

- (BOOL)isLocked               { return _editingFlags.locked;                                 }
- (BOOL)isEditing              { return (self.model.elementType & _editingFlags.editingMode); }
- (BOOL)shouldShrinkwrap       { return _editingFlags.shrinkwrap;                             }
- (BOOL)isMoveable             { return _editingFlags.moveable;                               }
- (BOOL)isResizable            { return _editingFlags.resizable;                              }
- (REEditingState)editingState { return _editingFlags.editingState;                           }
- (REEditingMode)editingMode   { return _editingFlags.editingMode;                            }
- (CGFloat)appliedScale        { return _editingFlags.appliedScale;                           }

- (void)scale:(CGFloat)scale {
  CGSize currentSize = self.bounds.size;
  CGSize newSize     = CGSizeApplyScale(currentSize, scale / _editingFlags.appliedScale);
  _editingFlags.appliedScale = scale;
  [self.model.constraintManager resizeElement:self.model
                                     fromSize:currentSize
                                       toSize:newSize
                                      metrics:self.viewFrames];
  [self setNeedsUpdateConstraints];
}

/// Sets border color according to current editing style.
- (void)setEditingState:(REEditingState)editingState {
  _editingFlags.editingState = editingState;

  _overlayView.showAlignmentIndicators = (_editingFlags.editingState == REEditingStateMoving ? YES : NO);
  _overlayView.showContentBoundary     = (_editingFlags.editingState ? YES : NO);

  switch (editingState) {
    case REEditingStateSelected:
      _overlayView.boundaryColor = YellowColor;
      break;

    case REEditingStateMoving:
      _overlayView.boundaryColor = BlueColor;
      break;

    case REEditingStateFocus:
      _overlayView.boundaryColor = RedColor;
      break;

    default:
      _overlayView.boundaryColor = ClearColor;
      break;
  }

  assert((self.subviews)[self.subviews.count - 1] == _overlayView);
  [_overlayView.layer setNeedsDisplay];
}

- (void)updateSubelementOrderFromView {
  self.model.subelements = [NSOrderedSet orderedSetWithArray:
                            [self.subelementViews valueForKey:@"remoteElement"]];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation {
  [self.model.constraintManager
     translateSubelements:[subelementViews valueForKeyPath:@"model"]
              translation:translation
                  metrics:self.viewFrames];

  if (self.shrinkwrap)
    [self.model.constraintManager shrinkWrapSubelements:self.viewFrames];

  [self.subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
  [self setNeedsUpdateConstraints];
}

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale {
  for (RemoteElementView * subelementView in subelementViews) {
    CGSize maxSize    = subelementView.maximumSize;
    CGSize minSize    = subelementView.minimumSize;
    CGSize scaledSize = CGSizeApplyScale(subelementView.bounds.size, scale);
    CGSize newSize    = (CGSizeContainsSize(maxSize, scaledSize)
                         ? (CGSizeContainsSize(scaledSize, minSize)
                            ? scaledSize
                            : minSize)
                         : maxSize);

    [self.model.constraintManager
         resizeElement:subelementView.model
              fromSize:subelementView.bounds.size
                toSize:newSize
               metrics:self.viewFrames];
  }

  if (self.shrinkwrap)
    [self.model.constraintManager shrinkWrapSubelements:self.viewFrames];

  [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
  [self setNeedsUpdateConstraints];
}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute {
  [self.model.constraintManager
     alignSubelements:[subelementViews valueForKeyPath:@"model"]
            toSibling:siblingView.model
            attribute:attribute
              metrics:self.viewFrames];

  if (self.shrinkwrap)
    [self.model.constraintManager shrinkWrapSubelements:self.viewFrames];

  [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
  [self setNeedsUpdateConstraints];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute {
  [self.model.constraintManager
     resizeSubelements:[subelementViews valueForKeyPath:@"model"]
             toSibling:siblingView.model
             attribute:attribute
               metrics:self.viewFrames];

  if (self.shrinkwrap)
    [self.model.constraintManager shrinkWrapSubelements:self.viewFrames];

  [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
  [self setNeedsUpdateConstraints];

}

- (void)willResizeViews:(NSSet *)views {}
- (void)didResizeViews:(NSSet *)views {}

- (void)willScaleViews:(NSSet *)views {}
- (void)didScaleViews:(NSSet *)views {}

- (void)willAlignViews:(NSSet *)views {}
- (void)didAlignViews:(NSSet *)views {}

- (void)willTranslateViews:(NSSet *)views {}
- (void)didTranslateViews:(NSSet *)views {}

@end

@implementation RemoteElementView (Debugging)

- (MSDictionary *)appearanceDescriptionDictionary {
  RemoteElement * element = [self.model faultedObject];

  // backgroundColor, backgroundImage, backgroundImageAlpha, shape, style
  NSString * backgroundString = namedModelObjectDescription(element.backgroundImage);
  NSString * bgAlphaString    = [element.backgroundImageAlpha stringValue];
  NSString * bgColorString    = NSStringFromUIColor(element.backgroundColor);
  NSString * shapeString      = NSStringFromREShape(element.shape);
  NSString * styleString      = NSStringFromREStyle(element.style);
  NSString * proportionString = BOOLString(element.proportionLock);
  NSString * themeString      = namedModelObjectDescription(element.theme);


  MSDictionary * appearanceDictionary = [MSDictionary dictionary];
  appearanceDictionary[@"theme"]                = (themeString ?: @"nil");
  appearanceDictionary[@"shape"]                = (shapeString ?: @"nil");
  appearanceDictionary[@"style"]                = (styleString ?: @"nil");
  appearanceDictionary[@"backgroundImage"]      = (backgroundString ?: @"nil");
  appearanceDictionary[@"backgroundImageAlpha"] = (bgAlphaString ?: @"nil");
  appearanceDictionary[@"backgroundColor"]      = (bgColorString ?: @"nil");
  appearanceDictionary[@"proportionLock"]       = (proportionString ?: @"nil");

  return (MSDictionary *)appearanceDictionary;
}

- (NSString *)appearanceDescription {
  MSDictionary * dd = [self appearanceDescriptionDictionary];

  NSMutableString * description = [@"" mutableCopy];
  [dd enumerateKeysAndObjectsUsingBlock:
   ^(NSString * key, NSString * value, BOOL * stop)
  {
    [description appendFormat:@"%@ %@\n",
     [[key stringByAppendingString:@":"] stringByRightPaddingToLength:22 withCharacter:' '],
     [value stringByShiftingRight:23 shiftFirstLine:NO]];
  }];

  return [description stringByShiftingRight:4];
}

- (NSString *)shortDescription { return self.name; }

- (NSString *)framesDescription {
  NSArray * frames = [[@[self] arrayByAddingObjectsFromArray : self.subelementViews]
                      arrayByMappingToBlock:^id (RemoteElementView * obj, NSUInteger idx)
  {
    NSString * nameString = [obj.name camelCase];

    NSString * originString = $(@"(%6s,%6s)",
                                UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.x))),
                                UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.y))));

    NSString * sizeString = $(@"%6s x %6s",
                              UTF8(StripTrailingZeros($(@"%f", obj.frame.size.width))),
                              UTF8(StripTrailingZeros($(@"%f", obj.frame.size.height))));

    return $(@"%@\t%@\t%@", nameString, originString, sizeString);
  }];

  return [[@"Element\t    Origin       \t      Size        \n" stringByAppendingString:
           [frames componentsJoinedByString:@"\n"]] singleBarHeaderBox:20];
}

- (NSString *)constraintsDescription {
  return $(@"%@\n%@\n\n%@",
           [$(@"%@", self.name) singleBarMessageBox],
           [self.model constraintsDescription],
           [self viewConstraintsDescription]);
}

- (NSString *)modelConstraintsDescription {
  return [self.model constraintsDescription];
}

- (NSString *)viewConstraintsDescription {
  NSMutableString * description        = [@"" mutableCopy];
  NSArray         * modeledConstraints = [self constraintsOfType:[RemoteElementLayoutConstraint class]];

  if (modeledConstraints.count)
    [description appendFormat:@"\nview constraints (modeled):\n\t%@",
     [[modeledConstraints valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];

  NSArray * unmodeledConstraints = [self constraintsOfType:[NSLayoutConstraint class]];

  if (unmodeledConstraints.count)
    [description appendFormat:@"\n\nview constraints (unmodeled):\n\t%@",
     [[unmodeledConstraints arrayByMappingToBlock:
       ^id (id obj, NSUInteger idx) {
      return prettyRemoteElementConstraint(obj);
    }] componentsJoinedByString:@"\n\t"]];

  if (!modeledConstraints.count && !unmodeledConstraints.count)
    [description appendString:@"no constraints"];

  return description;
}

@end

NSString *prettyRemoteElementConstraint(NSLayoutConstraint * constraint) {
  static NSString *(^itemNameForView)(UIView *) = ^(UIView * view) {
    return (view
            ? ([view isKindOfClass:[RemoteElementView class]]
               ? [((RemoteElementView *)view).name camelCase]
               : (view.accessibilityIdentifier
                  ?: $(@"<%@:%p>", ClassString([view class]), view)
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

