//
//  RemoteElementEditingViewController+Gestures.m
//  iPhonto
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController_Private.h"
#import "RemoteElementView_Private.h"
//#import "MSRemoteConstants.h"
#import "MSRemoteMacros.h"

#define UNDO_BUTTON_INDEX 2

#define MSLogDebugGesture                 \
    MSLogDebug(EDITOR_F_C,                \
               @"%@ %@ state: %@",        \
               ClassTagSelectorString,    \
               gestureRecognizer.nametag, \
               NSStringFromUIGestureRecognizerState(gestureRecognizer.state));


static const int   ddLogLevel = LOG_LEVEL_DEBUG;
//static const int ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation RemoteElementEditingViewController (Gestures)

- (void)attachGestureRecognizers
{
    self.gestures = [NSPointerArray weakObjectsPointerArray];

    // long press to translate selected views
    ////////////////////////////////////////////////////////////////////////////////
    self.longPressGesture = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self
                                     action:@selector(handleLongPress:)];
    _longPressGesture.nametag = @"longPressGesture";
    _longPressGesture.delegate = self;
    [self.view addGestureRecognizer:_longPressGesture];
    [_gestures addPointer:(__bridge void *)(_longPressGesture)];

    // pinch to scale selected views
    ////////////////////////////////////////////////////////////////////////////////
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]
                         initWithTarget:self
                                 action:@selector(handlePinch:)];
    _pinchGesture.nametag = @"pinchGesture";
    _pinchGesture.delegate = self;
    [self.view addGestureRecognizer:_pinchGesture];
    [_gestures addPointer:(__bridge void *)(_pinchGesture)];

    // double tap to set a focus view
    ////////////////////////////////////////////////////////////////////////////////
    self.oneTouchDoubleTapGesture = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                             action:@selector(handleTap:)];
    _oneTouchDoubleTapGesture.nametag = @"oneTouchDoubleTapGesture";
    _oneTouchDoubleTapGesture.numberOfTapsRequired = 2;
    _oneTouchDoubleTapGesture.delegate             = self;
    [self.view addGestureRecognizer:_oneTouchDoubleTapGesture];
    [_gestures addPointer:(__bridge void *)(_oneTouchDoubleTapGesture)];

    // drag/touch to select views
    ////////////////////////////////////////////////////////////////////////////////
    self.multiselectGesture = [[MSMultiselectGestureRecognizer alloc]
                                  initWithTarget:self
                                          action:@selector(handleSelection:)];
    _multiselectGesture.nametag  = @"multiselectGesture";
    _multiselectGesture.delegate = self;
    _multiselectGesture.maximumNumberOfTouches = 1;
    _multiselectGesture.minimumNumberOfTouches = 1;
    [_multiselectGesture requireGestureRecognizerToFail:_oneTouchDoubleTapGesture];
    [self.view addGestureRecognizer:_multiselectGesture];
    [_gestures addPointer:(__bridge void *)(_multiselectGesture)];

    // anchored drag/touch to deselect views
    ////////////////////////////////////////////////////////////////////////////////
    self.anchoredMultiselectGesture = [[MSMultiselectGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleSelection:)];
    _anchoredMultiselectGesture.nametag  = @"anchoredMultiselectGesture";
    _anchoredMultiselectGesture.delegate = self;
    _anchoredMultiselectGesture.maximumNumberOfTouches = 1;
    _anchoredMultiselectGesture.minimumNumberOfTouches = 1;
    _anchoredMultiselectGesture.numberOfAnchorTouchesRequired = 1;
    [_pinchGesture requireGestureRecognizerToFail:_anchoredMultiselectGesture];
    [_multiselectGesture requireGestureRecognizerToFail:_anchoredMultiselectGesture];
    [self.view addGestureRecognizer:_anchoredMultiselectGesture];
    [_gestures addPointer:(__bridge void *)(_anchoredMultiselectGesture)];

    // two finger pan to scroll if source view extends out of sight
    ////////////////////////////////////////////////////////////////////////////////
    self.twoTouchPanGesture = [[UIPanGestureRecognizer alloc]
                               initWithTarget:self
                                       action:@selector(handlePan:)];
    _twoTouchPanGesture.nametag = @"twoTouchPanGesture";
    _twoTouchPanGesture.minimumNumberOfTouches = 2;
    _twoTouchPanGesture.maximumNumberOfTouches = 2;
    _twoTouchPanGesture.delegate               = self;
    [self.view addGestureRecognizer:_twoTouchPanGesture];
    [_multiselectGesture requireGestureRecognizerToFail:_twoTouchPanGesture];
    _twoTouchPanGesture.enabled = NO;
    [_gestures addPointer:(__bridge void *)(_twoTouchPanGesture)];

    // long press to translate selected views
    ////////////////////////////////////////////////////////////////////////////////
    self.toolbarLongPressGesture = [[UILongPressGestureRecognizer alloc]
                                    initWithTarget:self
                                            action:@selector(handleLongPress:)];
    _toolbarLongPressGesture.nametag = @"toolbarLongPressGesture";
    _toolbarLongPressGesture.delegate = self;
    [_longPressGesture requireGestureRecognizerToFail:_toolbarLongPressGesture];
    [_undoButton addGestureRecognizer:_toolbarLongPressGesture];
    [_gestures addPointer:(__bridge void *)(_toolbarLongPressGesture)];

    [self createGestureManager];

}  /* attachGestureRecognizers */

