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

MSKIT_EXTERN CGSize const   RemoteElementMinimumSize;

@interface RemoteElementLabelView : UILabel
@property (nonatomic, assign) CGFloat        baseWidth;
@property (nonatomic, assign) CGFloat        fontScale;
@property (nonatomic, assign) BOOL           preserveLines;
@property (nonatomic, readonly) NSUInteger   lineBreaks;
@end


@interface RemoteElementView () <UIGestureRecognizerDelegate>

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;

- (NSDictionary *)kvoRegistration;
- (void)addInternalSubviews;
- (void)addSubelementViews:(NSSet *)views;
- (void)addSubelementView:(RemoteElementView *)view;
- (void)removeSubelementViews:(NSSet *)views;
- (void)removeSubelementView:(RemoteElementView *)view;

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;

- (void)addViewToContent:(UIView *)view;
- (void)addViewToOverlay:(UIView *)view;
- (void)addViewToBackdrop:(UIView *)view;

@property (nonatomic, strong) UIBezierPath * borderPath;
@property (nonatomic, assign) BOOL           contentInteractionEnabled;
@property (nonatomic, assign) BOOL           contentClipsToBounds;
@property (nonatomic, assign) BOOL           overlayClipsToBounds;
@property (nonatomic, strong) UIImageView  * backgroundImageView;
@property (nonatomic, assign) CGFloat        appliedScale;
@property (nonatomic, assign) CGSize         cornerRadii;


@end
