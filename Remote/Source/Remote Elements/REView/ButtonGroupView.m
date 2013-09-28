//
// ButtonGroupView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteElementView_Private.h"

MSNAMETAG_DEFINITION(ButtonGroupViewInternal);
MSNAMETAG_DEFINITION(ButtonGroupViewLabel);

static int   ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation ButtonGroupView

- (void)updateConstraints
{
    [super updateConstraints];

    if (![self constraintsWithNametagPrefix:ButtonGroupViewInternalNametag])
    {
        NSString * constraints =
              $(@"'%1$@' _label.width = self.width\n"
              "'%1$@' _label.height = self.height\n"
              "'%1$@' _label.centerX = self.centerX\n"
              "'%1$@' _label.centerY = self.centerY",
              $(@"%@-%@", ButtonGroupViewInternalNametag, ButtonGroupViewLabelNametag));

        [self addConstraints:
         [NSLayoutConstraint
          constraintsByParsingString:constraints
                               views:NSDictionaryOfVariableBindings(self, _label)]];
    }


}

- (CGSize)intrinsicContentSize
{
    switch ((uint64_t)self.type)
    {
        case REButtonGroupTypeToolbar:
            return CGSizeMake(MainScreen.bounds.size.width, 44.0);

        default:
            return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    }
}

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    [self.subelementViews setValuesForKeysWithDictionary:@{@"resizable": @(!_locked),
                                                           @"moveable" : @(!_locked)}];
}

- (void)buttonViewDidExecute:(ButtonView *)buttonView
{
    if (self.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)tuck {
    if (_isPanel && _tuckedConstraint && _untuckedConstraint) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _untuckedConstraint.priority = 1;
                             _tuckedConstraint.priority = 999;
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
    if (_isPanel && _tuckedConstraint && _untuckedConstraint) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _tuckedConstraint.priority = 1;
                             _untuckedConstraint.priority = 999;
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

- (void)tuckAction:(id)sender
{
    [self tuck];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (gesture == _tuckGesture)
            [self tuck];
        else if (gesture == _untuckGesture)
            [self untuck];
    }
}

- (void)didMoveToWindow
{
    if (_isPanel && !self.isEditing) {
        if (self.window)
        {
            [self.window addGestureRecognizer:_tuckGesture];
            [self.window addGestureRecognizer:_untuckGesture];
        }
        else
        {
            [_tuckGesture.view removeGestureRecognizer:_tuckGesture];
            [_untuckGesture.view removeGestureRecognizer:_untuckGesture];
        }
    }
}

- (NSDictionary *)kvoRegistration
{
    // TODO: observe panel location
    __strong NSDictionary * kvoRegistration =
        @{@"label" : MSMakeKVOHandler({
            id   newValue = change[NSKeyValueChangeNewKey];
            _label.attributedText = (ValueIsNotNil(newValue) ? (NSAttributedString*)newValue : nil);
        })};

    return [[super kvoRegistration] dictionaryByAddingEntriesFromDictionary:kvoRegistration];
}

- (void)initializeIVARs
{
    [super initializeIVARs];

    self.shrinkwrap  = YES;
    self.resizable   = YES;
    self.moveable    = YES;
    self.cornerRadii = CGSizeMake(5.0f, 5.0f);

    if (self.type == REButtonGroupTypeToolbar)
    {
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                              forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                              forAxis:UILayoutConstraintAxisVertical];
    }
}

