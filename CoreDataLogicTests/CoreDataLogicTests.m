//
//  CoreDataLogicTests.m
//  CoreDataLogicTests
//
//  Created by Jason Cardwell on 4/16/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "CoreDataLogicTests.h"
#import <CoreData/CoreData.h>
#import <Lumberjack/Lumberjack.h>
#import <MagicalRecord/MagicalRecord.h>
#import <MSKit/MSKit.h>
#import "CoreDataManager.h"
#import "RemoteElement.h"
#import "RERemoteController.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

static NSString * remoteUUID_      = nil;
static NSString * buttonGroupUUID_ = nil;
static NSString * buttonUUID_      = nil;

@implementation CoreDataLogicTests

- (void)remoteCreationAndSaveWithContext:(NSManagedObjectContext *)context
{
    RERemote * remote = [RERemote remoteElementInContext:context];
    STAssertNotNil(remote, @"remote should not be nil");
    remote.displayName = @"Test Remote";
    STAssertNotNil(remote.configurationDelegate,
                   @"remote should have a configuration delegate created automatically");
    STAssertNotNil(remote.layoutConfiguration,
                   @"remote should have a layout configuration created automatically");
    STAssertNotNil(remote.constraintManager,
                   @"remote should have a constraint manager created automatically");
    STAssertNil(remote.parentElement, @"remote should not have a parent element");
    STAssertNil(remote.controller, @"remote should not have a controller until registered with one");
    MSLogInfoTag(@"\ntest remote:\n%@\nsaving context via local reference to main context...",
                 [remote deepDescription]);
    remoteUUID_ = remote.uuid;
}

- (void)buttonGroupCreationAndSaveWithContext:(NSManagedObjectContext *)context
{
    RERemote * remote = [RERemote objectWithUUID:remoteUUID_ inContext:context];
    STAssertNotNil(remote, @"unable to fetch the remote created in the previous test");
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:context];
    STAssertNotNil(buttonGroup, @"buttonGroup should not be nil");
    buttonGroup.displayName = @"Test Button Group";
    STAssertNotNil(buttonGroup.configurationDelegate,
                   @"buttonGroup should have a configuration delegate created automatically");
    STAssertNotNil(buttonGroup.layoutConfiguration,
                   @"buttonGroup should have a layout configuration created automatically");
    STAssertNotNil(buttonGroup.constraintManager,
                   @"buttonGroup should have a constraint manager created automatically");
    [remote addSubelementsObject:buttonGroup];
    STAssertTrue([remote.subelements containsObject:buttonGroup],
                 @"buttonGroup should have been added to remote's subelements");
    STAssertTrue(buttonGroup.parentElement == remote,
                 @"buttonGroup's parent element should be remote");
    STAssertNil(buttonGroup.controller,
                @"buttonGroup should not have a controller because remote shouldn't have one");
    MSLogInfoTag(@"\ntest button group:\n%@\nsaving context via local reference to main context...",
                 [buttonGroup deepDescription]);
    buttonGroupUUID_ = buttonGroup.uuid;
}

- (void)buttonCreationAndSaveWithContext:(NSManagedObjectContext *)context
{
    REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID_
                                                      inContext:context];
    STAssertNotNil(buttonGroup, @"unable to fetch the buttonGroup created in the previous test");
    REButton * button = [REButton remoteElementInContext:context];
    STAssertNotNil(button, @"button should not be nil");
    button.displayName = @"Test Button";
    STAssertNotNil(button.configurationDelegate,
                   @"button should have a configuration delegate created automatically");
    STAssertNotNil(button.layoutConfiguration,
                   @"button should have a layout configuration created automatically");
    STAssertNotNil(button.constraintManager,
                   @"button should have a constraint manager created automatically");
    [buttonGroup addSubelementsObject:button];
    STAssertTrue([buttonGroup.subelements containsObject:button],
                 @"button should have been added to buttonGroup's subelements");
    STAssertTrue(button.parentElement == buttonGroup,
                 @"button's parent element should be buttonGroup");
    STAssertNil(button.controller,
                @"button should not have a controller because buttonGroup shouldn't have one");
    MSLogInfoTag(@"\ntest button:\n%@\nsaving context via local reference to main context...",
                 [button deepDescription]);
    buttonUUID_ = button.uuid;
}

