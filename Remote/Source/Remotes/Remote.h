//
// Remote.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

@class   ButtonGroup;

typedef NS_ENUM (uint64_t, RemoteType) {
    RemoteTypeDefault  = RemoteElementRemoteType,
    RemoteTypeReserved = 0xFF8
};
typedef NS_OPTIONS (uint64_t, RemoteStyle) {
    RemoteStyleDefault  = RemoteElementNoStyle,
    RemoteStyleReserved = 0xFFFF000000000000
};
typedef NS_ENUM (uint64_t, RemoteShape) {
    RemoteShapeDefault  = RemoteElementShapeUndefined,
    RemoteShapeReserved = 0xFFFFFF000000
};
typedef NS_OPTIONS (uint64_t, RemoteOptions) {
    RemoteOptionsDefault           = RemoteElementNoOptions,
    RemoteOptionTopBarHiddenOnLoad = 0x100000000,
    RemoteOptionReserved           = 0xFFFE00000000,
    RemoteOptionsMask              = RemoteElementOptionsMask
};

/**
 * `Remote` is a subclass of `NSManagedObject` that models a home theater
 * remote control. It maintains a collection of <ButtonGroup> objects to implement
 * the actual execution of commands (via their collection of <Button> objects).
 * A `Remote` serves as a model for display by a <RemoteView>. Each `Remote` models
 * a single screen. Dynamically switching among `Remote` objects is handled by a
 * <RemoteController> which maintains a collection of `Remotes`.
 */
@interface Remote : RemoteElement

/**
 * Creates a new `Remote` object in the given context.
 * @param context `NSManagedObjectContext` with which to create the remote.
 * @return The newly created Remote object.
 */
// + (Remote *)remoteInContext:(NSManagedObjectContext *)context;

/**
 * Flag that determines whether or not the remote view controller's topbar should be visible when
 * this remote is loaded.
 */
@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL   topBarHiddenOnLoad;

/**
 * Retrieve a ButtonGroup contained by this Remote by the ButtonGroup's key.
 * @param key Key for the ButtonGroup to retrieve.
 * @return The ButtonGroup requested, or nil if no ButtonGroup with specified key exists.
 */
- (ButtonGroup *)buttonGroupWithKey:(NSString *)key;
- (ButtonGroup *)objectForKeyedSubscript:(NSString *)subscript;

@end
