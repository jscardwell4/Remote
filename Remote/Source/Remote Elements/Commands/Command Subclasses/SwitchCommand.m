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
#import "RemoteElementImportSupportFunctions.h"

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
    return IntValue(type);
}

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    dictionary[@"uuid"] = NullObject;

    dictionary[@"type"]   = switchCommandTypeJSONValueForSwitchCommand(self);
    dictionary[@"target"] = CollectionSafe(self.target);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

- (void)importTarget:(id)data
{
    if (!isStringKind(data) || StringIsEmpty(data) || (!self.type && !UUIDIsValid(data))) return;

    self.target = data;
}

- (void)importType:(id)data
{
    SwitchCommandType type = switchCommandTypeFromImportKey(data);
    [self setValue:@(type) forKey:@"type"];
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
            Remote * remote = [Remote objectWithUUID:((SwitchCommand *)_command).target context:moc];
            if (remote) _success = [controller switchToRemote:remote];
            else _success = NO;
        }

        else
            _success = NO;

        [super main];
    }
    
    @catch (NSException * exception)
    {
        MSLogError(@"command failed");
    }
}

@end