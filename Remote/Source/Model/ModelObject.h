//
//  ModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import Foundation;
@import UIKit;
@import CoreData;
@import CocoaLumberjack;
@import MoonKit;

@protocol Model <NSObject>
@property (nonatomic, copy, readonly) NSString * uuid;
@end

@protocol NamedModel <Model>
@property (nonatomic, copy, readonly) NSString * name;
@end

@protocol RenameableModel <Model>

@property (nonatomic, copy, readwrite) NSString * name;

@end

@interface ModelObject : NSManagedObject <Model>

MSEXTERN_STRING ModelObjectInitializingContextName;

@property (nonatomic, copy, readonly) NSString * uuid;

+ (BOOL)isValidUUID:(NSString *)uuid;
+ (instancetype)objectWithUUID:(NSString *)uuid;
+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc;

- (id)objectForKeyedSubscript:(NSString *)uuid;
//- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

ModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid);
ModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx);

@interface ModelObject (Describing)

- (NSString *)deepDescription;
- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level;

- (MSDictionary *)deepDescriptionDictionary;

@end

NSString *namedModelObjectDescription(ModelObject<NamedModel> * modelObject);
NSString *unnamedModelObjectDescription(ModelObject * modelObject);

@interface ModelObject (Importing)

+ (instancetype)importObjectFromData:(NSDictionary *)data context:(NSManagedObjectContext *)moc;
+ (NSArray *)importObjectsFromData:(id)data context:(NSManagedObjectContext *)moc;
- (void)updateWithData:(NSDictionary *)data;

@end

@interface ModelObject (Exporting) <MSJSONExport>

@property (nonatomic, weak, readonly) id         JSONObject;
@property (nonatomic, weak, readonly) NSString * JSONString;
- (MSDictionary *)JSONDictionary;

- (BOOL)writeJSONToFile:(NSString *)file;
- (BOOL)attributeValueIsDefault:(NSString *)attributeName;

@end

#define SafeSetValueForKey(VALUE, KEY, DICT) ({ DICT[KEY] = CollectionSafe(VALUE); })
#define SuppressDefaultValue(ATTRIBUTE, BLOCK) ({ if (![self attributeValueIsDefault:ATTRIBUTE]) { BLOCK;} })
#define SetValueForKeyIfNotDefault(VALUE, KEY, DICT) \
  SuppressDefaultValue(KEY, SafeSetValueForKey(VALUE, [KEY camelCaseToDashCase], DICT))

@interface ModelObject (Finding)

+ (instancetype)existingObjectWithID:(NSManagedObjectID *)objectID error:(NSError **)error;
+ (instancetype)existingObjectWithID:(NSManagedObjectID *)objectID
                             context:(NSManagedObjectContext *)moc
                               error:(NSError **)error;
+ (instancetype)existingObjectWithUUID:(NSString *)uuid;
+ (instancetype)existingObjectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc;

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)moc;
+ (NSArray *)findAll;
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate;
+ (instancetype)findFirstMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (instancetype)findFirstMatchingPredicate:(NSPredicate *)predicate;
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending context:(NSManagedObjectContext *)moc;
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending;
+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value context:(NSManagedObjectContext *)moc;
+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value;
+ (NSArray *)allValuesForAttribute:(NSString *)attribute;
+ (NSArray *)allValuesForAttribute:(NSString *)attribute context:(NSManagedObjectContext *)moc;

@end

@interface ModelObject (Counting)

+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate;
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;

@end

@interface ModelObject (Fetching)

+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy sortedBy:(NSString *)sortBy;
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                         sortedBy:(NSString *)sortBy
                                          context:(NSManagedObjectContext *)moc;
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending;
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending
                                        context:(NSManagedObjectContext *)moc;

@end

@interface ModelObject (Deleting)

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate;

@end

