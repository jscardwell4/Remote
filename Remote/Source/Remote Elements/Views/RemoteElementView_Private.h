//
// RemoteElementView_Private.h
// Remote
//
// Created by Jason Cardwell on 10/13/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"
#import "RemoteElementView.h"
#import "RemoteElement_Private.h"

MSEXTERN CGSize const REMinimumSize;

@class REViewSubelements, REViewContent, REViewBackdrop, REViewOverlay, RELabelView;


#pragma mark Additional/modified properties
////////////////////////////////////////////////////////////////////////////////


@interface RemoteElementView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong)            UIImageView       * backgroundImageView;
@property (nonatomic, weak, readwrite)   RemoteElementView * parentElementView;
@property (nonatomic, strong, readwrite) RemoteElement     * model;
@end


#pragma mark Initializing the view
////////////////////////////////////////////////////////////////////////////////


@interface RemoteElementView (Initialization)

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;
- (MSDictionary *)kvoRegistration;

@end


#pragma mark Drawing directly into the view
////////////////////////////////////////////////////////////////////////////////


@interface RemoteElementView (Drawing)

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)refreshBorderPath;

@property (nonatomic, strong) UIBezierPath * borderPath;
@property (nonatomic, assign) CGSize         cornerRadii;

@end

#pragma mark Adding views and layers as content
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (InternalSubviews)

- (void)addInternalSubviews;

- (void)addViewToContent:(UIView *)view;
- (void)addLayerToContent:(CALayer *)layer;
- (void)addViewToOverlay:(UIView *)view;
- (void)addLayerToOverlay:(CALayer *)layer;
- (void)addViewToBackdrop:(UIView *)view;
- (void)addLayerToBackdrop:(CALayer *)layer;

@property (nonatomic, assign) BOOL contentInteractionEnabled;
@property (nonatomic, assign) BOOL subelementInteractionEnabled;
@property (nonatomic, assign) BOOL contentClipsToBounds;
@property (nonatomic, assign) BOOL overlayClipsToBounds;

@end


#pragma mark Editing callbacks
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (EditingHandles)

- (void)willResizeViews:(NSSet *)views;
- (void)didResizeViews:(NSSet *)views;

- (void)willScaleViews:(NSSet *)views;
- (void)didScaleViews:(NSSet *)views;

- (void)willAlignViews:(NSSet *)views;
- (void)didAlignViews:(NSSet *)views;

- (void)willTranslateViews:(NSSet *)views;
- (void)didTranslateViews:(NSSet *)views;

@end
