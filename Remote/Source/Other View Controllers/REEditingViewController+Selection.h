//
//  RemoteElementEditingViewController+Selection.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REEditingViewController.h"

typedef NS_ENUM (NSInteger, HighlightStyle) {
    HighlightStyleNone     = 0,
    HighlightStyleSelected = 1,
    HighlightStyleFocus    = 2,
    HighlightStyleMoving   = 3
};

//MSKIT_EXTERN UIColor const * kUnselectedColor;
//MSKIT_EXTERN UIColor const * kSelectedColor;
//MSKIT_EXTERN UIColor const * kFocusColor;
//MSKIT_EXTERN UIColor const * kMovingColor;

@class   REView;

@interface REEditingViewController (Selection)

///@name Selection

@property (nonatomic, readonly) NSUInteger   selectionCount;

- (void)toggleSelectionForViews:(NSSet *)views;
- (void)selectView:(REView *)view;
- (void)selectViews:(NSSet *)views;
- (void)deselectView:(REView *)view;
- (void)deselectViews:(NSSet *)views;
- (void)deselectAll;
- (CGRect)selectedViewsUnionFrameInView:(UIView *)view;
- (CGRect) selectedViewsUnionFrameInSourceView;

@end
