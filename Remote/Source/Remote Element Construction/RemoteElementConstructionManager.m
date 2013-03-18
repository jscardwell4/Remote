//
// RemoteElementConstructionManager.m
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElementConstructionManager.h"
#import "RemoteBuilder.h"
#import "ButtonGroupBuilder.h"
#import "ButtonBuilder.h"
#import "MacroBuilder.h"

// static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int   ddLogLevel = DefaultDDLogLevel;

@interface RemoteElementConstructionManager ()

@property (nonatomic, strong) NSManagedObjectContext * buildContext;

@property (nonatomic, strong) RemoteBuilder * remoteBuilder;

@property (nonatomic, strong) ButtonGroupBuilder * buttonGroupBuilder;

@property (nonatomic, strong) ButtonBuilder * buttonBuilder;

@property (nonatomic, strong) MacroBuilder * macroBuilder;

@end

@implementation RemoteElementConstructionManager

+ (RemoteElementConstructionManager *)sharedManager {
    static dispatch_once_t                             pred          = 0;
    __strong static RemoteElementConstructionManager * _sharedObject = nil;

    dispatch_once(&pred,
                  ^{
        _sharedObject = [self new];
    }

                  );

    return _sharedObject;
}

- (BOOL)buildRemoteControllerInContext:(NSManagedObjectContext *)context {
    DDLogDebug(@"%@", ClassTagSelectorString);
    self.buildContext = context;
    assert(self.buildContext);

    // remove existing and rebuild
    [self.buildContext
     performBlockAndWait:^{
         NSFetchRequest * fetchRequest =
            [[NSFetchRequest alloc] initWithEntityName:@"RERemoteController"];

         NSError * error = nil;
         NSArray * fetchedObjects =
            [self.buildContext
             executeFetchRequest:fetchRequest
                           error:&error];

         if (!error && fetchedObjects && fetchedObjects.count) {
            RERemoteController * rc = (RERemoteController *)fetchedObjects[0];
            [self.buildContext
             deleteObject:rc];
// [self.buildContext save:&error];
            if (!error)
                DDLogDebug(
                    @"%@ removed previous remote controller and associated remotes/toolbars",
                    ClassTagSelectorString);
            else
                DDLogError(@"%@ failed to remove previous remote controller",
                           ClassTagSelectorString);
        }
     }

    ];

// __block BOOL success = NO;
// [self.buildContext performBlockAndWait:^{ success = [self buildController]; }];

// return success;
    return [self buildController];
}

- (BOOL)buildController {
    RERemoteController * controller = [RERemoteController remoteControllerInContext:_buildContext];

    controller.topToolbar =
        [self.buttonGroupBuilder constructRemoteViewControllerTopBarButtonGroup];

    ComponentDevice * avReceiver =
        [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:_buildContext];

    avReceiver.inputPowersOn = YES;
    avReceiver.offCommand    =
        [SendIRCommand sendIRCommandWithIRCode:[avReceiver codeWithName:@"Power"]];

    ComponentDevice * comcastDVR =
        [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:_buildContext];

    comcastDVR.alwaysOn = YES;

    ComponentDevice * samsungTV =
        [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:_buildContext];

    samsungTV.offCommand =
        [SendIRCommand sendIRCommandWithIRCode:[samsungTV codeWithName:@"Power Off"]];
    samsungTV.onCommand =
        [SendIRCommand sendIRCommandWithIRCode:[samsungTV codeWithName:@"Power On"]];

    ComponentDevice * ps3 =
        [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:_buildContext];

    ps3.offCommand = [SendIRCommand sendIRCommandWithIRCode:[ps3 codeWithName:@"Discrete Off"]];
    ps3.onCommand  = [SendIRCommand sendIRCommandWithIRCode:[ps3 codeWithName:@"Discrete On"]];

    if (![self.remoteBuilder constructHomeRemote]) {
                DDLogError(@"%@ failed to construct home remote", ClassTagSelectorString);

        return NO;
    }

    // dvr activity remote
    if (![self.remoteBuilder constructDVRRemote]) {
                DDLogError(@"%@ failed to construct dvr remote", ClassTagSelectorString);

        return NO;
    }

    // ps3 activity remote
    if (![self.remoteBuilder constructPS3Remote]) {
                DDLogError(@"%@ failed to construct ps3 remote", ClassTagSelectorString);

        return NO;
    }

    // sonos activity remote
    if (![self.remoteBuilder constructSonosRemote]) {
                DDLogError(@"%@ failed to construct sonos remote", ClassTagSelectorString);

        return NO;
    }

// return [DataManager saveMainContext];
    return YES;
}  /* buildController */

- (BOOL)rebuildBankObjectPreviews {
// FIXME: This hasn't been working with CGPost errors

// return [[ButtonBuilder sharedButtonBuilder] generateButtonPreviews:YES];
    return NO;
}

- (RemoteBuilder *)remoteBuilder {
    if (!_remoteBuilder) self.remoteBuilder = [RemoteBuilder remoteBuilderWithContext:_buildContext];

    return _remoteBuilder;
}

- (ButtonGroupBuilder *)buttonGroupBuilder {
    if (!_buttonGroupBuilder) self.buttonGroupBuilder = [ButtonGroupBuilder buttonGroupBuilderWithContext:_buildContext];

    return _buttonGroupBuilder;
}

- (ButtonBuilder *)buttonBuilder {
    if (!_buttonBuilder) self.buttonBuilder = [ButtonBuilder buttonBuilderWithContext:_buildContext];

    return _buttonBuilder;
}

- (MacroBuilder *)macroBuilder {
    if (!_macroBuilder) self.macroBuilder = [MacroBuilder macroBuilderWithContext:_buildContext];

    return _macroBuilder;
}

@end
