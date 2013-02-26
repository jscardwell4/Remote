//
// RemoteElementView_Private.h
// iPhonto
//
// Created by Jason Cardwell on 10/13/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElementView.h"
#import "RemoteElement_Private.h"
#import "RemoteElementViewConstraintFunctions.h"

#define SelectorTagString           \
    (ValueIsNil(self.remoteElement) \
     ? ClassTagSelectorString       \
     : ClassTagSelectorStringForInstance(self.displayName))

MSKIT_EXTERN CGSize const   RemoteElementMinimumSize;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementViewInternalSubview : UIView
@property (nonatomic, weak, readonly) RemoteElementView * remoteElementView;
- (id)initWithRemoteElementView:(RemoteElementView *)remoteElementView;
@end

/*******************************************************************************
*  View that holds any subelement views and draws primary content
*******************************************************************************/
@interface RemoteElementContentView : RemoteElementViewInternalSubview @end

/*******************************************************************************
*  View that draws any background decoration
*******************************************************************************/
@interface RemoteElementBackdropView : RemoteElementViewInternalSubview @end

/*******************************************************************************
*  View that draws top level style elements such as gloss and editing indicators
*******************************************************************************/
@interface RemoteElementOverlayView : RemoteElementViewInternalSubview
@property (nonatomic, assign) BOOL      showAlignmentIndicators;
@property (nonatomic, assign) BOOL      showContentBoundary;
@property (nonatomic, strong) UIColor * boundaryColor;
@end

@interface RemoteElementLabelView : UILabel
@property (nonatomic, assign) CGFloat        baseWidth;
@property (nonatomic, assign) CGFloat        fontScale;
@property (nonatomic, assign) BOOL           preserveLines;
@property (nonatomic, readonly) NSUInteger   lineBreaks;
@end

@class   RemoteElementViewConstraintManager;

@interface RemoteElementView () <UIGestureRecognizerDelegate> {
    @protected
        struct {
        CGSize   cornerRadii;
    }
    _options;

    struct {
        BOOL   needsUpdateChildConstraints;
    }
    _flags;
}

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;

- (NSArray *)kvoRegistration;
- (void)     addInternalSubviews;
- (void)     addSubelementViews:(NSSet *)views;
- (void)addSubelementView:(RemoteElementView *)view;
- (void)removeSubelementViews:(NSSet *)views;
- (void)removeSubelementView:(RemoteElementView *)view;

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;

@property (nonatomic, strong) UIBezierPath                       * borderPath;
@property (nonatomic, strong) RemoteElementContentView           * contentView;
@property (nonatomic, strong) RemoteElementBackdropView          * backdropView;
@property (nonatomic, strong) RemoteElementOverlayView           * overlayView;
@property (nonatomic, strong) UIImageView                        * backgroundImageView;
@property (nonatomic, strong) RemoteElementViewConstraintManager * constraintManager;
@end
