//
//  ModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "MSRemoteMacros.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

MSSTRING_CONST ModelObjectInitializingContextName = @"ModelObjectInitializingContextName";

@interface ModelObject (CoreDataGeneratedAccessors)
@property (nonatomic, copy) NSString * primitiveUuid;
@end


@implementation ModelObject

@dynamic uuid;

/// isValidUUID:
/// @param uuid
/// @return BOOL
+ (BOOL)isValidUUID:(NSString *)uuid {
  NSRange r = [uuid rangeOfRegEx:@"[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}"];
  return (uuid && r.location == 0 && r.length == [uuid length]);
}

/// objectWithUUID:
/// @param uuid
/// @return instancetype
+ (instancetype)objectWithUUID:(NSString *)uuid {
  return [self objectWithUUID:uuid context:[CoreDataManager defaultContext]];
}

/// This method will create a new model object with the specified uuid. if `uuid` is nil or invalid
/// an automatically generated uuid is used. Throws an exception if the context is nil or if an object
/// with the specified uuid already exists.
///
/// @param uuid
/// @param moc
/// @return instancetype
+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc {

  if (!moc) ThrowInvalidNilArgument("context cannot be nil");

  if (![self isValidUUID:uuid])
    ThrowInvalidArgument(uuid, "provided uuid is not of the correct format");

  if ([self existingObjectWithUUID:uuid context:moc])
    ThrowInvalidArgument(uuid, "an object with the uuid provided already exists");

  ModelObject * object = [self createInContext:moc];
  object.primitiveUuid = uuid;

  return object;

}

/// awakeFromInsert
- (void)awakeFromInsert { [super awakeFromInsert]; self.primitiveUuid = MSNonce(); }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Subscripts
////////////////////////////////////////////////////////////////////////////////

/// keyedCollection
/// @return id
- (id)keyedCollection { return nil; }

/// indexedCollection
/// @return id
- (id)indexedCollection { return nil; }

/// objectForKeyedSubscript:
/// @param uuid
/// @return id
- (id)objectForKeyedSubscript:(NSString *)uuid { return memberOfCollectionWithUUID([self keyedCollection], uuid); }

/// objectAtIndexedSubscript:
/// @param idx
/// @return id
- (id)objectAtIndexedSubscript:(NSUInteger)idx { return memberOfCollectionAtIndex([self indexedCollection], idx); }

ModelObject *memberOfCollectionWithUUID(id collection, NSString * uuid) {

  if (![ModelObject isValidUUID:uuid]) ThrowInvalidArgument(uuid, "uuid provided is not valid");

  NSSet * set = nil;

  if ([collection isKindOfClass:[NSSet class]])             set = (NSSet *)collection;
  else if ([collection isKindOfClass:[NSOrderedSet class]]) set = [(NSOrderedSet *)collection set];

  return [set objectPassingTest:^BOOL(id obj) {
    return ([obj isKindOfClass:[ModelObject class]] && [((ModelObject *)obj).uuid isEqualToString : uuid]);
  }];

}

ModelObject *memberOfCollectionAtIndex(id collection, NSUInteger idx) {
  return ([collection respondsToSelector:@selector(objectAtIndexedSubscript:)] ? collection[idx] : nil);
}


@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Importing objects
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Importing)

/// This method create or updates a model object from the specified data. If `data` contains an entry
/// for `uuid` and an object exists with the specified uuid, the existing object should be updated with
/// any values in `data` and returned. Otherwise, a new object should be created and returned. This abstract
/// class implementation looks for an existing object and, if found, calls `updateWithData:` on the object
/// before returning it. This implementation does not create a new object to allow for subclass overrides
/// to call this implementation and receive a valid object only if it already exists and has been updated.
///
/// @param data NSDictionary * containing the import formatted keys and values to assign the model object
/// @param moc NSManagedObjectContext * The context within which to retrieve/create the object.
/// @return instancetype The updated or newly created model object
/// @throws NSInvalidArgumentException if either parameter is nil
+ (instancetype)importObjectFromData:(NSDictionary *)data context:(NSManagedObjectContext *)moc {

  if (!moc) ThrowInvalidNilArgument(moc);

  ModelObject * object = nil;

  if (data) {

    NSString * uuid = data[@"uuid"];

    if ([self isValidUUID:uuid]) {
      object = [self existingObjectWithUUID:uuid context:moc];

      if (!object) object = [self objectWithUUID:uuid context:moc];
    }

    if (!object) object = [self createInContext:moc];

    [object updateWithData:data];
    
  }

  return object;
}

