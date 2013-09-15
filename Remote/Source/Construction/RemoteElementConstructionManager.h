//
// RemoteElementConstructionManager.h
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Construction Manager
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementConstructionManager : NSObject

+ (void)buildController;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////
@class Remote;

/**
 * `RemoteBuilder` is a singleton class that, when provided with an `NSManagedObjectContext`, can
 * fetch or create a <RemoteController> object and construct a multitude of elements that together
 * form a fully realized remote control interface. Currently this class is used for testing
 * purposes.
 */
@interface RemoteBuilder : NSObject @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////
@class   MacroCommand;

@interface MacroBuilder : NSObject @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
@class   ButtonGroup, PickerLabelButtonGroup;

@interface ButtonGroupBuilder : NSObject

+ (ButtonGroup *)dPadInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)numberPadInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)transportInContext:(NSManagedObjectContext *)moc;
+ (PickerLabelButtonGroup *)rockerInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)oneByThreeInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)verticalPanelInContext:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Sets
////////////////////////////////////////////////////////////////////////////////

@interface CommandSetBuilder : NSObject @end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////

@interface ButtonBuilder : NSObject @end
