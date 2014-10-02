//
// BatteryStatusButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "ImageView.h"
#import "Button.h"
#import "ControlStateImageSet.h"
#import "ImageView.h"
#import "Remote-Swift.h"

@interface BatteryStatusButtonView ()

@property (nonatomic, strong) ImageView * batteryFrame;
@property (nonatomic, strong) ImageView * batteryPlug;
@property (nonatomic, strong) ImageView * batteryLightning;
@property (nonatomic, strong) ImageView * batteryFill;

@property (nonatomic, assign) CGFloat              batteryLevel;   /// current charge level
@property (nonatomic, assign) UIDeviceBatteryState batteryState;   /// i.e. charging, full

@property (nonatomic, strong) MSNotificationReceptionist * batteryLevelReceptionist;
@property (nonatomic, strong) MSNotificationReceptionist * batteryStateReceptionist;

@end

@implementation BatteryStatusButtonView

- (void)initializeIVARs {
  [super initializeIVARs];

  if (TARGET_IPHONE_SIMULATOR) {
    self.batteryLevel = 0.75;
    self.batteryState = UIDeviceBatteryStateCharging;
  } else {
    self.batteryLevel = CurrentDevice.batteryLevel;
    self.batteryState = CurrentDevice.batteryState;
  }

  [CurrentDevice setBatteryMonitoringEnabled:YES];
}

- (void)registerForChangeNotification {
  [super registerForChangeNotification];

  self.batteryLevelReceptionist =
    [MSNotificationReceptionist receptionistWithObserver:self
                                               forObject:CurrentDevice
                                        notificationName:UIDeviceBatteryLevelDidChangeNotification
                                                   queue:MainQueue
                                                 handler:^(MSNotificationReceptionist * receptionist) {
                                                   BatteryStatusButtonView * view =
                                                     (BatteryStatusButtonView *)receptionist.observer;
                                                   view.batteryLevel = [CurrentDevice batteryLevel];
                                                   [view setNeedsDisplay];
                                                 }];
  self.batteryStateReceptionist =
    [MSNotificationReceptionist receptionistWithObserver:self
                                               forObject:CurrentDevice
                                        notificationName:UIDeviceBatteryStateDidChangeNotification
                                                   queue:MainQueue
                                                 handler:^(MSNotificationReceptionist * receptionist) {
                                                   BatteryStatusButtonView * view =
                                                     (BatteryStatusButtonView *)receptionist.observer;
                                                   view.batteryState = [CurrentDevice batteryState];
                                                   [view setNeedsDisplay];
                                                 }];
}

- (void)initializeViewFromModel {
  [super initializeViewFromModel];

  self.batteryFrame     = self.model.icons[UIControlStateNormal];
  self.batteryPlug      = self.model.icons[UIControlStateSelected];
  self.batteryLightning = self.model.icons[UIControlStateDisabled];
  self.batteryFill      = self.model.icons[UIControlStateHighlighted];
}

- (CGSize)intrinsicContentSize { return self.model.icon ? self.model.icon.image.size : REMinimumSize; }

/// Overrides the `ButtonView` implementation to perform custom drawing of the 'battery' frame,
/// the fill color that indicates battery level, and the icon that indicates battery state.
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {

  if (_batteryLevel == -1) {
    _batteryLevel = CurrentDevice.batteryLevel;
    _batteryState = CurrentDevice.batteryState;
  }

  CGRect insetRect     = CGRectInset(rect, 2.0f, 2.0f);
  CGSize frameIconSize = self.batteryFrame.image.size;
  CGSize frameSize     = (CGSizeContainsSize(insetRect.size, frameIconSize)
                          ? frameIconSize
                          : CGSizeAspectMappedToSize(frameIconSize, insetRect.size, YES));
  CGRect frameRect = CGRectMake(CGRectGetMidX(insetRect) - frameSize.width / 2.0,
                                CGRectGetMidY(insetRect) - frameSize.height / 2.0,
                                frameSize.width,
                                frameSize.height);

  [self.batteryFrame.colorImage drawInRect:frameRect];

  CGFloat padding   = frameSize.width * 0.06;
  CGSize  paintSize = CGSizeMake(frameSize.width - 4 * padding,
                                 frameSize.height - 3 * padding);
  CGRect paintRect = CGRectMake(frameRect.origin.x + padding,
                                frameRect.origin.y + 1.5 * padding,
                                paintSize.width,
                                paintSize.height);

  paintRect.size.width *= _batteryLevel;

  UIBezierPath * path = [UIBezierPath bezierPathWithRect:paintRect];

  [self.batteryFill.color setFill];
  [path fill];

  if (self.batteryState == UIDeviceBatteryStateFull) {
    [self.batteryPlug.colorImage drawInRect:CGRectInset(frameRect, padding, padding)];

  } else if (self.batteryState == UIDeviceBatteryStateCharging) {
    CGSize lightningIconSize = self.batteryLightning.image.size;
    CGSize lightningSize     = (CGSizeContainsSize(paintSize, lightningIconSize)
                                ? lightningIconSize
                                : CGSizeAspectMappedToSize(lightningIconSize, paintSize, YES));
    CGRect lightningRect = (CGRect) {
      .size = lightningSize
    };

    lightningRect.origin.x = CGRectGetMidX(frameRect) - lightningSize.width / 2.0;
    lightningRect.origin.y = CGRectGetMidY(frameRect) - lightningSize.height / 2.0;
    [self.batteryLightning.colorImage drawInRect:lightningRect];
  }
}

@end
