//
//  RemoteElementEditingViewController+Selection.m
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController_Private.h"
#import "REView_Private.h"

//static const int   ddLogLevel = LOG_LEVEL_DEBUG;

static const int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel)

@implementation REEditingViewController (Selection)

- (CGRect)selectedViewsUnionFrameInView:(UIView *)view
{
    return [view convertRect:[self selectedViewsUnionFrameInSourceView] fromView:_sourceView];
}

- (CGRect)selectedViewsUnionFrameInSourceView
{
    CGRect   unionRect = CGRectZero;

    for (REView * view in _selectedViews)
    {
        if (CGRectIsEmpty(unionRect)) unionRect = view.frame;
        else unionRect = CGRectUnion(unionRect, view.frame);
    }

    return unionRect;
}

/**
 * Convenience property that returns `[selectedViews count]`.
 * @return The number of selected views
 */
- (NSUInteger)selectionCount
{
    return [_selectedViews count];
}

/**
 * Adds a subelement of the `sourceView` to the current selection.
 * @param view `REView` to add to the current selection
 */
- (void)selectView:(REView *)view
{
    [self selectViews:[@[view] set]];
}

/**
 * Adds multiple subelement views of the `sourceView` to the current selection.
 * @param views `NSSet` of `REView` objects to add to the current selection.
 */
- (void)selectViews:(NSSet *)views
{
    for (REView * view in [views setByRemovingObjectsFromSet: self.selectedViews])
    {
        view.editingState = REEditingStateSelected;
        [_sourceView bringSubelementViewToFront:view];
    }

    [_selectedViews unionSet:views];
    [self updateState];
}

/**
 * Removes a subelement of the `sourceView` from the current selection.
 * @param view `REView` to remove to the current selection
 */
- (void)deselectView:(REView *)view
{
    [self deselectViews:[@[view] set]];
}

/**
 * Removes multiple subelement views of the `sourceView` to the current selection.
 * @param views `NSSet` of `REView` objects to remove to the current selection.
 */
- (void)deselectViews:(NSSet *)views
{
    for (REView * view in [views setByIntersectingSet: self.selectedViews])
    {
        if (view == _focusView) self.focusView = nil;
        else view.editingState = REEditingStateNotEditing;
    }

    [self.selectedViews minusSet:views];
    [self updateState];
}

/**
 * Empties the current selction.
 */
- (void)deselectAll
{
    self.focusView = nil;
    [self deselectViews:self.selectedViews];
}

/**
 * Removes a subelement view of the `sourceView` from the current selection when selected,
 * adds it the current selection otherwise.
 * @param views `REView` to add/remove from the current selection
 */
- (void)toggleSelectionForViews:(NSSet *)views
{
    NSSet * selectedViews   = [views setByIntersectingSet:self.selectedViews];
    NSSet * unselectedViews = [views setByRemovingObjectsFromSet:self.selectedViews];

    [self selectViews:unselectedViews];
    [self deselectViews:selectedViews];
}

@end