- (void)createGestureManager {
    NSMutableArray * gestureBlocks = [NSMutableArray arrayWithNullCapacity:_gestures.count];
    NSArray * gestures = @[_pinchGesture,
                           _longPressGesture,
                           _toolbarLongPressGesture,
                           _twoTouchPanGesture,
                           _oneTouchDoubleTapGesture,
                           _multiselectGesture,
                           _anchoredMultiselectGesture];
    __weak RemoteElementEditingViewController *weakSelf = self;

    MSGestureManagerBlock receiveTouchDefault =
    ^BOOL(UIGestureRecognizer * gesture, UITouch * touch) {
        return ([weakSelf.toolbars
                 objectPassingTest:^BOOL(UIToolbar * obj, NSUInteger idx, BOOL *stop) {
                     return [touch.view isDescendantOfView:obj];
                 }] || _flags.popoverActive || _flags.menuState != REEditingMenuStateDefault
                ? NO :
                YES);
    };

    MSGestureManagerBlock notMovingBlock =
    ^BOOL(UIGestureRecognizer * gesture, id unused) {
        return !_flags.movingSelectedViews;
    };

    MSGestureManagerBlock hasSelectionBlock =
    ^BOOL(UIGestureRecognizer * gesture, id unused) {
        return weakSelf.selectionCount;
    };

    // pinch
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeBegin):hasSelectionBlock,
     @(MSGestureManagerResponseTypeReceiveTouch):receiveTouchDefault
     }];

    // long press
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault,
     @(MSGestureManagerResponseTypeRecognizeSimultaneously):
     (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) {
        return [@"toolbarLongPressGesture" isEqualToString:other.nametag];
    }}];

    // toolbar long press
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault,
     @(MSGestureManagerResponseTypeRecognizeSimultaneously):
     (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) {
        return [@"longPressGesture" isEqualToString:other.nametag];
    }}];

    // two touch pan
    [gestureBlocks addObject:@{@(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault}];

    // one touch double tap
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeBegin): notMovingBlock,
     @(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault
     }];

    // multiselect
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeBegin): notMovingBlock,
     @(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault,
     @(MSGestureManagerResponseTypeRecognizeSimultaneously):
     (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) {
        return [@"anchoredMultiselectGesture" isEqualToString:other.nametag];
    }}];

    // anchored multiselect
    [gestureBlocks addObject:@{
     @(MSGestureManagerResponseTypeBegin): notMovingBlock,
     @(MSGestureManagerResponseTypeReceiveTouch): receiveTouchDefault,
     @(MSGestureManagerResponseTypeRecognizeSimultaneously):
     (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) {
        return [@"multiselectGesture" isEqualToString:other.nametag];
    }}];

    self.gestureManager = [MSGestureManager gestureManagerForGestures:gestures
                                                               blocks:gestureBlocks];
}

