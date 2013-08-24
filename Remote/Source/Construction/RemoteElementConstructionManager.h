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
@class RERemote;

/**
 * `RemoteBuilder` is a singleton class that, when provided with an `NSManagedObjectContext`, can
 * fetch or create a <RemoteController> object and construct a multitude of elements that together
 * form a fully realized remote control interface. Currently this class is used for testing
 * purposes.
 */
@interface RERemoteBuilder : NSObject @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////
@class   REMacroCommand;

@interface REMacroBuilder : NSObject @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
@class   REButtonGroup, REPickerLabelButtonGroup;

@interface REButtonGroupBuilder : NSObject

+ (REButtonGroup *)dPadInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)numberPadInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)transportInContext:(NSManagedObjectContext *)moc;
+ (REPickerLabelButtonGroup *)rockerInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)oneByThreeInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)verticalPanelInContext:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Sets
////////////////////////////////////////////////////////////////////////////////

@interface RECommandSetBuilder : NSObject @end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////

@interface REButtonBuilder : NSObject @end