/// This method expects data to be an NSArray of NSDictionary objects. Subclasses that wish to return
/// an array of objects from this method with data being of some other class should not call super other than
/// for throwing invalid nil argument exceptions
///
/// @param data
/// @param moc
/// @return NSArray *
+ (NSArray *)importObjectsFromData:(id)data context:(NSManagedObjectContext *)moc {

  if (!moc) ThrowInvalidNilArgument("managed object context cannot be nil");

  if (!data) return nil;

  if ([data isKindOfClass:[NSArray class]]) {
    // call `importObjectFromData:inContext` on each dictionary in the array

    NSMutableArray * objects = [(NSArray *)data mutableCopy];

    [objects filter:^BOOL (id evaluatedObject) { return isDictionaryKind(evaluatedObject); }];
    [objects map:^id (id objData, NSUInteger idx) {
      return CollectionSafe([self importObjectFromData:objData context:moc]);
    }];
    [objects compact];


    return objects;
  }

  return nil;
}

/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Finding objects
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Finding)

/// existingObjectWithID:error:
/// @param objectID
/// @param error
/// @return instancetype
+ (instancetype)existingObjectWithID:(NSManagedObjectID *)objectID  error:(NSError **)error{
  return [self existingObjectWithID:objectID context:[CoreDataManager defaultContext] error:error];
}

/// existingObjectWithID:context:error:
/// @param objectID
/// @param moc
/// @param error
/// @return instancetype
+ (instancetype)existingObjectWithID:(NSManagedObjectID *)objectID
                             context:(NSManagedObjectContext *)moc
                               error:(NSError **)error
{
  NSManagedObject * object = [moc existingObjectWithID:objectID error:error];
  return [object isKindOfClass:self] ? (ModelObject *)object : nil;
}

/// existingObjectWithUUID:
/// @param uuid
/// @return instancetype
+ (instancetype)existingObjectWithUUID:(NSString *)uuid {
  return [self existingObjectWithUUID:uuid context:[CoreDataManager defaultContext]];
}

/// existingObjectWithUUID:context:
/// @param uuid
/// @param moc
/// @return instancetype
+ (instancetype)existingObjectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc {

  if (!moc) ThrowInvalidNilArgument(context);

  if (![self isValidUUID:uuid])
    ThrowInvalidArgument(uuid, "provided uuid is not of the correct format");

  return [self findFirstByAttribute:@"uuid" withValue:uuid context:moc];
  
}

/// findFirstByAttribute:withValue:context:
/// @param attribute
/// @param value
/// @param moc
/// @return instancetype
+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value context:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString(self)];
  request.fetchLimit = 1;
  request.predicate  = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];

  NSError * error   = nil;
  NSArray * results = [moc executeFetchRequest:request error:&error];
  MSHandleErrors(error);

  return [results firstObject];

}
/// findFirstByAttribute:withValue:
/// @param attribute
/// @param value
/// @return instancetype
+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value {
  return [self findFirstByAttribute:attribute withValue:value context:[CoreDataManager defaultContext]];
}

/// allValuesForAttribute:
/// @param attribute
/// @return NSArray *
+ (NSArray *)allValuesForAttribute:(NSString *)attribute {
  return [self allValuesForAttribute:attribute context:[CoreDataManager defaultContext]];
}

