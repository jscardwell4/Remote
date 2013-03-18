//
//  RemoteElementEditingViewController+Gestures.m
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController_Private.h"
#import "REView_Private.h"
//#import "MSRemoteConstants.h"
#import "MSRemoteMacros.h"

#define UNDO_BUTTON_INDEX 2

#define MSLogDebugGesture                 \
    MSLogDebug(@"%@ %@ state: %@",        \
               ClassTagSelectorString,    \
               gestureRecognizer.nametag, \
               UIGestureRecognizerStateString(gestureRecognizer.state));


static const int   ddLogLevel   = DefaultDDLogLevel;
static const int   msLogContext = EDITOR_F;
#pragma unused(ddLogLevel, msLogContext)


@implementation REEditingViewController (Gestures)

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
    __weak REEditingViewController *weakSelf = self;

#define ShouldBegin                   @(MSGestureManagerResponseTypeBegin)
#define ShouldReceiveTouch            @(MSGestureManagerResponseTypeReceiveTouch)
#define ShouldRecognizeSimultaneously @(MSGestureManagerResponseTypeRecognizeSimultaneously)

#define RecognizeSimultaneouslyBlock(name)                                                   \
    (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) \
    {                                                                                        \
        return [name isEqualToString:other.nametag];                                         \
    }

#define ReceiveTouchBlock(condition)                                             \
    (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, UITouch * touch) \
    {                                                                            \
        return condition;                                                        \
    }

