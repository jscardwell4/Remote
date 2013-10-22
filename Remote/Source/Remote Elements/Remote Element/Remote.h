//
// Remote.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RERemote
////////////////////////////////////////////////////////////////////////////////
@class ButtonGroup;

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
 * Flag that determines whether or not the remote view controller's topbar should be visible when
 * this remote is loaded.
 */
@property (nonatomic, assign, getter = isTopBarHidden) BOOL topBarHidden;

@property (nonatomic, weak, readonly) RemoteConfigurationDelegate * remoteConfigurationDelegate;

@property (nonatomic, strong, readonly) NSDictionary * panels;

/**
 * Retrieve a ButtonGroup contained by this Remote by the ButtonGroup's key.
 *
 * @param subscript Key for the ButtonGroup to retrieve.
 *
 * @return The ButtonGroup requested, or nil if no ButtonGroup with specified key exists.
 */
- (ButtonGroup *)objectForKeyedSubscript:(NSString *)subscript;
- (ButtonGroup *)objectAtIndexedSubscript:(NSUInteger)subscript;
- (void)assignButtonGroup:(ButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment;
- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment;
- (BOOL)registerMode:(RERemoteMode)mode;

@property (nonatomic, readonly) NSArray * modes;

@end

@interface Remote (REConfigurationDelegate)

@property (nonatomic, copy) RERemoteMode currentMode;

- (void)addMode:(RERemoteMode)mode;
- (BOOL)hasMode:(RERemoteMode)mode;

@end
