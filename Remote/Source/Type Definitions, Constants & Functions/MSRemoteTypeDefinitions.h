//
// RemoteTypeDefinitions.h
// Remote
//
// Created by Jason Cardwell on 6/19/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

#pragma mark - Debugging

typedef struct DebugFlags {
    BOOL         logKVO;
    BOOL         logGeometry;
    BOOL         logTouches;
    BOOL         logGestures;
    BOOL         logNotifications;
    NSUInteger   overrideBackgroundColors;
} DebugFlags;
