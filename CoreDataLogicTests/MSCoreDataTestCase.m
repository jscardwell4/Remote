//
//  MSCoreDataTestCase.m
//  Remote
//
//  Created by Jason Cardwell on 4/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSCoreDataTestCase.h"
#import "CoreDataManager.h"
#import "ModelObject.h"

//#define REMOVE_STORE_EACH_RUN

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

static NSMutableSet           * registeredClasses_    = nil;
static NSString               * storePath_            = nil;
static NSManagedObjectContext * defaultContext_       = nil;
static NSManagedObjectContext * rootSavingContext_    = nil;
static BOOL                     useMagicalSaves_      = NO;
static BOOL                     useMagicalSetup_      = NO;
static BOOL                     usePersistentStore_   = NO;
static BOOL                     useUndoManager_       = NO;
static BOOL                     useBackgroundSaving_  = NO;
static BOOL                     logContextSaves_      = NO;


static NSString const * storedValuesFileName  = @"MSCoreDataTestCase_StoredValues.plist";

@interface MSCoreDataTestCase ()

@property (nonatomic, copy,   readwrite) NSString               * storePath;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * defaultContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * rootSavingContext;

@property (nonatomic, assign, readwrite, getter = shouldUseMagicalSaves) BOOL useMagicalSaves;

@end

@implementation MSCoreDataTestCase