- (void)initializeViewFromModel {
    [super initializeViewFromModel];
    _isPanel = [self.model isPanel];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    if (self.superview && _isPanel && !self.isEditing)
    {
        _tuckGesture = [[MSSwipeGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handleSwipe:)];
        _tuckGesture.nametag = $(@"'%@'-tuck", self.name);
        _tuckGesture.enabled = NO;
        _untuckGesture = [[MSSwipeGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(handleSwipe:)];
        _untuckGesture.nametag = $(@"'%@'-untuck", self.name);

        NSLayoutAttribute attribute1, attribute2;
        switch (self.model.panelLocation)
        {
            case REPanelLocationTop:
                attribute1   = NSLayoutAttributeBottom;
                attribute2   = NSLayoutAttributeTop;
                _tuckGesture.direction = UISwipeGestureRecognizerDirectionUp;
                _untuckGesture.direction = UISwipeGestureRecognizerDirectionDown;
                _tuckGesture.quadrant = _untuckGesture.quadrant = MSSwipeGestureRecognizerQuadrantUp;
                break;

            case REPanelLocationBottom:
                attribute1   = NSLayoutAttributeTop;
                attribute2   = NSLayoutAttributeBottom;
                _tuckGesture.direction = UISwipeGestureRecognizerDirectionDown;
                _untuckGesture.direction = UISwipeGestureRecognizerDirectionUp;
                _tuckGesture.quadrant = _untuckGesture.quadrant = MSSwipeGestureRecognizerQuadrantDown;
                break;

            case REPanelLocationLeft:
                attribute1   = NSLayoutAttributeRight;
                attribute2   = NSLayoutAttributeLeft;
                _tuckGesture.direction = UISwipeGestureRecognizerDirectionLeft;
                _untuckGesture.direction = UISwipeGestureRecognizerDirectionRight;
                _tuckGesture.quadrant = _untuckGesture.quadrant = MSSwipeGestureRecognizerQuadrantLeft;
                break;

            case REPanelLocationRight:
                attribute1   = NSLayoutAttributeLeft;
                attribute2   = NSLayoutAttributeRight;
                _tuckGesture.direction = UISwipeGestureRecognizerDirectionRight;
                _untuckGesture.direction = UISwipeGestureRecognizerDirectionLeft;
                _tuckGesture.quadrant = _untuckGesture.quadrant = MSSwipeGestureRecognizerQuadrantRight;
                break;

            default:
                assert(NO);
                break;
        }
        _tuckedConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:attribute1
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:attribute2
                                                        multiplier:1.0f
                                                          constant:0.0f];
        _tuckedConstraint.priority = 999;
        _tuckedConstraint.nametag = REButtonGroupPanelNametag;
        _untuckedConstraint = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:attribute2
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:attribute2
                                                          multiplier:1.0f
                                                            constant:0.0f];
        _untuckedConstraint.priority = 1;
        _untuckedConstraint.nametag = REButtonGroupPanelNametag;
        [self.superview addConstraints:@[_tuckedConstraint, _untuckedConstraint]];
    }
}

- (void)addSubelementView:(ButtonView *)view
{
    if (_locked) [view setValuesForKeysWithDictionary:@{@"resizable" : @NO,
                                                        @"moveable"  : @NO}];

    if (view.type == REButtonTypeTuck)
    {
        __weak ButtonGroupView * weakself = self;
        __weak ButtonView      * weakview = view;
        [view setActionHandler:^{ [weakself tuckAction:weakview]; }
                     forAction:RESingleTapAction];
    }

    [super addSubelementView:view];
}

- (void)addInternalSubviews
{
    [super addInternalSubviews];

    _label = [UILabel newForAutolayout];
    _label.backgroundColor = ClearColor;

    [self addViewToContent:_label];
}

- (void)setEditingMode:(REEditingMode)mode
{
    [super setEditingMode:mode];

    self.resizable = (self.editingMode == REEditingModeNotEditing) ? YES : NO;
    self.moveable  = (self.editingMode == REEditingModeNotEditing) ? YES : NO;

    if (self.editingMode == RERemoteEditingMode)
        self.subelementInteractionEnabled = NO;

    else if (self.editingMode == REButtonGroupEditingMode)
        self.subelementInteractionEnabled = YES;

    [self.subelementViews setValue:@(mode) forKeyPath:@"editingMode"];
}

- (void)setMoveable:(BOOL)moveable
{
    [super setMoveable:moveable];
}

- (ButtonView *)objectAtIndexedSubscript:(NSUInteger)idx {
    return (ButtonView *)[super objectAtIndexedSubscript:idx];
}

- (ButtonView *)objectForKeyedSubscript:(NSString *)key {
    return (ButtonView *)[super objectForKeyedSubscript:key];
}

@end

@implementation ButtonGroupView (Drawing)

- (void)drawRoundedPanelInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    REPanelLocation   panelLocation = self.model.panelLocation;

    CGContextClearRect(ctx, self.bounds);

    NSUInteger   roundedCorners = (panelLocation == REPanelLocationRight
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

    CGRect    insetRect = CGRectInset(self.bounds, 0, 3);
    CGFloat   tx        = (panelLocation == REPanelLocationRight ? 3 : -3);

    insetRect = CGRectApplyAffineTransform(insetRect, CGAffineTransformMakeTranslation(tx, 0));

    bezierPath = [UIBezierPath bezierPathWithRoundedRect:insetRect
                                       byRoundingCorners:roundedCorners
                                             cornerRadii:CGSizeMake(12, 12)];
    bezierPath.lineWidth = 2.0;
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
}

@end

