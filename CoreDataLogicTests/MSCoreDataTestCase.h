//
//  MSCoreDataTestCase.h
//  Remote
//
//  Created by Jason Cardwell on 4/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

typedef NS_OPTIONS(uint8_t, MSCoreDataTestOptions) {
    MSCoreDataTestDefaultOptions  			= 0b00000000,
    MSCoreDataTestMagicalSaves    			= 0b00000001,
    MSCoreDataTestMagicalSetup    			= 0b00010010,
    MSCoreDataTestPersistentStore 			= 0b00000100,
    MSCoreDataTestUndoSupport     			= 0b00001000,
    MSCoreDataTestBackgroundSavingContext 	= 0b00010000,
    MSCoreDataTestLogContextSaves           = 0b00100000,
    MSCoreDataTestLogCreatedObjects         = 0b01000000,
    MSCoreDataTestLogParseEvents            = 0b10000000
};

#define MSLogCreatedObjectsInContext(ctx, frmt, ...)        \
    do                                                      \
    {                                                       \
        if(msTestOptions & MSCoreDataTestLogCreatedObjects) \
            MSLogInfoInContext(ctx, frmt, __VA_ARGS__);     \
    } while (0)

#define MSLogCreatedObjects(frmt, ...) MSLogCreatedObjectsInContext(msLogContext, frmt, __VA_ARGS__)

#define MSLogCCreatedObjectsInContext(ctx, frmt, ...)                 \
    do                                                               \
    {                                                                \
    if(msTestOptions & MSCoreDataTestLogCreatedObjects) \
    MSLogCInfoInContext(ctx, frmt, __VA_ARGS__);              \
    } while (0)

#define MSLogCCreatedObjects(frmt, ...) MSLogCCreatedObjectsInContext(msLogContext, frmt, __VA_ARGS__)

@interface MSCoreDataTestCase : SenTestCase

/// Path to created persistent store file if store is not held in memory set during `setUp`.
@property (nonatomic, copy,   readonly) NSString * storePath;

/// The primary, main queue `NSManagedObjectContext` set during `setUp`.
@property (nonatomic, strong, readonly) NSManagedObjectContext * defaultContext;

/// The secondary, background saving queue `NSManagedObjectContext` set during `setUp`.
@property (nonatomic, strong, readonly) NSManagedObjectContext * rootSavingContext;

/// Whether to use `MagicalRecord` save blocks for testing context persistence.
@property (nonatomic, assign, readonly, getter = shouldUseMagicalSaves) BOOL useMagicalSaves;

/// Path to created persistent store file if store is not held in memory.
+ (NSString *)storePath;

/// Whether to use `MagicalRecord` save blocks for testing context persistence.
+ (BOOL)shouldUseMagicalSaves;

/// The primary, main queue `NSManagedObjectContext` for use in tests.
+ (NSManagedObjectContext *)defaultContext;

/// The secondary, background saving queue `NSManagedObjectContext` for use in tests.
+ (NSManagedObjectContext *)rootSavingContext;

/// Overridden by subclasses to customize core data stack environment.
+ (MSCoreDataTestOptions)options;

/// Overridden by subclasses to provide name of model to use.
+ (NSString *)modelName;

/// Overridden by subclasses to alter model before the core data stack is intialized.
+ (NSManagedObjectModel *)augmentedModelForModel:(NSManagedObjectModel *)model;

- (id)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

+ (void)storeValue:(id)value forKey:(NSString *)key;

+ (id)valueStoredForKey:(NSString *)key;

+ (NSDictionary *)storedValues;

@end