- (void)remoteControllerCreationAndSaveWithContext:(NSManagedObjectContext *)context
{
    RERemoteController * controller = [RERemoteController remoteControllerInContext:context];
    STAssertNotNil(controller, @"controller should have been created");
    STAssertTrue((!controller.remotes || controller.remotes.count == 0),
                 @"controller should not have any remotes yet");
    STAssertNil(controller.homeRemote, @"controller should not have a 'homeRemote' yet");
    STAssertNil(controller.currentRemote, @"controller should not have a 'currentRemote' yet");

    RERemote * remote = [RERemote objectWithUUID:remoteUUID_ inContext:context];
    STAssertNotNil(remote, @"unable to fetch the remote created in the previous test");
    [controller registerHomeRemote:remote];
    STAssertEqualObjects(remote, controller.homeRemote,
                         @"remote should have been set as the controller's `homeRemote`");
    STAssertEquals(controller.remotes.count, (NSUInteger)1, @"controller should have one remote in `remotes`");
    STAssertNotNil(controller.currentRemote,
                   @"controller should use `homeRemote` for `currentRemote` if not set");
    MSLogInfoTag(@"\ncontroller after registering remote:\n%@\n\n"
                 "remote after being registered with controller:\n%@",
                 [controller deepDescription], [remote deepDescription]);
}


/**
 * Create and save an `RERemoteElement` object.
 */

- (void)testRemoteCreationAndSave
{
    assert(NO);
    [self.defaultContext performBlockAndWait:
     ^{
         [self remoteCreationAndSaveWithContext:self.defaultContext];
         NSError * error = nil;
         [self.defaultContext save:&error];
         if (error) [MagicalRecord handleErrors:error];
         STAssertNil(error, @"save must have failed when it should not have");
     }];
}

/**
 * Create and save an `REButtonGroup` object.
 */

- (void)testButtonGroupCreationAndSave
{
    assert(NO);
    [self.defaultContext performBlockAndWait:
     ^{
         [self buttonGroupCreationAndSaveWithContext:self.defaultContext];
         NSError * error = nil;
         [self.defaultContext save:&error];
         if (error) [MagicalRecord handleErrors:error];
         STAssertNil(error, @"save must have failed when it should not have");
     }];

}

/**
 * Create and save an `REButton` object.
 */

- (void)testButtonCreationAndSave
{
    assert(NO);
    [self.defaultContext performBlockAndWait:
     ^{
         [self buttonCreationAndSaveWithContext:self.defaultContext];
         NSError * error = nil;
         [self.defaultContext save:&error];
         if (error) [MagicalRecord handleErrors:error];
         STAssertNil(error, @"save must have failed when it should not have");
     }];
}

/**
 * Create an `RERemoteController` object, retrieve previously created `RERemote` and register with
 * controller as the home remote.
 */

- (void)testRemoteControllerCreationAndSave
{
    assert(NO);
    [self.defaultContext performBlockAndWait:
     ^{
         [self remoteControllerCreationAndSaveWithContext:self.defaultContext];
         NSError * error = nil;
         [self.defaultContext save:&error];
         if (error) [MagicalRecord handleErrors:error];
         STAssertNil(error, @"save must have failed when it should not have");
     }];
}

/**
 * Test whether `rootSavingContext` observed changes to `self.defaultContext`
 */
- (void)testRootSavingContextMergedChanges
{
    assert(NO);
    [self.rootSavingContext performBlockAndWait:
     ^{
         RERemoteController * controller = [RERemoteController
                                            remoteControllerInContext:self.rootSavingContext];
         STAssertNotNil(controller, @"we should be able to fetch the previously created controller");
         STAssertNotNil(controller.homeRemote, @"`homeRemote` should still be set on the controller");
         MSLogInfoTag(@"controller fetched into root saving context:\n%@", controller);

         RERemote * remote = [RERemote objectWithUUID:remoteUUID_ inContext:self.rootSavingContext];
         STAssertNotNil(remote, @"we should be able to fetch the previously created remote");
         STAssertTrue([controller.remotes containsObject:remote],
                      @"controller's set of remotes should include remote");
         MSLogInfoTag(@"remote fetched into root saving context:\n%@", remote);

         REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID_
                                                           inContext:self.rootSavingContext];
         STAssertNotNil(buttonGroup, @"we should be able to fetch the previously created button group");
         STAssertTrue([remote.subelements containsObject:buttonGroup],
                      @"remote's set of subelements should include button group");
         MSLogInfoTag(@"button group fetched into root saving context:\n%@", buttonGroup);

         REButton * button = [REButton objectWithUUID:buttonUUID_ inContext:self.rootSavingContext];
         STAssertNotNil(button, @"we should be able to fetch the previously created button");
         STAssertTrue([buttonGroup.subelements containsObject:button],
                      @"button group's set of subelements should include button");
         MSLogInfoTag(@"button fetched into root saving context:\n%@", button);

         NSError * error = nil;
         [self.rootSavingContext save:&error];
         if (error) [MagicalRecord handleErrors:error];
         STAssertNil(error, @"saving root saving context created an error when it shouldn't have");
     }];
}


