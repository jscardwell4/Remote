//
//  RECoreDataTestCase.m
//  Remote
//
//  Created by Jason Cardwell on 4/19/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RECoreDataTestCase.h"
#import "CoreDataManager.h"
#import <MSKit/MSKit.h>

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation RECoreDataTestCase

/// Overridden to return the name of the application's managed object model.
+ (NSString *)modelName { return @"Remote.momd"; }

/// Overridden to return the result of running the `model` through `+[CoreDataManager augmentModel]`.
+ (NSManagedObjectModel *)augmentedModelForModel:(NSManagedObjectModel *)model
{
    NSManagedObjectModel * augmentedModel = [CoreDataManager augmentModel:model];
    MSLogInfoInContextTag(LOG_CONTEXT_FILE|LOG_CONTEXT_UITESTING,
                          @"model used for test case:\n%@",
                          [CoreDataManager objectModelDescription:augmentedModel]);
    return augmentedModel;
}

/// Returns options for managing our own core data stack with undo support and in-memory store.
+ (MSCoreDataTestOptions)options
{
    return MSCoreDataTestUndoSupport|MSCoreDataTestBackgroundSavingContext;
}

/// Overridden to create more specific store
+ (NSString *)storeName { return @"RECoreDataTestCase.sqlite"; }

- (void)setUp
{
    [super setUp];
    [self.defaultContext performBlockAndWait:
     ^{
         [self.defaultContext reset];
     }];
}

- (void)tearDown
{
    [self.defaultContext performBlockAndWait:
     ^{
         [self.defaultContext reset];
     }];
    [super tearDown];
}

@end