+ (void)initialize
{
    if (self == [MSCoreDataTestCase class])
        registeredClasses_ = [NSMutableSet setWithObject:self];
    else
        [registeredClasses_ addObject:self];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SenTestCase
////////////////////////////////////////////////////////////////////////////////

/// Overridden to create only invocations for selectors returned by `arrayOfInvocationSelectors`.
+ (NSArray *)testInvocations
{
    NSArray * selectors = [self arrayOfInvocationSelectors];

    return [selectors arrayByMappingToBlock:
            ^NSInvocation *(NSValue * selector, NSUInteger idx)
            {
                NSInvocation * invocation =
                    [NSInvocation invocationWithMethodSignature:
                     [self instanceMethodSignatureForSelector:PointerValue(selector)]];

                [invocation setSelector:PointerValue(selector)];
                
                return invocation;
            }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - SenTestSuiteExtensions
////////////////////////////////////////////////////////////////////////////////

/**
 * Initializes the core data stack according various overridable options.
 */
+ (void) setUp
{
    [super setUp];

    // Once per class initialization, check for environment variable to remove existing store
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (BOOLValue([[NSProcessInfo processInfo] environment][@"DeleteExistingStore"]))
            [self removeExistingFiles];
    });

    [self initializeManagedObjectModel];

    [self initializeOptions];

    if (useMagicalSetup_) [self initializeWithMagicalSetup]; // Let MagicalRecord do the setup work

    else
    {
        [self initializePersistentStoreCoordinator];
        [self initializeManagedObjectContexts];
    }

    if (logContextSaves_) [self observeManagedObjectContexts];

    [self initializeUndoSupport];
}

/**
 * Set instance variables from class variables.
 */
- (void)setUp
{
    [super setUp];

    [MagicalRecord setErrorHandlerTarget:self action:@selector(handleErrors:)];

    self.defaultContext    = defaultContext_;
    self.rootSavingContext = rootSavingContext_;
    self.useMagicalSaves   = useMagicalSaves_;
    self.storePath         = storePath_;
}

- (void)tearDown
{
    self.defaultContext    = nil;
    self.rootSavingContext = nil;
    self.storePath         = nil;
    [super tearDown];
}

/**
 * Cleans up core data stack and removes persistent store if one was created.
 */
+ (void) tearDown
{
    [NotificationCenter removeObserver:self];

    // Dispose of contexts, model, store, coordinator
    defaultContext_    = nil;
    rootSavingContext_ = nil;
    [MagicalRecord cleanUp];

#ifdef REMOVE_STORE_EACH_RUN
    // Delete store file
    if (storePath_ && [FileManager fileExistsAtPath:storePath_])
    {
        NSError * error = nil;
        [FileManager removeItemAtPath:storePath_ error:&error];
        if (error) [MagicalRecord handleErrors:error];
        storePath_ = nil;
    }
#endif
    [super tearDown];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Core Data Additions
////////////////////////////////////////////////////////////////////////////////

/**
 * The primary, main queue `NSManagedObjectContext` set during `setUp`.
 */
+ (NSManagedObjectContext *)defaultContext { return defaultContext_; }

/**
 * Path to created persistent store file if store is not held in memory.
 */
+ (NSManagedObjectContext *)rootSavingContext { return rootSavingContext_; }

/**
 * Path to created persistent store file if store is not held in memory set during `setUp`.
 */
+ (NSString *)storePath { return storePath_; }

/**
 * Overridden by subclasses to provide separate sqlite persistent store name.
 */
+ (NSString *)storeName { return @"MSCoreDataTestCase.sqlite"; }

/**
 * Overridden by subclasses to customize core data stack environment
 */
+ (MSCoreDataTestOptions)options { return MSCoreDataTestDefaultOptions; }

/**
 * Whether to use `MagicalRecord` save blocks for testing context persistence
 */
+ (BOOL)shouldUseMagicalSaves { return ([self options] & MSCoreDataTestMagicalSaves); }

/**
 * Overridden by subclasses to provide name of model to use.
 */
+ (NSString *)modelName { return nil; }

/**
 * May be overridden by subclasses to alter model used in tests before the core data stack is 
 * intialized.
 */
+ (NSManagedObjectModel *)augmentedModelForModel:(NSManagedObjectModel *)model { return model; }

/**
 * Overridden by subclasses to provide an array of selectors wrapped as `NSValue` objects to use in
 * generating test suite invocations.
 */
+ (NSArray *)arrayOfInvocationSelectors { return @[]; }

/**
 * Calls `+[CoreDataManager handlerErrors:]` to log error and then fails the unit test.
 */
- (void)handleErrors:(NSError *)error
{
    [CoreDataManager handleErrors:error];
    STFail(@"Error occurred in Magical Record framework");
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializing Core Data Stack
////////////////////////////////////////////////////////////////////////////////

+ (void)initializeManagedObjectModel
{
    // Create a url for the managed object model
    NSString * testedUnitPath = [UserDefaults stringForKey:@"SenTestedUnitPath"];
    NSString * modelPath      = [testedUnitPath stringByAppendingPathComponent:[self modelName]];
    NSURL    * modelURL       = [NSURL URLWithString:modelPath];

    // Create and augment the managed object model
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSManagedObjectModel * augmentedModel = [self augmentedModelForModel:model];

    // Set the augmented managed object model as the default model
    [NSManagedObjectModel MR_setDefaultManagedObjectModel:augmentedModel];
}

+ (void)initializeOptions
{
    // Get runtime arguments regarding core data stack
    MSCoreDataTestOptions options = [self options];
    useMagicalSaves_     = (options & MSCoreDataTestMagicalSaves           );
    useMagicalSetup_     = (options & MSCoreDataTestMagicalSetup           );
    usePersistentStore_  = (options & MSCoreDataTestPersistentStore        );
    useUndoManager_      = (options & MSCoreDataTestUndoSupport            );
    useBackgroundSaving_ = (options & MSCoreDataTestBackgroundSavingContext);
    logContextSaves_     = (options & MSCoreDataTestLogContextSaves        );

    MSDictionary * optionsDictionary =
        [MSDictionary dictionaryWithDictionary:
          @{ @"Magical saves"      : BOOLString(useMagicalSaves_),
             @"Magical setup?"     : BOOLString(useMagicalSetup_),
             @"Persistent store?"  : BOOLString(usePersistentStore_),
             @"Undo support?"      : BOOLString(useUndoManager_),
             @"Background saving?" : BOOLString(useBackgroundSaving_),
             @"Log context saves?" : BOOLString(logContextSaves_) }];

    NSString * optionsString = [optionsDictionary formattedDescriptionWithOptions:0 levelIndent:0];

    MSLogInfoTag(@"options:  %@", [optionsString stringByReplacingOccurrencesOfString:@"\n" withString:@"\n              "]);
}

+ (void)initializeWithMagicalSetup
{
    if (usePersistentStore_)
    {
        // Initialize the core data stack
        [MagicalRecord setupCoreDataStackWithStoreNamed:[self storeName]];

        // Hold onto the path to which the persistent store has been created
        storePath_ = [[[NSPersistentStore MR_defaultPersistentStore] URL] path];
        MSLogInfoTag(@"store path: %@", storePath_);

        // Store references to the contexts created by MagicalRecord
        defaultContext_    = [NSManagedObjectContext MR_defaultContext   ];
        rootSavingContext_ = [NSManagedObjectContext MR_rootSavingContext];
    }

    else
    {
        [MagicalRecord setupCoreDataStackWithInMemoryStore];

        // Store references to the contexts created by MagicalRecord
        defaultContext_    = [NSManagedObjectContext MR_defaultContext];
        rootSavingContext_ = [NSManagedObjectContext MR_rootSavingContext];
    }
    if (defaultContext_.parentContext)
        [defaultContext_ registerAsChildOfContext:defaultContext_.parentContext];

}

+ (void)initializePersistentStoreCoordinator
{
    if (usePersistentStore_)
    {
        // Establish URL for persistent store
        NSError * error = nil;
        NSURL * supportDirectory = [FileManager URLForDirectory:NSApplicationSupportDirectory
                                                       inDomain:NSUserDomainMask
                                              appropriateForURL:nil
                                                         create:NO
                                                          error:&error];
        if (error) [MagicalRecord handleErrors:error];

        NSURL * storeURL = [supportDirectory
                            URLByAppendingPathComponent:[self storeName]];

        // Create a persistent store coordinator with the augmented managed object model
        NSPersistentStoreCoordinator * persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel
                                                                          MR_defaultManagedObjectModel]];

        NSDictionary * options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                    NSInferMappingModelAutomaticallyOption       : @YES };

        error = nil;

        // Add a persistent store using the established URL
        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:options
                                                         error:&error];

        if (error) [MagicalRecord handleErrors:error];

        // Register as default coordinator, should also set default persistent store
        [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:persistentStoreCoordinator];

        // Hold onto the path to which the persistent store has been created
        storePath_ = [[[NSPersistentStore MR_defaultPersistentStore] URL] path];
        MSLogInfoTag(@"store path: %@", storePath_);
    }

    else
    {
        // Create a persistent store coordinator with the augmented managed object model
        NSPersistentStoreCoordinator * persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel
                                                                          MR_defaultManagedObjectModel]];

        NSError * error = nil;
        [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                 configuration:nil
                                                           URL:nil
                                                       options:nil
                                                         error:&error];
        if (error) [MagicalRecord handleErrors:error];

        // Register as default coordinator, should also set default persistent store
        [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:persistentStoreCoordinator];
    }
}

