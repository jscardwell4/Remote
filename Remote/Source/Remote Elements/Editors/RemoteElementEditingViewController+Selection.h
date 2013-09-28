//
//  RemoteElementEditingViewController+Selection.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController.h"

typedef NS_ENUM (NSInteger, HighlightStyle) {
    HighlightStyleNone     = 0,
    HighlightStyleSelected = 1,
    HighlightStyleFocus    = 2,
    HighlightStyleMoving   = 3
};

//MSEXTERN UIColor const * kUnselectedColor;
//MSEXTERN UIColor const * kSelectedColor;
//MSEXTERN UIColor const * kFocusColor;
//MSEXTERN UIColor const * kMovingColor;

@class   RemoteElementView;

@interface RemoteElementEditingViewController (Selection)

///@name Selection

@property (nonatomic, readonly) NSUInteger   selectionCount;

- (void)toggleSelectionForViews:(NSSet *)views;
- (void)selectView:(RemoteElementView *)view;
- (void)selectViews:(NSSet *)views;
- (void)deselectView:(RemoteElementView *)view;
- (void)deselectViews:(NSSet *)views;
- (void)deselectAll;
- (CGRect)selectedViewsUnionFrameInView:(UIView *)view;
- (CGRect) selectedViewsUnionFrameInSourceView;

@end
