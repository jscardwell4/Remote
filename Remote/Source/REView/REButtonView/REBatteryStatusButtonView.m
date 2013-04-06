//
// REBatteryStatusButtonView.m
// Remote
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "REView_Private.h"

@implementation REBatteryStatusButtonView

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

    __weak REBatteryStatusButtonView * weakself = self;
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

    _frameColor = self.model.icons.iconColors[UIControlStateNormal];
    if (!_frameColor) _frameColor =  WhiteColor;

    _plugColor = self.model.icons.iconColors[UIControlStateSelected];
    if (!_plugColor) _plugColor = LightGrayColor;

    _lightningColor = self.model.icons.iconColors[UIControlStateDisabled];
    if (!_lightningColor) _lightningColor = _plugColor;

    _fillColor = self.model.backgroundColors[UIControlStateNormal];
    if (!_fillColor) _fillColor = LightTextColor;

    _frameIcon = [self.model.icons UIImageForState:UIControlStateNormal];
    if (!_frameIcon)
        _frameIcon = [[BOIconImage fetchImageWithTag:5 context:self.model.managedObjectContext]
                      imageWithColor:_frameColor];

    _plugIcon = [self.model.icons UIImageForState:UIControlStateSelected];
    if (!_plugIcon)
        _plugIcon = [[BOIconImage fetchImageWithTag:4 context:self.model.managedObjectContext]
                     imageWithColor:_plugColor];

    _lightningIcon = [self.model.icons UIImageForState:UIControlStateDisabled];
    if (!_lightningIcon)
        _lightningIcon = [[BOIconImage fetchImageWithTag:6 context:self.model.managedObjectContext]
                          imageWithColor:_lightningColor];
}

- (void)dealloc { [NotificationCenter removeObserver:self]; }

- (CGSize)intrinsicContentSize
{
    UIImage * iconImage = [self.model.icons UIImageForState:UIControlStateNormal];
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

    CGSize   frameSize = CGSizeFitToSize(_frameIcon.size, rect.size);
    CGRect   frameRect = CGRectMake(CGRectGetMidX(rect) - frameSize.width / 2.0,
                                    CGRectGetMidY(rect) - frameSize.height / 2.0,
                                    frameSize.width,
                                    frameSize.height);

    [_frameIcon drawInRect:frameRect];

    CGSize    iconSize    = frameRect.size;
    CGFloat   padding     = iconSize.width * 0.06;
    CGPoint   imageOrigin = frameRect.origin;
    CGRect    paintRect   = CGRectMake(imageOrigin.x + padding,
                                       imageOrigin.y + 1.5 * padding,
                                       iconSize.width - 4 * padding,
                                       iconSize.height - 3 * padding);

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
        CGSize   lightningSize = CGSizeFitToSize(_lightningIcon.size,
                                                 CGRectInset(frameRect, padding, padding).size);
        CGRect   lightningRect = (CGRect){ .size = lightningSize };

        lightningRect.origin.x = CGRectGetMidX(frameRect) - lightningSize.width / 2.0;
        lightningRect.origin.y = CGRectGetMidY(frameRect) - lightningSize.height / 2.0;
        [_lightningIcon drawInRect:lightningRect];
    }
}

@end
