//
//  Activity.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Activity.h"
#import "Command.h"
#import "RemoteController.h"
#import "RemoteElement.h"
#import "Remote.h"
#import "RemoteElementImportSupportFunctions.h"

@interface Activity ()

@property (nonatomic, strong, readonly) RemoteController  * controller;

@end

@interface Activity (CoreDataGenerateAccessors)

@property (nonatomic, strong) RemoteController * primitiveController;
@property (nonatomic, strong) Remote           * primitiveRemote;

@end

@implementation Activity

@dynamic controller, launchMacro, haltMacro, remote, name;

+ (instancetype)activityWithName:(NSString *)name
{
    return [self activityWithName:name inContext:[CoreDataManager defaultContext]];
}

+ (instancetype)activityWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    Activity * activity = [self MR_createInContext:context];
    activity.name = name;
    return activity;
}

/*
- (MacroCommand *)importMacroWithData:(NSDictionary *)data
{
    NSString * uuid = data[@"uuid"];
    assert(StringIsNotEmpty(uuid));

    __block MacroCommand * macroCommand = nil;

    [self.managedObjectContext performBlockAndWait:
     ^{
         macroCommand = [MacroCommand commandInContext:self.managedObjectContext];
         [macroCommand setValue:uuid forKey:@"uuid"];

         NSArray * commandsData = data[@"commands"];
         if (commandsData)
         {
             for (NSDictionary * commandData in commandsData)
             {
                 NSString * type = commandData[@"class"];
                 Class commandClass = commandClassForImportKey(type);
                 if (commandClass)
                 {                     
                     Command * command = [commandClass MR_importFromObject:commandData
                                                                 inContext:self.managedObjectContext];
                     [macroCommand addCommandsObject:command];

                 }
             }
         }
     }];
    return macroCommand;
}
*/

/*
- (BOOL)importController:(id)data
{
    assert([data isKindOfClass:[NSDictionary class]]);
    NSDictionary * importData = (NSDictionary *)data;
    
    NSString * uuid = importData[@"controller"][@"uuid"];
    
    [self.managedObjectContext performBlockAndWait:
     ^{
         RemoteController * controller = [RemoteController objectWithUUID:uuid
                                                                    context:self.managedObjectContext];
         if (!controller)
         {
             controller = [RemoteController remoteControllerInContext:self.managedObjectContext];
             [controller setValue:uuid forKey:@"uuid"];
         }

         [controller registerActivity:self];
     }];
    return YES;
}
*/


/*
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
*/

- (BOOL)shouldImportRemote:(id)data {return YES;}
- (BOOL)shouldImportLaunchMacro:(id)data {return YES;}
- (BOOL)shouldImportHaltMacro:(id)data {return YES;}

/*
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
*/

- (void)setController:(RemoteController *)controller
{
    [self willChangeValueForKey:@"controller"];
    self.primitiveController = controller;
    [self didChangeValueForKey:@"controller"];
}

- (void)setRemote:(Remote *)remote
{
    [self willChangeValueForKey:@"remote"];
    self.primitiveRemote = remote;
    [self didChangeValueForKey:@"remote"];
}

- (BOOL)updateName:(NSString *)name
{
    if ([Activity MR_countOfEntitiesWithPredicate:NSPredicateMake(@"name EQUALS %@", name)])
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

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    dictionary[@"name"]        = CollectionSafe(self.name);
    dictionary[@"remote.uuid"] = CollectionSafe(self.remote.uuid);
    dictionary[@"launchMacro"] = CollectionSafe(self.launchMacro.JSONDictionary);
    dictionary[@"haltMacro"]   = CollectionSafe(self.haltMacro.JSONDictionary);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


- (NSDictionary *)deepDescriptionDictionary
{
    Activity * activity = [self faultedObject];
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
