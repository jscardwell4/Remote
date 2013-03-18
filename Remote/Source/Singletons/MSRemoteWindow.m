//
// MSRemoteWindow.m
// Remote
//
// Created by Jason Cardwell on 10/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSRemoteWindow.h"

// #define LOG_WINDOW_EVENTS

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@implementation MSRemoteWindow {
    BOOL              _nextEventWakesScreen;
    CGFloat           _wakeAtBrightness;
    dispatch_time_t   _lastEvent;
}

- (void)sendEvent:(UIEvent *)event {
    if (!_trackLastEvent)
callsuper:
        [super sendEvent:event];
    else {
        if (event.type == UIEventTypeTouches || event.type == UIEventTypeMotion) _lastEvent = dispatch_walltime(DISPATCH_TIME_NOW, 0);

        if (_nextEventWakesScreen) {
            MainScreen.brightness = _wakeAtBrightness;
            _nextEventWakesScreen = NO;
        } else
            goto callsuper;
    }

#ifdef LOG_WINDOW_EVENTS
    DDLogDebug(@"%@ new event:%@", ClassTagSelectorString, ((ddLogLevel & LOG_FLAG_VERBOSE)
                                                            ?[event description]
                                                            :[NSString stringWithFormat:@"%@ timestamp:%f",
                                                              ClassString([event class]), event.timestamp]));
#endif
}

- (dispatch_time_t)lastEvent {
    return (_trackLastEvent ? _lastEvent : dispatch_walltime(DISPATCH_TIME_NOW, 0));
}

- (void)dimScreen {
    _wakeAtBrightness     = MainScreen.brightness;
    MainScreen.brightness = 0.0;
    _nextEventWakesScreen = YES;
}

@end
