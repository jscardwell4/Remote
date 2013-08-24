//
//  REView+InternalSubviews.m
//  Remote
//
//  Created by Jason Cardwell on 3/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

@implementation REView (InternalSubviews)

/**
 * Adds the backdrop, content, and overlay views. Subclasses that override should call `super`.
 */
- (void)addInternalSubviews
{
    _backdropView = [REViewBackdrop newForAutolayout];
    [self addSubview:_backdropView];

    _backgroundImageView                 = [UIImageView newForAutolayout];
    _backgroundImageView.contentMode     = UIViewContentModeScaleToFill;
    _backgroundImageView.opaque          = NO;
    _backgroundImageView.backgroundColor = ClearColor;
    [_backdropView addSubview:_backgroundImageView];

    _contentView = [REViewContent newForAutolayout];
    [self addSubview:_contentView];

    _subelementsView = [REViewSubelements newForAutolayout];
    [self addSubview:_subelementsView];

    _overlayView = [REViewOverlay newForAutolayout];
    [self addSubview:_overlayView];
}

- (void)setContentInteractionEnabled:(BOOL)contentInteractionEnabled
{
    _contentView.userInteractionEnabled = contentInteractionEnabled;
}

- (BOOL)contentInteractionEnabled { return _contentView.userInteractionEnabled; }

- (void)setSubelementInteractionEnabled:(BOOL)subelementInteractionEnabled
{
    _subelementsView.userInteractionEnabled = subelementInteractionEnabled;
}

- (BOOL)subelementInteractionEnabled { return _subelementsView.userInteractionEnabled; }

- (void)setContentClipsToBounds:(BOOL)contentClipsToBounds
{
    _contentView.clipsToBounds = contentClipsToBounds;
}

- (BOOL)contentClipsToBounds { return _contentView.clipsToBounds; }

- (void)setOverlayClipsToBounds:(BOOL)overlayClipsToBounds {
    _overlayView.clipsToBounds = overlayClipsToBounds;
}

- (BOOL)overlayClipsToBounds { return _overlayView.clipsToBounds; }

- (void)addViewToContent:(UIView *)view { [_contentView addSubview:view]; }

- (void)addViewToOverlay:(UIView *)view { [_overlayView addSubview:view]; }

- (void)addViewToBackdrop:(UIView *)view { [_backdropView addSubview:view]; }

- (void)addLayerToContent:(CALayer *)layer { [_contentView.layer addSublayer:layer]; }

- (void)addLayerToOverlay:(CALayer *)layer { [_overlayView.layer addSublayer:layer]; }

- (void)addLayerToBackdrop:(CALayer *)layer { [_backdropView.layer addSublayer:layer]; }

@end