/// allValuesForAttribute:context:
/// @param attribute
/// @param moc
/// @return NSArray *
+ (NSArray *)allValuesForAttribute:(NSString *)attribute context:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString(self)];
  [request setResultType:NSDictionaryResultType];
  [request setReturnsDistinctResults:YES];
  [request setPropertiesToFetch:@[attribute]];

  NSError * error = nil;
  NSArray * results = [moc executeFetchRequest:request error:&error];
  MSHandleErrors(error);

  return [results valueForKeyPath:attribute];

}

/// findAllMatchingPredicate:
/// @param predicate
/// @return NSArray *
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate {
  return [self findAllMatchingPredicate:predicate context:[CoreDataManager defaultContext]];
}

/// findAllMatchingPredicate:context:
/// @param predicate
/// @param moc
/// @return NSArray *
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString(self) predicate:predicate];
  NSError        * error   = nil;
  NSArray        * result  = [moc executeFetchRequest:request error:&error];
  MSHandleErrors(error);
  return result;
}

/// findAll
/// @return NSArray *
+ (NSArray *)findAll { return [self findAllInContext:[CoreDataManager defaultContext]]; }

/// findAllInContext:
/// @param moc
/// @return NSArray *
+ (NSArray *)findAllInContext:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString(self)];
  NSError        * error   = nil;
  NSArray        * result  = [moc executeFetchRequest:request error:&error];
  MSHandleErrors(error);
  return result;

}

/// findAllSortedBy:ascending:
/// @param sortBy
/// @param ascending
/// @return NSArray *
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending {
  return [self findAllSortedBy:sortBy ascending:ascending context:[CoreDataManager defaultContext]];
}

/// findAllSortedBy:ascending:context:
/// @param sortBy
/// @param ascending
/// @param moc
/// @return NSArray *
+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending context:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString(self)];

  request.sortDescriptors = [[@"," split:sortBy] mapped:^(NSString * obj, NSUInteger idx) {
    return [NSSortDescriptor sortDescriptorWithKey:obj ascending:ascending];
  }];

  NSError * error  = nil;
  NSArray * result = [moc executeFetchRequest:request error:&error];
  MSHandleErrors(error);
  return result;

}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Counting objects
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Counting)

/// countOfObjectsWithPredicate:context:
/// @param predicate
/// @param moc
/// @return NSUInteger
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc {

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class])
                                                              predicate:predicate];
  NSError        * error   = nil;
  NSUInteger       result  = [moc countForFetchRequest:request error:&error];

  MSHandleErrors(error);

  return result;

}

/// countOfObjectsWithPredicate:
/// @param predicate
/// @return NSUInteger
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate {
  return [self countOfObjectsWithPredicate:predicate context:[CoreDataManager defaultContext]];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Deleting objects
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Deleting)

/// deleteAllMatchingPredicate:context:
/// @param predicate
/// @param moc
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)moc {
  NSArray * matches = [self findAllMatchingPredicate:predicate context:moc];

  if ([matches count] > 0) [moc deleteObjects:[matches set]];
}

/// deleteAllMatchingPredicate:
/// @param predicate
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate {
  [self deleteAllMatchingPredicate:predicate context:[CoreDataManager defaultContext]];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetching objects
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Fetching)

/// fetchAllGroupedBy:withPredicate:sortedBy:ascending:context:
/// @param groupBy
/// @param predicate
/// @param sortBy
/// @param ascending
/// @param moc
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending
                                        context:(NSManagedObjectContext *)moc {
  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class])
                                                              predicate:predicate];
  if (sortBy)
    request.sortDescriptors = [[sortBy componentsSeparatedByString:@","]
                               mapped:^NSSortDescriptor *(NSString * obj, NSUInteger idx) {
                                 return [NSSortDescriptor sortDescriptorWithKey:obj ascending:ascending];
                               }];

  NSFetchedResultsController * resultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:moc
                                          sectionNameKeyPath:groupBy
                                                   cacheName:nil];

  return resultsController;
}

