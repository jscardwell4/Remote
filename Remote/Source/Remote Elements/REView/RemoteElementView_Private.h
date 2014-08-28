//
// REView_Private.h
// Remote
//
// Created by Jason Cardwell on 10/13/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView.h"
#import "RemoteElement_Private.h"

MSEXTERN CGSize const REMinimumSize;

@class REViewSubelements, REViewContent, REViewBackdrop, REViewOverlay, RELabelView;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface RemoteElementView () <UIGestureRecognizerDelegate>

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;
- (MSDictionary *)kvoRegistration;

@property (nonatomic, strong)            UIImageView       * backgroundImageView;
@property (nonatomic, weak, readwrite)   RemoteElementView * parentElementView;
@property (nonatomic, strong, readwrite) RemoteElement     * model;

@end


@interface RemoteElementView (Drawing)

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)refreshBorderPath;

@property (nonatomic, strong) UIBezierPath * borderPath;
@property (nonatomic, assign) CGSize         cornerRadii;

@end

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface ButtonGroupView (Drawing)

- (void)drawRoundedPanelInContext:(CGContextRef)ctx inRect:(CGRect)rect;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface ButtonView ()
{
  @private
  struct {
    BOOL longPressActive;
    BOOL commandsActive;
    BOOL highlightActionQueued;
    BOOL initialized;
  } _flags;

  struct {
    BOOL           antialiasIcon;
    BOOL           antialiasText;
    NSTimeInterval minHighlightInterval;
  } _options;

}
@property (nonatomic, strong, readwrite)  NSMutableDictionary          * actionHandlers;
@property (nonatomic, weak,   readwrite)  UITapGestureRecognizer       * tapGesture;
@property (nonatomic, weak,   readwrite)  MSLongPressGestureRecognizer * longPressGesture;
@property (nonatomic, weak,   readwrite)  UILabel                      * labelView;
@property (nonatomic, strong, readwrite)  UIImage                      * icon;
@property (nonatomic, weak,   readwrite)  UIActivityIndicatorView      * activityIndicator;
@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REBatteryStatusButtonView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface BatteryStatusButtonView ()
{
  @private
  CGFloat              _batteryLevel;                 /// current charge level
  UIDeviceBatteryState _batteryState;                 /// i.e. charging, full
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////

/// Generic view that initializes some basic settings
@interface REViewInternal : UIView {
  __weak RemoteElementView * _delegate;
} @end

/// View that holds any subelement views
@interface REViewSubelements : REViewInternal @end

/// View that draws primary content
@interface REViewContent : REViewInternal @end

/// View that draws any background decoration
@interface REViewBackdrop : REViewInternal @end

/// View that draws top level style elements such as gloss and editing indicators
@interface REViewOverlay : REViewInternal

@property (nonatomic, assign) BOOL      showAlignmentIndicators;
@property (nonatomic, assign) BOOL      showContentBoundary;
@property (nonatomic, strong) UIColor * boundaryColor;

@end