- (void)updateGesturesEnabled
{
    BOOL   focused   = (_focusView ? YES : NO);
    BOOL   moving    = _flags.movingSelectedViews;
    BOOL   selection = (self.selectionCount ? YES : NO);

    _longPressGesture.enabled           = !focused;
    _pinchGesture.enabled               = selection;
    _oneTouchDoubleTapGesture.enabled   = !moving;
    _multiselectGesture.enabled         = !moving;
    _anchoredMultiselectGesture.enabled = !moving;

    MSLogDebug(EDITOR_F_C,
               @"%@\n\t%@",
               ClassTagSelectorString,
               [[[_gestures allObjects]
                 arrayByMappingToBlock:^NSString *(UIGestureRecognizer * obj, NSUInteger idx) {
                    return $(@"%@: %@", obj.nametag, (obj.enabled ? @"enabled" : @"disabled"));
                }] componentsJoinedByString:@"\n\t"]);
}

- (IBAction)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    assert(gestureRecognizer == _oneTouchDoubleTapGesture);

    MSLogDebugGesture;

    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        UIView * view = [self.view hitTest:[gestureRecognizer locationInView:self.view] withEvent:nil];

        if ([view isKindOfClass:_selectableClass])
        {
            if (![_selectedViews containsObject:view]) [self selectView:(RemoteElementView *)view];

            self.focusView = (_focusView == view ? nil : (RemoteElementView *)view);
        }
    }
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    MSLogDebugGesture;

    if (gestureRecognizer == _longPressGesture)
    {
        switch (gestureRecognizer.state)
        {
            case UIGestureRecognizerStateBegan :
            {
                UIView * view = [self.view hitTest:[gestureRecognizer locationInView:self.view] withEvent:nil];

                if ([view isKindOfClass:_selectableClass])
                {
                    if (![_selectedViews containsObject:view]) [self selectView:(RemoteElementView *)view];

                    for (RemoteElementView * view in _selectedViews)
                    {
                        view.editingStyle = EditingStyleMoving;
                    }

                    _flags.movingSelectedViews = YES;
                    [self updateState];
                    _flags.longPressPreviousLocation = [gestureRecognizer locationInView:nil];
                    [self willMoveSelectedViews];
                }
            }
            break;

            case UIGestureRecognizerStateChanged :
            {
                CGPoint   currentLocation = [gestureRecognizer locationInView:nil];
                CGPoint   translation     = CGPointGetDelta(currentLocation, _flags.longPressPreviousLocation);

                _flags.longPressPreviousLocation = currentLocation;
                [self moveSelectedViewsWithTranslation:translation];
            }
            break;

            case UIGestureRecognizerStateCancelled :
            case UIGestureRecognizerStateFailed :
            case UIGestureRecognizerStateEnded :
                [self didMoveSelectedViews];
                break;

            case UIGestureRecognizerStatePossible :
                break;
        }  /* switch */

    }
    else if (gestureRecognizer == _toolbarLongPressGesture)
    {
        switch (gestureRecognizer.state)
        {
            case UIGestureRecognizerStateBegan :
                [_undoButton.button setTitle:[UIFont fontAwesomeIconForName:@"repeat"]
                                    forState:UIControlStateNormal];
                _undoButton.button.selected = YES;
                break;

            case UIGestureRecognizerStateChanged :
                if (![_undoButton.button
                      pointInside:[gestureRecognizer locationInView:_undoButton.button]
                        withEvent:nil])
                {
                    _undoButton.button.selected = NO;
                    gestureRecognizer.enabled   = NO;
                }

                break;

            case UIGestureRecognizerStateRecognized :
                [self redo:nil];

            case UIGestureRecognizerStateCancelled :
            case UIGestureRecognizerStateFailed :
            case UIGestureRecognizerStatePossible :
                gestureRecognizer.enabled   = YES;
                _undoButton.button.selected = NO;
                [_undoButton.button setTitle:[UIFont fontAwesomeIconForName:@"undo"]
                                    forState:UIControlStateNormal];
                break;
        }
    }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    MSLogDebugGesture;

    if (gestureRecognizer == _pinchGesture)
    {
        switch (gestureRecognizer.state)
        {
            case UIGestureRecognizerStateBegan :
                [self willScaleSelectedViews];
                break;

            case UIGestureRecognizerStateChanged :
                [self scaleSelectedViews:gestureRecognizer.scale validation:nil];
                break;

            case UIGestureRecognizerStateCancelled :
            case UIGestureRecognizerStateFailed :
            case UIGestureRecognizerStateEnded :
                [self didScaleSelectedViews];
                break;

            case UIGestureRecognizerStatePossible :
                break;
        }  /* switch */

    }
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    MSLogDebugGesture;

    static CGFloat   startingOffset = 0.0f;

    if (gestureRecognizer == _twoTouchPanGesture)
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
            startingOffset = self.sourceViewCenterYConstraint.constant;
        else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGPoint   translation    = [gestureRecognizer translationInView:self.view];
            CGFloat   adjustedOffset = startingOffset + translation.y;
            BOOL      isInBounds     = MSValueInBounds(adjustedOffset, _flags.allowableSourceViewYOffset);
            CGFloat   newOffset      = (isInBounds
                                        ? adjustedOffset
                                        : (adjustedOffset < _flags.allowableSourceViewYOffset.lower
                                           ? _flags.allowableSourceViewYOffset.lower
                                           : _flags.allowableSourceViewYOffset.upper
                                           )
                                        );

            if (self.sourceViewCenterYConstraint.constant != newOffset)
            {
                [UIView animateWithDuration:0.1f
                                      delay:0.0f
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     self.sourceViewCenterYConstraint.constant = newOffset;
                                     [self.view layoutIfNeeded];
                                 }

                                 completion:nil];
            }
        }
    }
}

