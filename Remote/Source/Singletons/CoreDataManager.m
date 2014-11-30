//
// CoreDataManager.m
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"
#import "RemoteController.h"

#define LOG_OBJECT_MODEL

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs and Class Variables

////////////////////////////////////////////////////////////////////////////////

typedef NS_OPTIONS (NSUInteger, CoreDataObjectRemovalOptions) {
  CoreDataManagerRemoveNone                   = 0 << 0,
  CoreDataManagerRemoveIcons                  = 1 << 0,
  CoreDataManagerRemoveBackgrounds            = 1 << 1,
  CoreDataManagerRemoveCodes                  = 1 << 2,
  CoreDataManagerRemoveRemotes                = 1 << 3,
  CoreDataManagerRemoveRemoteController       = 1 << 4,
  CoreDataManagerRemoveRemoveButtonGroups     = 1 << 5,
  CoreDataManagerRemoveRemoveButtons          = 1 << 6,
  CoreDataManagerRemoveConfigurationDelegates = 1 << 7,
  CoreDataManagerRemoveControlStateSets       = 1 << 8
};

static NSManagedObjectModel         * kManagedObjectModel;
static NSManagedObjectContext       * kDefaultContext;
static NSPersistentStoreCoordinator * kPersistentStoreCoordinator;
static NSPersistentStore            * kPersistentStore;

static int       ddLogLevel           = LOG_LEVEL_DEBUG;
static const int msLogContext         = (LOG_CONTEXT_COREDATA | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
static const int magicalRecordContext = (LOG_CONTEXT_MAGICALRECORD);   // |LOG_CONTEXT_CONSOLE);

struct DatabaseFlags_s {
  NSUInteger objectRemoval;
  BOOL       rebuildDatabase;
  BOOL       rebuildRemote;
  BOOL       removePreviousDatabase;
  BOOL       replacePreviousDatabase;
  BOOL       logSaves;
  BOOL       logCoreDataStackSetup;
} kFlags;

NSString *(^getContextDescription)(NSManagedObjectContext *) =
  ^NSString *(NSManagedObjectContext * context)
{
  return (StringIsNotEmpty(context.nametag) ? $(@"%@", context.nametag) : $(@"%p", context));
};


MSSTATIC_STRING_CONST kCoreDataManagerSQLiteName = @"Remote.sqlite";


////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreDataManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation CoreDataManager

+ (void)initialize {
  if (self == [CoreDataManager class]) {
    BOOL loadData        = [UserDefaults boolForKey:@"loadData"];
    BOOL rebuildRemote   = [UserDefaults boolForKey:@"rebuildRemote"];
    BOOL replaceDatabase = [UserDefaults boolForKey:@"replace"];

    kFlags = (struct DatabaseFlags_s) {
      .logSaves                = YES,
      .logCoreDataStackSetup   = YES,
      .removePreviousDatabase  = replaceDatabase || loadData,
      .rebuildRemote           = (rebuildRemote || loadData),
      .rebuildDatabase         = loadData,
      .replacePreviousDatabase = replaceDatabase,
      .objectRemoval           = CoreDataManagerRemoveNone
    };
    assert(  (kFlags.replacePreviousDatabase && !(kFlags.rebuildDatabase || kFlags.rebuildRemote))
          || !kFlags.replacePreviousDatabase);
  }
}

+ (BOOL)initializeDatabase {
  __block BOOL success = YES;

  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{

    /// Create model
    ////////////////////////////////////////////////////////////////////////////////

    NSURL * modelURL = [MainBundle URLForResource:@"Remote" withExtension:@"momd"];

    kManagedObjectModel = [self augmentModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    assert(kManagedObjectModel);

    #ifdef LOG_OBJECT_MODEL
      [self logObjectModel:kManagedObjectModel];
    #endif

    BOOL databaseStoreExists = [self databaseStoreExists];

    if (databaseStoreExists && kFlags.removePreviousDatabase) {
      success = [self removeExistingStore];
      assert(success);
    }

    // Copy bundle resource to store destination if needed
    if (!databaseStoreExists && kFlags.replacePreviousDatabase) {
      success = [self copyBundleDatabaseStore];
      assert(success);
    }

    assert(([self databaseStoreExists] ^ kFlags.rebuildDatabase));

    MSLogDebugTag(@"file operations complete, database %@ flagged for rebuilding",
                  kFlags.rebuildDatabase ? @"is" : @"is not");


    kPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:kManagedObjectModel];
    NSError * error = nil;
    kPersistentStore = [kPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:[self databaseStoreURL]
                                                                       options:@{NSMigratePersistentStoresAutomaticallyOption:
                                                                                   @YES,
                                                                                 NSInferMappingModelAutomaticallyOption:
                                                                                   @YES}
                                                                         error:&error];

    if (error) { MSHandleErrors(error); }

    kDefaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    kDefaultContext.persistentStoreCoordinator = kPersistentStoreCoordinator;
    kDefaultContext.nametag = @"default";

    if (databaseStoreExists && kFlags.rebuildRemote) {
      success = [self removeExistingRemote];
      assert(success);
    }
  });

  return success;
}

