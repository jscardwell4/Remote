//
//  REView+Editing.m
//  Remote
//
//  Created by Jason Cardwell on 3/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

@implementation REView (Editing)

- (void)setEditing:(BOOL)editing { _editingFlags.editing = editing; }

- (void)setEditingMode:(REEditingMode)editingMode { _editingFlags.editingMode = editingMode; }

- (void)setResizable:(BOOL)resizable { _editingFlags.resizable = resizable; }

- (void)setMoveable:(BOOL)moveable { _editingFlags.moveable = moveable; }

- (void)setShrinkwrap:(BOOL)shrinkwrap { _editingFlags.shrinkwrap = shrinkwrap; }

- (void)setAppliedScale:(CGFloat)appliedScale { _editingFlags.appliedScale = appliedScale; }

- (BOOL)isEditing { return (self.type & _editingFlags.editingMode); }

- (BOOL)shouldShrinkwrap { return _editingFlags.shrinkwrap; }

- (BOOL)isMoveable { return _editingFlags.moveable; }

- (BOOL)isResizable { return _editingFlags.resizable; }

- (REEditingState)editingState { return _editingFlags.editingState; }

- (REEditingMode)editingMode { return _editingFlags.editingMode; }

- (CGFloat)appliedScale { return _editingFlags.appliedScale; }

- (void)scale:(CGFloat)scale {
    CGSize currentSize = self.bounds.size;
    CGSize newSize = CGSizeApplyScale(currentSize, scale / _editingFlags.appliedScale);
    _editingFlags.appliedScale = scale;
    [self.model.constraintManager resizeElement:self.model
                                   fromSize:currentSize
                                     toSize:newSize
                                    metrics:viewFramesByIdentifier(self)];
    [self setNeedsUpdateConstraints];
}

/**
 * Sets border color according to current editing style.
 */
- (void)setEditingState:(REEditingState)editingState
{
    _editingFlags.editingState = editingState;

    _overlayView.showAlignmentIndicators = (_editingFlags.editingState == REEditingStateMoving ? YES : NO);
    _overlayView.showContentBoundary     = (_editingFlags.editingState ? YES : NO);

    switch (editingState)
    {
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

    assert([self.subviews objectAtIndex:self.subviews.count - 1] == _overlayView);
    [_overlayView.layer setNeedsDisplay];
}

- (void)updateSubelementOrderFromView
{
    self.model.subelements = [NSOrderedSet orderedSetWithArray:
                          [self.subelementViews valueForKey:@"remoteElement"]];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation
{
    [self.model.constraintManager
     translateSubelements:[subelementViews valueForKeyPath:@"model"]
     translation:translation
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [self.model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

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

        [self.model.constraintManager
         resizeElement:subelementView.model
         fromSize:subelementView.bounds.size
         toSize:newSize
         metrics:viewFramesByIdentifier(self)];
    }

    if (self.shrinkwrap)
        [self.model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(REView *)siblingView
               attribute:(NSLayoutAttribute)attribute
{
    [self.model.constraintManager
     alignSubelements:[subelementViews valueForKeyPath:@"model"]
     toSibling:siblingView.model
     attribute:attribute
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [self.model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

    [subelementViews makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [self setNeedsUpdateConstraints];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(REView *)siblingView
                attribute:(NSLayoutAttribute)attribute
{
    [self.model.constraintManager
     resizeSubelements:[subelementViews valueForKeyPath:@"model"]
     toSibling:siblingView.model
     attribute:attribute
     metrics:viewFramesByIdentifier(self)];

    if (self.shrinkwrap)
        [self.model.constraintManager shrinkWrapSubelements:viewFramesByIdentifier(self)];

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