#define ShouldBeginBlock(condition)                                              \
    (MSGestureManagerBlock)^BOOL(UIGestureRecognizer * gesture, id unused)       \
    {                                                                            \
        return condition;                                                        \
    }

    // general blocks

    MSGestureManagerBlock notMovingBlock = ShouldBeginBlock(!_flags.movingSelectedViews);

    MSGestureManagerBlock hasSelectionBlock = ShouldBeginBlock(weakSelf.selectionCount);

    MSGestureManagerBlock noPopovers =
        ShouldBeginBlock(!_flags.popoverActive && _flags.menuState == REEditingMenuStateDefault);

    MSGestureManagerBlock noToolbars =
        ReceiveTouchBlock(![weakSelf.toolbars objectPassingTest:
                            ^BOOL(UIToolbar * obj, NSUInteger idx) {
                                return [touch.view isDescendantOfView:obj];
                            }]);

    MSGestureManagerBlock selectableClassBlock =
        ReceiveTouchBlock([touch.view isKindOfClass:_selectableClass]);

    // pinch
    [gestureBlocks addObject:@{
         ShouldBegin        : hasSelectionBlock,
         ShouldReceiveTouch : ReceiveTouchBlock(noPopovers(gesture, touch) && noToolbars(gesture, touch))
     }];

    // long press
    [gestureBlocks addObject:@{
         ShouldReceiveTouch            : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                          && noToolbars(gesture, touch)
                                                          && selectableClassBlock(gesture, touch)),
         ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"toolbarLongPressGesture")
     }];

    // toolbar long press
    [gestureBlocks addObject:@{
         ShouldReceiveTouch            : ReceiveTouchBlock(   noPopovers(gesture, touch)
                                                           && [touch.view isDescendantOfView:_topToolbar]),
         ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"longPressGesture")
     }];

    // two touch pan
    [gestureBlocks addObject:@{
         ShouldReceiveTouch: ReceiveTouchBlock(noPopovers(gesture, touch) && noToolbars(gesture, touch))
     }];

    // one touch double tap
    [gestureBlocks addObject:@{
         ShouldBegin        : notMovingBlock,
         ShouldReceiveTouch : ReceiveTouchBlock(noPopovers(gesture, touch) && noToolbars(gesture, touch))
     }];

    // multiselect
    [gestureBlocks addObject:@{
         ShouldBegin 			 				: notMovingBlock,
         ShouldReceiveTouch 			: ReceiveTouchBlock(   noPopovers(gesture, touch)
                                                            && noToolbars(gesture, touch)),
         ShouldRecognizeSimultaneously  : RecognizeSimultaneouslyBlock(@"anchoredMultiselectGesture")
     }];

    // anchored multiselect
    [gestureBlocks addObject:@{
         ShouldBegin                   : notMovingBlock,
         ShouldReceiveTouch            : ReceiveTouchBlock(   noPopovers(gesture, touch)
                                                           && noToolbars(gesture, touch)),
         ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"multiselectGesture")
    }];

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

    MSLogDebug(@"%@\n\t%@",
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
            if (![_selectedViews containsObject:view])
                [self selectView:(REView *)view];

            self.focusView = (_focusView == view ? nil : (REView *)view);
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
            case UIGestureRecognizerStateBegan:
            {
                UIView * view = [self.view hitTest:[gestureRecognizer locationInView:self.view]
                                         withEvent:nil];

                if ([view isKindOfClass:_selectableClass])
                {
                    if (![_selectedViews containsObject:view])
                        [self selectView:(REView*)view];

                    for (REView * view in _selectedViews)
                        view.editingStyle = EditingStyleMoving;

                    _flags.movingSelectedViews = YES;
                    [self updateState];
                    _flags.longPressPreviousLocation = [gestureRecognizer locationInView:nil];
                    [self willTranslateSelectedViews];
                }
            }
            break;

            case UIGestureRecognizerStateChanged:
            {
                CGPoint   currentLocation = [gestureRecognizer locationInView:nil];
                CGPoint   translation     = CGPointGetDelta(currentLocation,
                                                            _flags.longPressPreviousLocation);

                _flags.longPressPreviousLocation = currentLocation;
                [self translateSelectedViews:translation];
            }
            break;

            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateEnded:
                [self didTranslateSelectedViews];
                break;

            case UIGestureRecognizerStatePossible:
                break;
        }

    }
    else if (gestureRecognizer == _toolbarLongPressGesture)
    {
        switch (gestureRecognizer.state)
        {
            case UIGestureRecognizerStateBegan:
                [_undoButton.button setTitle:[UIFont fontAwesomeIconForName:@"repeat"]
                                    forState:UIControlStateNormal];
                _undoButton.button.selected = YES;
                break;

            case UIGestureRecognizerStateChanged:

                if (![_undoButton.button
                      pointInside:[gestureRecognizer locationInView:_undoButton.button]
                        withEvent:nil])
                {
                    _undoButton.button.selected = NO;
                    gestureRecognizer.enabled   = NO;
                }

                break;

            case UIGestureRecognizerStateRecognized:
                [self redo:nil];

            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStatePossible:
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
            case UIGestureRecognizerStateBegan:
                [self willScaleSelectedViews];
                break;

            case UIGestureRecognizerStateChanged:
                [self scaleSelectedViews:gestureRecognizer.scale validation:nil];
                break;

            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateEnded:
                [self didScaleSelectedViews];
                break;

            case UIGestureRecognizerStatePossible:
                break;
        }

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
            BOOL      isInBounds     = MSValueInBounds(adjustedOffset,
                                                       _flags.allowableSourceViewYOffset);
            CGFloat   newOffset      = (isInBounds
                                        ? adjustedOffset
                                        : (adjustedOffset < _flags.allowableSourceViewYOffset.lower
                                           ? _flags.allowableSourceViewYOffset.lower
                                           : _flags.allowableSourceViewYOffset.upper));

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
    MSLogDebug(@"%@ select stacked views to include: (%@)",
               ClassTagSelectorString,
               [[[stackedViews allObjects] valueForKey:@"displayName"]
                componentsJoinedByString:@", "]);

    _flags.menuState = REEditingMenuStateStackedViews;

    MenuController.menuItems = [[stackedViews allObjects]
                                arrayByMappingToBlock:
                                ^UIMenuItem *(REView * obj, NSUInteger idx) {
                                    SEL action = NSSelectorFromString($(@"menuAction%@:",
                                                                        obj.uuid));
                                    return MenuItem(obj.displayName, action);
                                }];

    [MenuController setTargetRect:[self.view.window
                                   convertRect:[UIView unionFrameForViews:[stackedViews allObjects]]
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
        NSMutableSet * touchedSubelementViews = [[gestureRecognizer
                                                  touchedSubviewsInView:_sourceView
                                                  ofKind:_selectableClass] mutableCopy];

        if (touchedSubelementViews.count)
        {
            NSMutableDictionary * viewsPerTouch = [NSMutableDictionary
                                                   dictionaryWithCapacity:touchLocations.count];

            [touchLocations enumerateObjectsUsingBlock:^(NSValue * obj, BOOL *stop) {
                viewsPerTouch[obj] = [_sourceView.subelementViews
                                      filteredArrayUsingPredicateWithBlock:
                                      ^BOOL(REView * rev, NSDictionary *bindings) {
                                          return [rev pointInside:[rev convertPoint:CGPointValue(obj)
                                                                           fromView:_sourceView]
                                                        withEvent:nil];
                                      }];
            }];

            NSSet * stackedLocations = [viewsPerTouch
                                        keysOfEntriesPassingTest:
                                        ^BOOL(id key, NSArray * obj, BOOL *stop) {
                                            return (ValueIsNotNil(obj) && obj.count > 1);
                                        }];

            if (stackedLocations.count)
            {
                NSSet * stackedViews = [NSSet setWithArrays:[viewsPerTouch allValues]];

                [touchedSubelementViews minusSet:stackedViews];
                [self displayStackedViewDialogForViews:stackedViews];
            }

            SuppressPerformSelectorLeakWarning([self performSelector:action
                                                          withObject:touchedSubelementViews];)

    }
        else if (_selectedViews.count) [self deselectAll];

    }
}

@end