- (IBAction)toggleSelected:(UIButton *)sender { sender.selected = !sender.selected; }

- (void)displayStackedViewDialogForViews:(NSSet *)stackedViews
{
    MSLogDebug(EDITOR_F, @"%@ select stacked views to include: (%@)",
               ClassTagSelectorString,
               [[[stackedViews allObjects] valueForKey:@"displayName"]
                componentsJoinedByString:@", "]);

    _flags.menuState = REEditingMenuStateStackedViews;

    MenuController.menuItems = [[stackedViews allObjects]
                                arrayByMappingToBlock:^UIMenuItem *(RemoteElementView * obj, NSUInteger idx) {
                                    SEL action = NSSelectorFromString($(@"menuAction%@:",obj.identifier));

                                    return MenuItem(obj.displayName, action);
                                }];

    [MenuController setTargetRect:[self.view.window convertRect:[UIView
                                                                 unionFrameForViews:[stackedViews
                                                                                     allObjects]]
                                                       fromView:_sourceView]
                           inView:self.view];
    MenuController.arrowDirection = UIMenuControllerArrowDefault;
    [MenuController update];
    MenuController.menuVisible = YES;

}

- (IBAction)handleSelection:(MSMultiselectGestureRecognizer *)gestureRecognizer
{
    MSLogDebugGesture;

    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        SEL action = (gestureRecognizer == _anchoredMultiselectGesture
                      ? @selector(deselectViews:)
                      : @selector(selectViews:)
                      );

        NSSet        * touchLocations         = [gestureRecognizer touchLocationsInView:_sourceView];
        NSMutableSet * touchedSubelementViews = [[gestureRecognizer touchedSubviewsInView:_sourceView
                                                                                   ofKind:_selectableClass] mutableCopy];

        if (touchedSubelementViews.count)
        {
            NSMutableDictionary * viewsPerTouch = [NSMutableDictionary dictionaryWithCapacity:touchLocations.count];

            [touchLocations enumerateObjectsUsingBlock:^(NSValue * obj, BOOL *stop) {
                                viewsPerTouch[obj] = [_sourceView.subelementViews
                                                      filteredArrayUsingPredicateWithBlock:
                                                      ^BOOL(RemoteElementView * evaluatedObject, NSDictionary *bindings) {
                                                          return [evaluatedObject pointInside:[evaluatedObject convertPoint:Point(obj)
                                                                                                                   fromView:_sourceView]
                                                                                    withEvent:nil];
                                                      }];
            }];

            NSSet * stackedLocations = [viewsPerTouch keysOfEntriesPassingTest:^BOOL(id key, NSArray * obj, BOOL *stop) {
                return (ValueIsNotNil(obj) && obj.count > 1);
            }];

            if (stackedLocations.count)
            {
                NSSet * stackedViews = [NSSet setWithArrays:[viewsPerTouch allValues]];

                [touchedSubelementViews minusSet:stackedViews];
                [self displayStackedViewDialogForViews:stackedViews];
            }

            SuppressPerformSelectorLeakWarning([self performSelector:action withObject:touchedSubelementViews];)

    }
        else if (_selectedViews.count) [self deselectAll];

    }
}

@end
