//
// REView_Private.h
// Remote
//
// Created by Jason Cardwell on 10/13/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REView.h"
#import "RemoteElement_Private.h"

MSKIT_EXTERN CGSize const   REMinimumSize;

@class REViewSubelements, REViewContent, REViewBackdrop, REViewOverlay, RELabelView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Remote View
////////////////////////////////////////////////////////////////////////////////

@interface REView () <UIGestureRecognizerDelegate> {
    @private
    struct {
        REEditingMode   editingMode;
        BOOL            editing;
        BOOL            resizable;
        BOOL            moveable;
        BOOL            shrinkwrap;
        REEditingState  editingState;
        CGFloat         appliedScale;
    } _editingFlags;

    struct {
        CGSize cornerRadii;
    } _drawingFlags;
    
    __weak REView     * _weakself;
    NSDictionary      * _kvoReceptionists;
    REViewSubelements * _subelementsView;
    REViewContent     * _contentView;
    REViewBackdrop    * _backdropView;
    REViewOverlay     * _overlayView;
    UIImageView       * _backgroundImageView;
    UIBezierPath      * _borderPath;
}

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;
- (NSDictionary *)kvoRegistration;

@property (nonatomic, strong)            UIImageView   * backgroundImageView;
@property (nonatomic, weak, readwrite)   REView        * parentElementView;
@property (nonatomic, strong, readwrite) RemoteElement * model;

@end

@interface REView (Drawing)

- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)refreshBorderPath;

@property (nonatomic, strong) UIBezierPath  * borderPath;
@property (nonatomic, assign) CGSize          cornerRadii;

@end

@interface REView (InternalSubviews)

- (void)addInternalSubviews;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Adding arbitrary views and layers
////////////////////////////////////////////////////////////////////////////////

- (void)addViewToContent:(UIView *)view;
- (void)addLayerToContent:(CALayer *)layer;
- (void)addViewToOverlay:(UIView *)view;
- (void)addLayerToOverlay:(CALayer *)layer;
- (void)addViewToBackdrop:(UIView *)view;
- (void)addLayerToBackdrop:(CALayer *)layer;

@property (nonatomic, assign) BOOL   contentInteractionEnabled;
@property (nonatomic, assign) BOOL   subelementInteractionEnabled;
@property (nonatomic, assign) BOOL   contentClipsToBounds;
@property (nonatomic, assign) BOOL   overlayClipsToBounds;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote View
////////////////////////////////////////////////////////////////////////////////

@interface RERemoteView () {
    @protected
    NSMutableSet * _configurations;
    NSString * _currentConfiguration;
}
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group View
////////////////////////////////////////////////////////////////////////////////

@interface REButtonGroupView () {
    @protected
    UILabel * _label;

    @private
    BOOL 						 						 		_isPanel;
    NSLayoutConstraint       * _tuckedConstraint;
    NSLayoutConstraint       * _untuckedConstraint;
    MSSwipeGestureRecognizer * _tuckGesture;
    MSSwipeGestureRecognizer * _untuckGesture;
}

@end

@interface RESelectionPanelButtonGroupView () {
    @private	
    __weak REButtonView * _selectedButton;  /// Tracks currently selected configuration
}

@end

@interface REPickerLabelButtonGroupView () {

	@private
    struct {
        BOOL         blockPan;
        CGFloat      panLength;
        NSUInteger   labelIndex;
        NSUInteger   labelCount;
        CGFloat      prevPanAmount;
    } _pickerFlags;

    NSLayoutConstraint     * _labelContainerLeftConstraint;
    UIView                 * _labelContainer;
    UIPanGestureRecognizer * _labelPanGesture;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button View
////////////////////////////////////////////////////////////////////////////////

@interface REButtonView () {
    
    @protected
    NSMutableDictionary          * _actionHandlers;
    UITapGestureRecognizer       * _tapGesture;
    MSLongPressGestureRecognizer * _longPressGesture;
    RELabelView                  * _labelView;
    UIImage                      * _icon;
    UIActivityIndicatorView      * _activityIndicator;

    @private
    struct {
        BOOL             activityIndicator;
        UIControlState   state;
        BOOL             longPressActive;
        BOOL             commandsActive;
        BOOL             highlightActionQueued;
        BOOL             initialized;
    } _flags;
    
    struct {
        BOOL             antialiasIcon;
        BOOL             antialiasText;
        NSTimeInterval   minHighlightInterval;
    } _options;

}
@end

@interface REBatteryStatusButtonView () {
    @private
    CGFloat                            _batteryLevel; /// current charge level
    UIDeviceBatteryState               _batteryState; /// i.e. charging, full
}

@end

@interface REConnectionStatusButtonView () {
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Subview Class Interfaces
////////////////////////////////////////////////////////////////////////////////

/// Generic view that initializes some basic settings
@interface REViewInternal : UIView { __weak REView * _delegate; } @end

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


#import "RERemoteViewController.h"
#import "Painter.h"
#import "RECommandContainer.h"
#import "ConnectionManager.h"
#import "RELabelView.h"
