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
    if (self.controller) [self.controller registerRemote:remote];
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

@end
