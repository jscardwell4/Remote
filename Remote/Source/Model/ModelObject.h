//
//  ModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSKit/MSKit.h"

@interface ModelObject : NSManagedObject <MSJSONExport>

MSEXTERN_STRING ModelObjectInitializingContextName;

BOOL UUIDIsValid(NSString * uuid);

@property (nonatomic, copy, readonly) NSString * uuid;

+ (instancetype)existingObjectWithUUID:(NSString *)uuid;
+ (instancetype)existingObjectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc;
+ (instancetype)objectWithUUID:(NSString *)uuid;
+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc;

- (id)objectForKeyedSubscript:(NSString *)uuid;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)moc;
+ (NSArray *)findAll;
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate;
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending context:(NSManagedObjectContext *)moc;
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending;
+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)value;
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate;
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending;
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending
                                        context:(NSManagedObjectContext *)moc;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate;

+ (instancetype)importObjectFromData:(NSDictionary *)data context:(NSManagedObjectContext *)moc;
+ (NSArray *)importObjectsFromData:(id)data context:(NSManagedObjectContext *)moc;

- (void)updateWithData:(NSDictionary *)data;

- (MSDictionary *)deepDescriptionDictionary;
- (NSString *)deepDescription;
- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level;
- (NSString *)modelObjectDescription;

- (BOOL)attributeValueIsDefault:(NSString *)attributeName;

@end

#define SafeSetValueForKey(VALUE, KEY, DICT) ({ DICT[KEY] = CollectionSafe(VALUE); })
#define SuppressDefaultValue(ATTRIBUTE, BLOCK) ({ if (![self attributeValueIsDefault:ATTRIBUTE]) { BLOCK;} })
#define SetValueForKeyIfNotDefault(VALUE, KEY, DICT) \
  SuppressDefaultValue(KEY, SafeSetValueForKey(VALUE, [KEY camelCaseToDashCase], DICT))
ModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid);
ModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx);

@protocol NamedModelObject <NSObject>

- (NSString *)name;

@end

NSString * namedModelObjectDescription(ModelObject<NamedModelObject> * modelObject);
NSString * unnamedModelObjectDescription(ModelObject * modelObject);

#import "CoreDataManager.h"