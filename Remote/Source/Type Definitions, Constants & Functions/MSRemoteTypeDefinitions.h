//
// RemoteTypeDefinitions.h
// Remote
//
// Created by Jason Cardwell on 6/19/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#pragma mark - Debugging

typedef struct DebugFlags {
    BOOL         logKVO;
    BOOL         logGeometry;
    BOOL         logTouches;
    BOOL         logGestures;
    BOOL         logNotifications;
    NSUInteger   overrideBackgroundColors;
} DebugFlags;

typedef NS_ENUM (NSInteger, PainterShape) {
    PainterShapeUndefined        = 0,
    PainterShapeRoundedRectangle = 1,
    PainterShapeOval             = 2,
    PainterShapeRectangle        = 3,
    PainterShapeTriangle         = 4,
    PainterShapeDiamond          = 5
};
