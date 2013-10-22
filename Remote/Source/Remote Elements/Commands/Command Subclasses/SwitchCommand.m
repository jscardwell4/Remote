//
//  SwitchCommand.m
//  Remote
//
//  Created by Jason Cardwell on 3/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "RemoteController.h"
#import "Remote.h"
#import "RemoteElementExportSupportFunctions.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface SwitchCommandOperation : CommandOperation @end

@implementation SwitchCommand

@dynamic target;

- (CommandOperation *)operation
{
    return [SwitchCommandOperation operationForCommand:self];
}

- (SwitchCommandType)type
{
    [self willAccessValueForKey:@"type"];
    NSNumber * type = [self primitiveValueForKey:@"type"];
    [self didAccessValueForKey:@"type"];
    return INTValue(type);
}

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    dictionary[@"type"]   = switchCommandTypeJSONValueForSwitchCommand(self);
    dictionary[@"target"] = CollectionSafeValue(self.target);

    [dictionary removeKeysWithNullObjectValues];

    return dictionary;
}

@end

@implementation SwitchCommandOperation

- (void)main
{
    @try
    {
        NSManagedObjectContext * moc = _command.managedObjectContext;
        RemoteController * controller = [RemoteController remoteControllerInContext:moc];
        if (((SwitchCommand *)_command).type == SwitchModeCommand)
        {
            Remote * remote = controller.currentRemote;
            NSString * mode = ((SwitchCommand *)_command).target;
            remote.currentMode = mode;
            _success = [remote.currentMode isEqualToString:mode];
        }

        else if (((SwitchCommand *)_command).type == SwitchRemoteCommand)
        {
            NSString * uriString = ((SwitchCommand *)_command).target;
            NSURL * uri = [NSURL URLWithString:uriString];
            Remote * remote = (Remote *)[moc objectForURI:uri];
            if (remote) _success = [controller switchToRemote:remote];
            else _success = NO;
        }

        else
            _success = NO;

        [super main];
    }
    
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"seriously, wtf?");
    }
}

@end