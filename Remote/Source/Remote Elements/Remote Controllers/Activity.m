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
    Activity * activity = [self createInContext:context];
    activity.name = name;
    return activity;
}

- (void)updateWithData:(NSDictionary *)data {

    [super updateWithData:data];
    
    NSString               * name        = data[@"name"];
    NSDictionary           * remote      = data[@"remote"];
    NSDictionary           * launchMacro = data[@"launchMacro"];
    NSDictionary           * haltMacro   = data[@"haltMacro"];
    NSManagedObjectContext * moc         = self.managedObjectContext;

    if (name)        self.name        = name;
    if (remote)      self.remote      = [Remote importObjectFromData:remote inContext:moc];
    if (launchMacro) self.launchMacro = [MacroCommand importObjectFromData:launchMacro inContext:moc];
    if (haltMacro)   self.haltMacro   = [MacroCommand importObjectFromData:haltMacro inContext:moc];

}

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
    if ([Activity countOfObjectsWithPredicate:NSPredicateMake(@"name EQUALS %@", name)])
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
