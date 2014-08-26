//
// BatteryStatusButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "ImageView.h"

@implementation BatteryStatusButtonView

- (void)initializeIVARs
{
    [super initializeIVARs];

    if (TARGET_IPHONE_SIMULATOR)
    {
        _batteryLevel = 0.75;
        _batteryState = UIDeviceBatteryStateCharging;
    }
    else
    {
        _batteryLevel = CurrentDevice.batteryLevel;
        _batteryState = CurrentDevice.batteryState;
    }

    [CurrentDevice setBatteryMonitoringEnabled:YES];

    __weak BatteryStatusButtonView * weakself = self;
    [NotificationCenter addObserverForName:UIDeviceBatteryLevelDidChangeNotification
                                    object:CurrentDevice
                                     queue:MainQueue
                                usingBlock:^(NSNotification * note) {
                                    _batteryLevel = [CurrentDevice batteryLevel];
                                    [weakself setNeedsDisplay];
                                }];

    [NotificationCenter addObserverForName:UIDeviceBatteryStateDidChangeNotification
                                    object:CurrentDevice
                                     queue:MainQueue
                                usingBlock:^(NSNotification * note) {
                                    _batteryState = [CurrentDevice batteryState];
                                    [weakself setNeedsDisplay];
                                }];
}

- (void)initializeViewFromModel
{
    [super initializeViewFromModel];

    _frameColor = self.model.icons[UIControlStateNormal].color;
    _plugColor = self.model.icons[UIControlStateSelected].color;
    _lightningColor = self.model.icons[UIControlStateDisabled].color;
    _fillColor = self.model.icons[UIControlStateHighlighted].color;
    _frameIcon = self.model.icons[UIControlStateNormal].colorImage;
    _plugIcon = self.model.icons[UIControlStateSelected].colorImage;
    _lightningIcon = self.model.icons[UIControlStateDisabled].colorImage;
}

- (void)dealloc { [NotificationCenter removeObserver:self]; }

- (CGSize)intrinsicContentSize
{
    UIImage * iconImage = self.model.icon.colorImage;
    return (iconImage ? iconImage.size : REMinimumSize);
}

/**
 * Overrides the `ButtonView` implementation to perform custom drawing of the 'battery' frame,
 * the fill color that indicates battery level, and the icon that indicates battery state.
 */
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    if (_batteryLevel == -1)
    {
        _batteryLevel = CurrentDevice.batteryLevel;
        _batteryState = CurrentDevice.batteryState;
    }

    CGRect   insetRect = CGRectInset(rect, 2.0f, 2.0f);
    CGSize   frameIconSize = _frameIcon.size;
    CGSize   frameSize = (CGSizeContainsSize(insetRect.size, frameIconSize)
                          ? frameIconSize
                          : CGSizeAspectMappedToSize(frameIconSize, insetRect.size, YES));
    CGRect   frameRect = CGRectMake(CGRectGetMidX(insetRect) - frameSize.width / 2.0,
                                    CGRectGetMidY(insetRect) - frameSize.height / 2.0,
                                    frameSize.width,
                                    frameSize.height);

    [_frameIcon drawInRect:frameRect];

    CGFloat   padding     = frameSize.width * 0.06;
    CGSize    paintSize   = CGSizeMake(frameSize.width - 4 * padding,
                                       frameSize.height - 3 * padding);
    CGRect    paintRect   = CGRectMake(frameRect.origin.x + padding,
                                       frameRect.origin.y + 1.5 * padding,
                                       paintSize.width,
                                       paintSize.height);

    paintRect.size.width *= _batteryLevel;

    UIBezierPath * path = [UIBezierPath bezierPathWithRect:paintRect];

    [self.fillColor setFill];
    [path fill];

    if (_batteryState == UIDeviceBatteryStateFull)
    {
        [_plugIcon drawInRect:CGRectInset(frameRect, padding, padding)];

    }
    else if (_batteryState == UIDeviceBatteryStateCharging)
    {
        CGSize lightningIconSize = _lightningIcon.size;
        CGSize   lightningSize = (CGSizeContainsSize(paintSize, lightningIconSize)
                                  ? lightningIconSize
                                  : CGSizeAspectMappedToSize(lightningIconSize, paintSize, YES));
        CGRect   lightningRect = (CGRect){ .size = lightningSize };

        lightningRect.origin.x = CGRectGetMidX(frameRect) - lightningSize.width / 2.0;
        lightningRect.origin.y = CGRectGetMidY(frameRect) - lightningSize.height / 2.0;
        [_lightningIcon drawInRect:lightningRect];
    }
}

@end
