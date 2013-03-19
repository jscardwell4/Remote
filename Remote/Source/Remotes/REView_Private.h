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

@interface REView () <UIGestureRecognizerDelegate>

- (void)attachGestureRecognizers;
- (void)registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (void)initializeIVARs;
- (void)initializeViewFromModel;
- (NSDictionary *)kvoRegistration;
- (void)addInternalSubviews;
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect;
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect;

@property (nonatomic, strong) UIBezierPath * borderPath;
@property (nonatomic, strong) UIImageView  * backgroundImageView;
@property (nonatomic, assign) CGFloat        appliedScale;
@property (nonatomic, assign) CGSize         cornerRadii;

@end
