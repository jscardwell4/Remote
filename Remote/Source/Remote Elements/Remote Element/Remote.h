//
// Remote.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

@class ButtonGroup;

@interface Remote : RemoteElement

@property (nonatomic, assign, getter = isTopBarHidden) BOOL topBarHidden;

@property (nonatomic, weak, readonly) RemoteConfigurationDelegate * remoteConfigurationDelegate;

@property (nonatomic, strong, readonly) NSDictionary * panels;

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