/**
 * Delete the previously created `RERemoteController`, which should cascade.
 */

- (void)testDeleteControllerAndSave
{
    assert(NO);
    [self.defaultContext performBlockAndWait:
     ^{
         RERemoteController * controller = [RERemoteController
                                            remoteControllerInContext:self.defaultContext];
         STAssertNotNil(controller, @"we should be able to fetch the previously created controller");
         STAssertNotNil(controller.homeRemote, @"`homeRemote` should still be set on the controller");

         RERemote * remote = [RERemote objectWithUUID:remoteUUID_ inContext:self.defaultContext];
         STAssertNotNil(remote, @"we should be able to fetch the previously created remote");
         STAssertTrue([controller.remotes containsObject:remote],
                      @"controller's set of remotes should include remote");

         REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID_
                                                           inContext:self.defaultContext];
         STAssertNotNil(buttonGroup, @"we should be able to fetch the previously created button group");
         STAssertTrue([remote.subelements containsObject:buttonGroup],
                      @"remote's set of subelements should include button group");

         REButton * button = [REButton objectWithUUID:buttonUUID_ inContext:self.defaultContext];
         STAssertNotNil(button, @"we should be able to fetch the previously created button");
         STAssertTrue([buttonGroup.subelements containsObject:button],
                      @"button group's set of subelements should include button");

         [controller MR_deleteInContext:self.defaultContext];
         controller = nil; remote = nil; buttonGroup = nil; button = nil;

         button = [REButton objectWithUUID:buttonUUID_ inContext:self.defaultContext];
         STAssertNil(button, @"button should not have been retrievable after deletion");
         buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID_
                                           inContext:self.defaultContext];
         STAssertNil(buttonGroup, @"button group should not have been retrievable after deletion");
         remote = [RERemote objectWithUUID:remoteUUID_
                                 inContext:self.defaultContext];
         STAssertNil(remote, @"remote should not have been retrievable after deletion");
         NSError * error = nil;
         [self.defaultContext save:&error];
         STAssertNil(error, @"error occurred during save when it should not have");

         STAssertEquals(self.defaultContext.registeredObjects.count, (NSUInteger)0,
                        @"all the registered objects should have been deleted");
     }];
}

/**
 * Test whether `rootSavingContext` observed changes to deletions in `self.defaultContext`
 */

- (void)testRootSavingContextMergedChangesAfterDeletion
{
    assert(NO);
    [self.rootSavingContext performBlockAndWait:
     ^{
         REButton * button = [REButton objectWithUUID:buttonUUID_
                                            inContext:self.rootSavingContext];
         STAssertNil(button, @"button should not have been retrievable after deletion");
         REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID_
                                                           inContext:self.rootSavingContext];
         STAssertNil(buttonGroup, @"button group should not have been retrievable after deletion");
         RERemote * remote = [RERemote objectWithUUID:remoteUUID_
                                            inContext:self.rootSavingContext];
         STAssertNil(remote, @"remote should not have been retrievable after deletion");

         NSError * error = nil;
         [self.rootSavingContext save:&error];
         STAssertNil(error, @"error occurred during save when it should not have");
         
         STAssertEquals(self.rootSavingContext.registeredObjects.count, (NSUInteger)0,
                        @"all the registered objects should have been deleted");
     }];
}

/**
 * Create and save an `RERemoteElement` object using MagicalRecord.
 */
- (void)testRemoteCreationAndSaveWithMagicalRecord
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         [self remoteCreationAndSaveWithContext:localContext];
     }];
}

/**
 * Create and save an `REButtonGroup` object using MagicalRecord.
 */
- (void)testButtonGroupCreationAndSaveWithMagicalRecord
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         [self buttonGroupCreationAndSaveWithContext:localContext];
     }];
}

/**
 * Create and save an `REButton` object using MagicalRecord.
 */
- (void)testButtonCreationAndSaveWithMagicalRecord
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         [self buttonCreationAndSaveWithContext:localContext];
     }];
}

/**
 * Create an `RERemoteController` object, retrieve previously created `RERemote`, register with
 * controller as the home remote and save using MagicalRecord.
 */
- (void)testRemoteControllerCreationAndSaveWithMagicalRecord
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         [self remoteControllerCreationAndSaveWithContext:localContext];
     }];
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[
             NSValueWithPointer(@selector(testRemoteCreationAndSaveWithMagicalRecord)),
             NSValueWithPointer(@selector(testButtonGroupCreationAndSaveWithMagicalRecord)),
             NSValueWithPointer(@selector(testButtonCreationAndSaveWithMagicalRecord)),
             NSValueWithPointer(@selector(testRemoteControllerCreationAndSaveWithMagicalRecord))
             ];
}

@end
