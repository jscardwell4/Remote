//
//  REActivity.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REActivity.h"
#import "RECommand.h"
#import "RERemoteController.h"
#import "RemoteElement.h"

@interface REActivity ()

@property (nonatomic, strong, readonly) RERemoteController  * controller;
@property (nonatomic, copy, readwrite)  NSString            * name;

@end

@interface REActivity (CoreDataGenerateAccessors)

@property (nonatomic, strong) RERemoteController * primitiveController;
@property (nonatomic, strong) RERemote           * primitiveRemote;

@end

@implementation REActivity

@dynamic controller, launchMacro, haltMacro, remote, name;

+ (instancetype)activityWithName:(NSString *)name
{
    return [self activityWithName:name inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)activityWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    REActivity * activity = [self MR_createInContext:context];
    activity.name = name;
    return activity;
}

- (REMacroCommand *)importMacroWithData:(NSDictionary *)data
{
    NSString * uuid = data[@"uuid"];
    assert(StringIsNotEmpty(uuid));

    __block REMacroCommand * macroCommand = nil;

    [self.managedObjectContext performBlockAndWait:
     ^{
         macroCommand = [REMacroCommand commandInContext:self.managedObjectContext];
         [macroCommand setValue:uuid forKey:@"uuid"];

         NSArray * commandsData = data[@"commands"];
         if (commandsData)
         {
             for (NSDictionary * commandData in commandsData)
             {
                 NSString * type = commandData[@"type"];
                 Class commandClass = classForCommandImportType(type);
                 if (commandClass)
                 {                     
                     RECommand * command = [commandClass MR_importFromObject:commandData
                                                                   inContext:self.managedObjectContext];
                     [macroCommand addCommandsObject:command];

                 }
             }
         }
     }];
    return macroCommand;
}

- (BOOL)importController:(id)data
{
    assert([data isKindOfClass:[NSDictionary class]]);
    NSDictionary * importData = (NSDictionary *)data;
    
    NSString * uuid = importData[@"controller"][@"uuid"];
    
    [self.managedObjectContext performBlockAndWait:
     ^{
         RERemoteController * controller = [RERemoteController objectWithUUID:uuid
                                                                    context:self.managedObjectContext];
         if (!controller)
         {
             controller = [RERemoteController remoteControllerInContext:self.managedObjectContext];
             [controller setValue:uuid forKey:@"uuid"];
         }

         [controller registerActivity:self];
     }];
    return YES;
}


- (BOOL)importHaltMacro:(id)data
{
    assert([data isKindOfClass:[NSDictionary class]]);
    NSDictionary * importData = (NSDictionary *)data;

    if ([importData hasKey:@"haltMacro"])
    {
        NSDictionary * macroData = importData[@"haltMacro"];
        self.haltMacro = [self importMacroWithData:macroData];
    }

    return YES;
}

- (BOOL)importLaunchMacro:(id)data
{
    assert([data isKindOfClass:[NSDictionary class]]);
    NSDictionary * importData = (NSDictionary *)data;
    if ([importData hasKey:@"launchMacro"])
    {
        NSDictionary * macroData = importData[@"launchMacro"];
        self.launchMacro = [self importMacroWithData:macroData];
    }

    return YES;
}

- (void)setController:(RERemoteController *)controller
{
    [self willChangeValueForKey:@"controller"];
    self.primitiveController = controller;
    [self didChangeValueForKey:@"controller"];
    if (controller && self.remote) [controller registerRemote:self.remote];
}

- (void)setRemote:(RERemote *)remote
{
    [self willChangeValueForKey:@"remote"];
    self.primitiveRemote = remote;
    [self didChangeValueForKey:@"remote"];
    if (remote && self.controller) [self.controller registerRemote:remote];
}

- (BOOL)updateName:(NSString *)name
{
    if ([REActivity MR_countOfEntitiesWithPredicate:NSMakePredicate(@"name EQUALS %@", name)])
        return NO;
    else
    {
        self.name = name;
        return YES;
    }
}

- (BOOL)launchActivity
{
    if (!self.controller)
        return NO;

    __block BOOL launchReturned = NO;
    __block BOOL launchSucceeded = NO;

    if (self.launchMacro)
        [self.launchMacro execute:^(BOOL success, NSError * error)
         {
             if (!error && success)
                 launchSucceeded = [self.controller switchToRemote:self.remote];

             launchReturned = YES;
         }];

    else
    {
        launchSucceeded = [self.controller switchToRemote:self.remote];
        launchReturned = YES;
    }
    
    while (!launchReturned);

    return launchSucceeded;
}

- (void)launchActivity:(void (^)(BOOL, NSError *))completion
{
    if (self.controller)
    {
        if (self.launchMacro)
            [self.launchMacro execute:^(BOOL success, NSError * error)
             {
                 if (!error && success)
                 {
                     success = [self.controller switchToRemote:self.remote];
                     if (completion)
                         completion(success, nil);
                 }
                 else if (completion)
                     completion(NO, nil);
             }];

        else
        {
            BOOL success = [self.controller switchToRemote:self.remote];
            if (completion)
                completion(success, nil);
        }
    }

    else
        completion(NO, nil);
}

- (BOOL)haltActivity
{

    __block BOOL haltReturned = NO;
    __block BOOL haltSucceeded = NO;

    if (!self.controller)
        return NO;

    else if (self.haltMacro)
    {
        [self.haltMacro execute:^(BOOL success, NSError * error)
         {
             if (!error && success)
                 haltSucceeded = [self.controller switchToRemote:self.controller.homeRemote];

             haltReturned = YES;
         }];
    }

    else
    {
        haltSucceeded = [self.controller switchToRemote:self.controller.homeRemote];
        haltReturned = YES;
    }

    while (!haltReturned);

    return haltSucceeded;
}

- (void)haltActivity:(void (^)(BOOL, NSError *))completion
{
    if (self.controller)
    {
        if (self.haltMacro)
            [self.haltMacro execute:^(BOOL success, NSError * error)
             {
                 if (!error && success)
                 {
                     success = [self.controller switchToRemote:self.controller.homeRemote];
                     if (completion)
                         completion(success, nil);
                 }
                 else if (completion)
                     completion(NO, nil);
             }];

        else
        {
            BOOL success = [self.controller switchToRemote:self.controller.homeRemote];
            if (completion)
                completion(success, nil);
        }
    }

    else
        completion(NO, nil);
}

- (BOOL)launchOrHault
{
    if (!self.controller)
        return NO;

    else if (self.controller.currentActivity == self)
        return [self haltActivity];
    else
        return [self launchActivity];
}

- (void)launchOrHault:(void (^)(BOOL success, NSError * error))completion
{
    if (self.controller.currentActivity == self)
        [self haltActivity:completion];

    else if (self.controller)
        [self launchActivity:completion];

    else if (completion)
        completion(NO, nil);
}

- (NSDictionary *)deepDescriptionDictionary
{
    REActivity * activity = [self faultedObject];
    assert(activity);
    
    NSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"]        = (activity.name ? : @"nil");
    dd[@"controller"]  = (activity.controller.uuid ?: @"nil");
    dd[@"remote"]      = namedModelObjectDescription(activity.remote);
    dd[@"launchMacro"] = namedModelObjectDescription(activity.launchMacro);
    dd[@"haltMacro"]   = namedModelObjectDescription(activity.haltMacro);

    return dd;
}

@end
