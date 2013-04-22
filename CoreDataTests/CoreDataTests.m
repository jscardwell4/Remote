//
//  CoreDataTests.m
//  CoreDataTests
//
//  Created by Jason Cardwell on 4/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "CoreDataTests.h"
#import <MagicalRecord/MagicalRecord.h>
#import <Lumberjack/Lumberjack.h>
#import <MSKit/MSKit.h>
#import "CoreDataManager.h"
#import "MSRemoteMacros.h"
#import "RemoteElement.h"

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_COREDATATESTS|LOG_CONTEXT_CONSOLE|LOG_CONTEXT_FILE;

@implementation CoreDataTests

+ (void)attachLoggers
{
    NSString * logsDirectory = $(@"%@/CoreDataTests", [MSLog defaultLogDirectory]);
    [MSLog addDefaultFileLoggerForContext:LOG_CONTEXT_COREDATATESTS directory:logsDirectory];
}

+ (void)setUp
{
    [super setUp];
    // Set-up code here.

    [self attachLoggers];

/*
    MSLogDebugTag(@"initializing core data stack for test suite");
    NSManagedObjectModel * model = [NSManagedObjectModel mergedModelFromBundles:nil];
    assert(model);
    NSManagedObjectModel * augmentedModel = [CoreDataManager augmentModel:model];
    assert(augmentedModel);

    NSString * modelDescription = [CoreDataManager objectModelDescription:augmentedModel];
    MSLogDebugInContextTag(LOG_CONTEXT_COREDATATESTS|LOG_CONTEXT_FILE,
                           @"object model for test suite:\n%@",
                           modelDescription);
    
    [NSManagedObjectModel MR_setDefaultManagedObjectModel:augmentedModel];
    assert([NSManagedObjectModel MR_defaultManagedObjectModel] == augmentedModel);

    [MagicalRecord setupCoreDataStackWithInMemoryStore];
*/
}

+ (void)tearDown
{
    // Tear-down code here.
    MSLogDebugTag(@"cleaning up core data stack for test suite");
    [MagicalRecord cleanUp];
    [super tearDown];
}

- (void)testCreateRemoteAndSaveViaMagicalRecord
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext * context)
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
         MSLogDebugTag(@"test remote: %@\nsaving context via local reference to main context...", remote);
     }];
}

- (void)testCreateRemoteAndSaveViaReferencedContext
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
    [context performBlockAndWait:
     ^{
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
         MSLogDebugTag(@"test remote: %@\nsaving context via local reference to main context...", remote);
         NSError * error = nil;
         [context save:&error];
         if (error) [MagicalRecord handleErrors:error];
     }];
}

//- (void)testCreateButtonGroup
//{
//}

//- (void)testCreateButton
//{
//    
//}

@end