+ (void)makeContext:(NSManagedObjectContext *)moc performBlock:(void (^)(void))block {
  if (moc.concurrencyType == NSConfinementConcurrencyType) block();
  else [moc performBlock:block];
}

+ (void)makeContext:(NSManagedObjectContext *)moc performBlockAndWait:(void (^)(void))block {
  if (moc.concurrencyType == NSConfinementConcurrencyType) block();
  else [moc performBlockAndWait:block];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Objects
////////////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)defaultContext {
  return kDefaultContext;
}

+ (NSManagedObjectContext *)childContextOfType:(NSManagedObjectContextConcurrencyType)type forContext:(NSManagedObjectContext *)moc {
  if (moc == nil) return nil;

  NSManagedObjectContext * childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];

  childContext.parentContext = moc;

  return childContext;
}

+ (NSManagedObjectContext *)childContextOfType:(NSManagedObjectContextConcurrencyType)type {
  return [self childContextOfType:type forContext:kDefaultContext];
}

+ (void)resetDefaultContext {
  [kDefaultContext performBlockAndWait:^{ [kDefaultContext reset]; }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Database File Operations
////////////////////////////////////////////////////////////////////////////////

+ (NSURL *)databaseStoreURL {
  static NSURL         * databaseStoreURL = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    NSError * error = nil;
    NSURL * url = [FileManager URLForDirectory:NSApplicationSupportDirectory
                                      inDomain:NSUserDomainMask
                             appropriateForURL:nil
                                        create:YES
                                         error:&error];

    if (!MSHandleErrors(error)) {
      url = [url URLByAppendingPathComponent:@"com.moondeerstudios.Remote"];

      if ([FileManager createDirectoryAtURL:url
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error])
      {
        if (!MSHandleErrors(error))
          databaseStoreURL = [url URLByAppendingPathComponent:kCoreDataManagerSQLiteName];
      }
    }
  });

  return databaseStoreURL;
}

+ (NSURL *)databaseBundleURL {
  static NSURL         * databaseBundleURL = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    databaseBundleURL = [MainBundle URLForResource:kCoreDataManagerSQLiteName withExtension:nil];
  });

  return databaseBundleURL;
}

+ (BOOL)databaseStoreExists {
  return [[self databaseStoreURL] checkResourceIsReachableAndReturnError:NULL];
}

+ (BOOL)copyBundleDatabaseStore {
  NSError * error = nil;

  [FileManager copyItemAtURL:[self databaseBundleURL] toURL:[self databaseStoreURL] error:&error];

  if (error) {
    MSHandleErrors(error);

    return NO;
  } else if (![self databaseStoreExists]) {
    MSLogErrorTag(@"bundle database copied but not found at destination store location");

    return NO;
  } else {
    MSLogDebugTag(@"bundle database store copied to destination successfully");

    return YES;
  }
}

+ (BOOL)removeExistingStore {
  NSError * error = nil;

  if (![self databaseStoreExists]) {
    MSLogDebugTag(@"no previous database store found to remove");

    return YES;
  } else if (![FileManager removeItemAtURL:[self databaseStoreURL] error:&error]) {
    MSHandleErrors(error);

    return NO;
  } else {
    MSLogDebugTag(@"previous database store has been removed");

    return YES;
  }
}

+ (BOOL)removeExistingRemote {
  __block BOOL             success = YES;
  NSManagedObjectContext * moc     = kDefaultContext;

  [moc performBlockAndWait:
   ^{
    RemoteController * controller = [RemoteController findFirstInContext:moc];
    MSLogDebugTag(@"existing remote? %@", NSStringFromBOOL((controller != nil)));

    if (controller) {
      [moc deleteObject:controller];
      MSLogDebugTag(@"existing remote has been deleted");
    }

    NSError * error = nil;
    success = [moc save:&error];
    MSHandleErrors(error);
  }];

  if (success)
    [moc performBlockAndWait:
     ^{
      RemoteController * controller = [RemoteController findFirstInContext:moc];
      success = (controller == nil ? YES : NO);
    }];

  return success;
}

