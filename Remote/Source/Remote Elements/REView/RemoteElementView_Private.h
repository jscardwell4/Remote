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


@interface RemoteElementView ()<UIGestureRecognizerDelegate>
{
  @private
  struct {
    REEditingMode  editingMode;
    BOOL           editing;
    BOOL           resizable;
    BOOL           moveable;
    BOOL           shrinkwrap;
    REEditingState editingState;
    CGFloat        appliedScale;
  } _editingFlags;

  struct {
    CGSize cornerRadii;
  } _drawingFlags;

  __weak RemoteElementView * _weakself;
  NSDictionary             * _kvoReceptionists;
  REViewSubelements        * _subelementsView;
  REViewContent            * _contentView;
  REViewBackdrop           * _backdropView;
  REViewOverlay            * _overlayView;
  UIImageView              * _backgroundImageView;
  UIBezierPath             * _borderPath;
}

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;
- (NSDictionary *)kvoRegistration;

@property (nonatomic, strong)            UIImageView       * backgroundImageView;
@property (nonatomic, weak, readwrite)   RemoteElementView * parentElementView;
@property (nonatomic, strong, readwrite) RemoteElement     * model;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView (Drawing)
////////////////////////////////////////////////////////////////////////////////


@interface RemoteElementView (Drawing)

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)refreshBorderPath;

@property (nonatomic, strong) UIBezierPath * borderPath;
@property (nonatomic, assign) CGSize         cornerRadii;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView (InternalSubviews)
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface RemoteView ()
{}
@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface ButtonGroupView ()
{
  @protected
  UILabel * _label;

  @private
  BOOL                       _isPanel;
  NSLayoutConstraint       * _tuckedConstraint;
  NSLayoutConstraint       * _untuckedConstraint;
  MSSwipeGestureRecognizer * _tuckGesture;
  MSSwipeGestureRecognizer * _untuckGesture;
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - RESelectionPanelButtonGroupView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface SelectionPanelButtonGroupView ()
{
  @private
  __weak ButtonView * _selectedButton;    /// Tracks currently selected mode
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REPickerLabelButtonGroupView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface PickerLabelButtonGroupView ()
{

  @private
  struct {
    BOOL       blockPan;
    CGFloat    panLength;
    NSUInteger labelIndex;
    NSUInteger labelCount;
    CGFloat    prevPanAmount;
  } _pickerFlags;

  NSLayoutConstraint     * _labelContainerLeftConstraint;
  UIView                 * _labelContainer;
  UIPanGestureRecognizer * _labelPanGesture;
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonView Class Extension
////////////////////////////////////////////////////////////////////////////////


@interface ButtonView ()
{

  @protected
  NSMutableDictionary          * _actionHandlers;
  UITapGestureRecognizer       * _tapGesture;
  MSLongPressGestureRecognizer * _longPressGesture;
  UILabel                      * _labelView;
  UIImage                      * _icon;
  UIActivityIndicatorView      * _activityIndicator;

  @private
  struct {
    BOOL activityIndicator;
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


#import "RemoteViewController.h"
#import "ConstraintManager.h"
#import "CommandSet.h"
#import "CommandSetCollection.h"
#import "ConnectionManager.h"
#import "RELabelView.h"
#import "LayoutConstraint.h"