+ (void)initializeManagedObjectContexts
{
    if (useBackgroundSaving_)
    {
        rootSavingContext_ = [[NSManagedObjectContext alloc]
                              initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [rootSavingContext_ performBlockAndWait:
         ^{
             rootSavingContext_.persistentStoreCoordinator = [NSPersistentStoreCoordinator
                                                              MR_defaultStoreCoordinator];
         }];

        [NSManagedObjectContext MR_setRootSavingContext:rootSavingContext_];

        defaultContext_ = [[NSManagedObjectContext alloc]
                           initWithConcurrencyType:NSMainQueueConcurrencyType];
        [defaultContext_ performBlockAndWait:
         ^{
             defaultContext_.parentContext = rootSavingContext_;
         }];

        [NSManagedObjectContext MR_setDefaultContext:defaultContext_];
    }

    else
    {

        // Create the default context on the main queue with the coordinator just created
        defaultContext_ = [[NSManagedObjectContext alloc]
                           initWithConcurrencyType:NSMainQueueConcurrencyType];
        [defaultContext_ performBlockAndWait:
         ^{
             defaultContext_.persistentStoreCoordinator = [NSPersistentStoreCoordinator
                                                           MR_defaultStoreCoordinator];
         }];

        [NSManagedObjectContext MR_setDefaultContext:defaultContext_];
    }

    if (defaultContext_.parentContext)
        [defaultContext_ registerAsChildOfContext:defaultContext_.parentContext];
}

+ (void)initializeUndoSupport
{
    // Make sure the context has undo support if specified
    if (useUndoManager_)
        [defaultContext_ performBlockAndWait:^{ defaultContext_.undoManager = [NSUndoManager new]; }];
}

+ (void)observeManagedObjectContexts
{
    void (^handleContextWillSaveNotification)(NSNotification *) =
    ^(NSNotification * note)
    {
        NSManagedObjectContext * context = (NSManagedObjectContext *)note.object;
        [context performBlockAndWait:
         ^{
             NSSet * registeredObjects = [context registeredObjects];
             MSLogInfoTag(@"saving context '%@'...\nregistered objects:\n%@",
                          [context description],
                          [[registeredObjects valueForKeyPath:@"deepDescription"]
                           componentsJoinedByString:@"\n"]);
         }];

    };

    if (defaultContext_)
        [NotificationCenter addObserverForName:NSManagedObjectContextWillSaveNotification
                                        object:defaultContext_
                                         queue:MainQueue
                                    usingBlock:handleContextWillSaveNotification];

    if (rootSavingContext_)
        [NotificationCenter addObserverForName:NSManagedObjectContextWillSaveNotification
                                        object:rootSavingContext_
                                         queue:MainQueue
                                    usingBlock:handleContextWillSaveNotification];
}

+ (void)removeExistingFiles
{
    // Also remove stored values as they may be invalidated
    NSURL * storedValuesURL = [self valueStorageURL];
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSError * error = nil;
    if (![fm removeItemAtURL:storedValuesURL error:&error])
    {
        NSError * underlyingError = error.userInfo[NSUnderlyingErrorKey];
        if (   [underlyingError.domain isEqualToString:NSPOSIXErrorDomain]
            && underlyingError.code == 2)
            MSLogInfoTag(@"no stored values to remove");
        else
            MSHandleErrors(error);
    }

    else
        MSLogInfoTag(@"stored values have been removed");

    // Get the store names from registered subclasses
    NSSet * storeNames = [registeredClasses_ valueForKeyPath:@"storeName"];
    MSLogInfoTag(@"stores to remove:  %@",
                 [storeNames componentsJoinedByString:@"\n                       "]);
    for (NSString * storeName in storeNames)
    { // Delete the store file
        NSURL * storeURL = [NSPersistentStore MR_urlForStoreName:storeName];
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSError * error = nil;
        if (![fm removeItemAtURL:storeURL error:&error])
        {
            NSError * underlyingError = error.userInfo[NSUnderlyingErrorKey];
            if (   [underlyingError.domain isEqualToString:NSPOSIXErrorDomain]
                && underlyingError.code == 2)
                MSLogInfoTag(@"no existing store to remove with name '%@'", storeName);
            else
                [MagicalRecord handleErrors:error];
        }

        else
            MSLogInfoTag(@"previous persistent store named '%@' has been removed", storeName);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Storing Arbitrary Values
////////////////////////////////////////////////////////////////////////////////

+ (NSDictionary *)storedValues
{
    return [NSDictionary dictionaryWithContentsOfURL:[self valueStorageURL]];
}

+ (NSURL *)valueStorageURL
{
    static const NSURL * valueStorageURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError * error = nil;
        NSURL * supportDirectory = [FileManager URLForDirectory:NSApplicationSupportDirectory
                                                       inDomain:NSUserDomainMask
                                              appropriateForURL:nil
                                                         create:NO
                                                          error:&error];
        if (error) MSHandleErrors(error);
        
        valueStorageURL = [supportDirectory URLByAppendingPathComponent:(NSString *)storedValuesFileName];
    });

    return (NSURL *)valueStorageURL;
}

+ (id)valueStoredForKey:(NSString *)key
{
    return [NSDictionary dictionaryWithContentsOfURL:[self valueStorageURL]][key];
}

+ (void)storeValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary * storedValues = [NSMutableDictionary
                                          dictionaryWithContentsOfURL:[self valueStorageURL]];
    if (!storedValues) storedValues = [@{} mutableCopy];
    storedValues[key] = value;
    [storedValues writeToURL:[self valueStorageURL] atomically:YES];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return [[self class] valueStoredForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    [[self class] storeValue:object forKey:key];
}

@end
