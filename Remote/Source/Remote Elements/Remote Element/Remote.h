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
@property (nonatomic, strong, readonly) NSDictionary * panels;

- (void)assignButtonGroup:(ButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment;
- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment;

@end