/// fetchAllGroupedBy:sortedBy:context:
/// @param groupBy
/// @param sortBy
/// @param moc
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                         sortedBy:(NSString *)sortBy
                                          context:(NSManagedObjectContext *)moc
{
  return [self fetchAllGroupedBy:groupBy withPredicate:nil sortedBy:sortBy ascending:YES context:moc];
}

/// fetchAllGroupedBy:sortedBy:
/// @param groupBy
/// @param sortBy
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy sortedBy:(NSString *)sortBy {
  return [self fetchAllGroupedBy:groupBy withPredicate:nil sortedBy:sortBy ascending:YES];
}

/// fetchAllGroupedBy:withPredicate:sortedBy:ascending:
/// @param groupBy
/// @param predicate
/// @param sortBy
/// @param ascending
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending {
  return [self fetchAllGroupedBy:groupBy
                   withPredicate:predicate
                        sortedBy:sortBy
                       ascending:ascending
                       context:[CoreDataManager defaultContext]];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Descriptions
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Describing)

/// deepDescriptionDictionary
/// @return MSDictionary *
- (MSDictionary *)deepDescriptionDictionary {
  MSDictionary * dd = [MSDictionary dictionary];

  dd[@"class"]   = ClassString([self class]);
  dd[@"address"] = $(@"%p", self);
  dd[@"uuid"]    = self.uuid;
  dd[@"context"] = $(@"%p%@",
                     self.managedObjectContext,
                     (self.managedObjectContext.nametag
                      ? $(@":'%@'", self.managedObjectContext.nametag)
                      : @""));

  return (MSDictionary *)dd;
}

/// deepDescription
/// @return NSString *
- (NSString *)deepDescription { return [self deepDescriptionWithOptions:0 indentLevel:1]; }

/// deepDescriptionWithOptions:indentLevel:
/// @param options
/// @param level
/// @return NSString *
- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level {
  MSDictionary * dd = [self deepDescriptionDictionary];

  return [dd formattedDescriptionWithOptions:options levelIndent:level];
}

/// modelObjectDescription
/// @return NSString *
- (NSString *)modelObjectDescription {
  return (([self conformsToProtocol:@protocol(NamedModel)])
          ? namedModelObjectDescription((ModelObject<NamedModel> *)self)
          : unnamedModelObjectDescription(self)
  );
}

NSString *namedModelObjectDescription(ModelObject<NamedModel> * modelObject) {
  return (modelObject
          ? $(@"%@(%p):'%@'", modelObject.uuid, modelObject, (modelObject.name ?: @""))
          : @"nil");
}

NSString *unnamedModelObjectDescription(ModelObject * modelObject) {
  return (modelObject ? $(@"%@(%p)", modelObject.uuid, modelObject) : @"nil");
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSON export
////////////////////////////////////////////////////////////////////////////////
@implementation ModelObject (Exporting)

/// JSONString
/// @return NSString *
- (NSString *)JSONString { return [self.JSONDictionary.JSONString stringByReplacingOccurrencesOfString:@"\\/" withString:@"\\"]; }


/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary { return [MSDictionary dictionaryWithObject:self.uuid forKey:@"uuid"]; }

/// JSONObject
/// @return id
- (id)JSONObject { return [self.JSONDictionary JSONObject]; }

/// writeJSONToFile:
/// @param file
/// @return BOOL
- (BOOL)writeJSONToFile:(NSString *)file {
  NSString * json = self.JSONString;
  return StringIsEmpty(json) ? NO : [json writeToFile:file];
}

/// attributeValueIsDefault:
/// @param attributeName
/// @return BOOL
- (BOOL)attributeValueIsDefault:(NSString *)attributeName {
  return [[self valueForKey:attributeName] isEqual:[self defaultValueForAttribute:attributeName]];
}

@end

