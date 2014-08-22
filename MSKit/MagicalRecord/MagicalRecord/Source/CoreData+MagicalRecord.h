
#ifndef NS_BLOCKS_AVAILABLE
    #warning MagicalRecord requires blocks
#endif

#ifdef __OBJC__
//#if defined(__has_feature)
//    #if !( __has_feature(objc_arc))
//        #warning MagicalRecord now requires ARC to be enabled
//    #endif
//#endif

    #import <CoreFoundation/CoreFoundation.h>
    #import <CoreData/CoreData.h>
    #import "MagicalRecord/MagicalRecord.h"
    #import "MagicalRecord/MagicalRecord+Options.h"
    #import "MagicalRecord/MagicalRecord+ShorthandSupport.h"
    #import "MagicalRecord/MagicalRecord+Setup.h"

    #import "MagicalRecord/MagicalRecordStack.h"
    #import "MagicalRecord/MagicalRecordStack+Actions.h"
    #import "MagicalRecord/SQLiteMagicalRecordStack.h"
    #import "MagicalRecord/SQLiteWithSavingContextMagicalRecordStack.h"
    #import "MagicalRecord/InMemoryMagicalRecordStack.h"
    #import "MagicalRecord/iCloudMagicalRecordStack.h"
    #import "MagicalRecord/AutoMigratingMagicalRecordStack.h"
    #import "MagicalRecord/ManuallyMigratingMagicalRecordStack.h"
    #import "MagicalRecord/AutoMigratingWithSourceAndTargetModelMagicalRecordStack.h"
    #import "MagicalRecord/ClassicWithBackgroundCoordinatorSQLiteMagicalRecordStack.h"

    #ifdef MR_SHORTHAND
        #import "MagicalRecord/MagicalRecordShorthand.h"
    #endif

    #import "MagicalRecord/NSManagedObject+MagicalRecord.h"
    #import "MagicalRecord/NSManagedObject+MagicalRequests.h"
    #import "MagicalRecord/NSManagedObject+MagicalFinders.h"
    #import "MagicalRecord/NSManagedObject+MagicalAggregation.h"
    #import "MagicalRecord/NSManagedObjectContext+MagicalRecord.h"
    #import "MagicalRecord/NSManagedObjectContext+MagicalObserving.h"
    #import "MagicalRecord/NSManagedObjectContext+MagicalSaves.h"

    #import "MagicalRecord/NSPersistentStoreCoordinator+MagicalRecord.h"
    #import "MagicalRecord/NSPersistentStoreCoordinator+MagicalAutoMigrations.h"
    #import "MagicalRecord/NSPersistentStoreCoordinator+MagicalManualMigrations.h"
    #import "MagicalRecord/NSPersistentStoreCoordinator+MagicalInMemoryStoreAdditions.h"
    #import "MagicalRecord/NSPersistentStoreCoordinator+MagicaliCloudAdditions.h"

    #import "MagicalRecord/NSManagedObjectModel+MagicalRecord.h"
    #import "MagicalRecord/NSPersistentStore+MagicalRecord.h"

    #import "MagicalRecord/MagicalImportFunctions.h"
    #import "MagicalRecord/NSManagedObject+MagicalDataImport.h"
    #import "MagicalRecord/NSNumber+MagicalDataImport.h"
    #import "MagicalRecord/NSObject+MagicalDataImport.h"
    #import "MagicalRecord/NSString+MagicalDataImport.h"
    #import "MagicalRecord/NSAttributeDescription+MagicalDataImport.h"
    #import "MagicalRecord/NSRelationshipDescription+MagicalDataImport.h"
    #import "MagicalRecord/NSEntityDescription+MagicalDataImport.h"
    #import "MagicalRecord/NSError+MagicalRecordErrorHandling.h"

    #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        #import "MagicalRecord/NSManagedObject+MagicalFetching.h"
        #import "MagicalRecord/NSFetchedResultsController+MagicalFetching.h"
    #endif

#endif

// @see https://github.com/ccgus/fmdb/commit/aef763eeb64e6fa654e7d121f1df4c16a98d9f4f
#define MRDispatchQueueRelease(q) (dispatch_release(q))

#if TARGET_OS_IPHONE
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        #undef MRDispatchQueueRelease
        #define MRDispatchQueueRelease(q)
    #endif
#else
    #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
        #undef MRDispatchQueueRelease
        #define MRDispatchQueueRelease(q)
    #endif
#endif