+ (void)saveContext:(NSManagedObjectContext *)moc propagate:(BOOL)propagate {

  __block BOOL success = NO;
  __block NSError * error = nil;

  [moc performBlockAndWait:^{
    [moc processPendingChanges];
    if ([moc hasChanges]) {
      success = [moc save:&error];
      MSHandleErrors(error);
    } else { success = YES; }
  }];

  if (success && !error && propagate && moc.parentContext) {
    [moc.parentContext performBlockAndWait:^{
      [moc.parentContext processPendingChanges];
      if ([moc.parentContext hasChanges]) {
        success = [moc.parentContext save:&error];
        MSHandleErrors(error);
      }
    }];
  }

}

+ (void)saveWithBlock:(void (^)(NSManagedObjectContext * localContext))block {
  [kDefaultContext performBlock:^{
    block(kDefaultContext);
    NSError * error = nil;
    [kDefaultContext save:&error];
    MSHandleErrors(error);
  }];
}

+ (void)saveWithBlock:(void (^)(NSManagedObjectContext * localContext))block
           completion:(void (^)(BOOL success, NSError * error))completion {
  if (!completion)
    ThrowInvalidNilArgument("completion block is nil, perhaps you should be using +[saveWithBlock:]?");

  __block BOOL      success = NO;
  __block NSError * error   = nil;

  [kDefaultContext performBlock:^{
    if (block) block(kDefaultContext);
    success = [kDefaultContext save:&error];
    completion(success, error);
  }];
}

+ (void)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * localContext))block {
  [kDefaultContext performBlockAndWait:^{
    if (block) block(kDefaultContext);
    NSError * error = nil;
    [kDefaultContext save:&error];
    MSHandleErrors(error);
  }];
}

+ (void)backgroundSaveWithBlock:(void (^)(NSManagedObjectContext * localContext))block {
  NSManagedObjectContext * childContext = [self childContextOfType:NSPrivateQueueConcurrencyType];
  childContext.undoManager = nil;
  [childContext performBlock:^{
    if (block) block(childContext);
    NSError * error = nil;
    if ([childContext hasChanges]) {
      [childContext save:&error];
      MSHandleErrors(error);
    }
    if (!error && [kDefaultContext hasChanges])
      [kDefaultContext performBlock:^{
        NSError * error = nil;
        [kDefaultContext save:&error];
        MSHandleErrors(error);
      }];
  }];
}

+ (void)backgroundSaveWithBlock:(void (^)(NSManagedObjectContext * localContext))block
                     completion:(void (^)(BOOL success, NSError * error))completion {
  if (!completion)
    ThrowInvalidNilArgument("completion block is nil, perhaps you should be using +[saveWithBlock:]?");

  NSManagedObjectContext * childContext = [self childContextOfType:NSPrivateQueueConcurrencyType];
  childContext.undoManager = nil;
  [childContext performBlock:^{

    if (block) block(childContext);
    __block BOOL success = YES;
    __block NSError * error = nil;
    if ([childContext hasChanges]) {
      success = [childContext save:&error];
      MSHandleErrors(error);
    }
    if (success) {
      if (!error && [kDefaultContext hasChanges])
        [kDefaultContext performBlock:^{
          NSError * error = nil;
          success = [kDefaultContext save:&error];
          MSHandleErrors(error);
          completion(success, error);
        }];

    } else { completion(success, error); }

  }];
}

+ (void)backgroundSaveWithBlockAndWait:(void (^)(NSManagedObjectContext * localContext))block {
  NSManagedObjectContext * childContext = [self childContextOfType:NSPrivateQueueConcurrencyType];
  childContext.undoManager = nil;
  __block NSError * error = nil;
  __block BOOL success = true;

  [childContext performBlockAndWait:^{
    if (block) block(childContext);
    if ([childContext hasChanges]) {
      success = [childContext save:&error];
      MSHandleErrors(error);
    }
  }];

  if (success && [kDefaultContext hasChanges])
    [kDefaultContext performBlockAndWait:^{
      success = [kDefaultContext save:&error];
      MSHandleErrors(error);
    }];
}

@end
