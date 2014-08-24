//
//  ModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSSTRING_CONST ModelObjectInitializingContextName = @"ModelObjectInitializingContextName";

BOOL UUIDIsValid(NSString * uuid)
{
    if (!uuid) return NO;

    NSRange r = [uuid rangeOfRegEX:@"[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}"];
    return (uuid && r.location == 0 && r.length == [uuid length]);
}

@interface ModelObject (CoreDataGeneratedAccessors)

@property (nonatomic, copy) NSString * primitiveUuid;

@end


@implementation ModelObject

@dynamic uuid;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    self.primitiveUuid = MSNonce();

}

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
+ (instancetype)importObjectFromData:(NSDictionary *)data inContext:(NSManagedObjectContext *)moc {

    if (!moc)  ThrowInvalidNilArgument("managed object context cannot be nil");
    if (!data) ThrowInvalidNilArgument("data cannot be nil");


    NSString * uuid = data[@"uuid"];
    ModelObject * object = nil;

    if (UUIDIsValid(uuid)) {
        object = [self existingObjectWithUUID:uuid context:moc];
        if (!object) object = [self objectWithUUID:uuid context:moc];
    }

    if (!object) object = [self createInContext:moc];

    [object updateWithData:data];
    
    return object;
}

/// This method expects data to be an NSArray of NSDictionary objects. Subclasses that wish to return
/// an array of objects from this method with data being of some other class should not call super other than
/// for throwing invalid nil argument exceptions
///
/// @param data description
/// @param moc description
/// @return NSArray *
+ (NSArray *)importObjectsFromData:(id)data inContext:(NSManagedObjectContext *)moc {

    if (!moc)  ThrowInvalidNilArgument("managed object context cannot be nil");
    if (!data) ThrowInvalidNilArgument("data cannot be nil");

    if ([data isKindOfClass:[NSArray class]]) {
        // call `importObjectFromData:inContext` on each dictionary in the array

        NSMutableArray * objects = [(NSArray *)data mutableCopy];
        [objects filter:^BOOL(id evaluatedObject) { return isDictionaryKind(evaluatedObject); }];
        [objects map:^id(id objData, NSUInteger idx) {
            return CollectionSafe([self importObjectFromData:objData inContext:moc]);
        }];
        [objects removeNullObjects];


        return objects;
    }

    return nil;
}

+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)moc {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class]) predicate:predicate];
    NSError * error = nil;
    NSArray * result = [moc executeFetchRequest:request error:&error];
    MSHandleErrors(error);
    return result;
}
+ (NSArray *)findAllMatchingPredicate:(NSPredicate *)predicate {
    return [self findAllMatchingPredicate:predicate inContext:[CoreDataManager defaultContext]];
}

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)moc {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class])];
    NSError * error = nil;
    NSArray * result = [moc executeFetchRequest:request error:&error];
    MSHandleErrors(error);
    return result;
}
+ (NSArray *)findAll { return [self findAllInContext:[CoreDataManager defaultContext]]; }

+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:ascending]];
    NSError * error = nil;
    NSArray * result = [moc executeFetchRequest:request error:&error];
    MSHandleErrors(error);
    return result;
}

+ (NSArray *)findAllSortedBy:(NSString *)sortBy ascending:(BOOL)ascending {
    return [self findAllSortedBy:sortBy ascending:ascending inContext:[CoreDataManager defaultContext]];
}

+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)moc {

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class]) predicate:predicate];
    NSError * error = nil;
    NSUInteger result = [moc countForFetchRequest:request error:&error];
    MSHandleErrors(error);
    return result;

}
+ (NSUInteger)countOfObjectsWithPredicate:(NSPredicate *)predicate {
    return [self countOfObjectsWithPredicate:predicate inContext:[CoreDataManager defaultContext]];
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)moc {
    NSArray * matches = [self findAllMatchingPredicate:predicate inContext:moc];
    if ([matches count] > 0) [moc deleteObjects:[matches set]];
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate {
    [self deleteAllMatchingPredicate:predicate inContext:[CoreDataManager defaultContext]];
}

+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending
                                        inContext:(NSManagedObjectContext *)moc
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ClassString([self class]) predicate:predicate];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:ascending]];
    if (groupBy) request.propertiesToGroupBy = @[groupBy];
    NSFetchedResultsController * resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                         managedObjectContext:moc
                                                                                           sectionNameKeyPath:nil
                                                                                                    cacheName:nil];
    return resultsController;
}
+ (NSFetchedResultsController *)fetchAllGroupedBy:(NSString *)groupBy
                                    withPredicate:(NSPredicate *)predicate
                                         sortedBy:(NSString *)sortBy
                                        ascending:(BOOL)ascending
{
    return [self fetchAllGroupedBy:groupBy
                     withPredicate:predicate
                          sortedBy:sortBy
                         ascending:ascending
                         inContext:[CoreDataManager defaultContext]];
}

+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)value {
    return [self findFirstByAttribute:attribute withValue:value inContext:[CoreDataManager defaultContext]];
}


+ (instancetype)existingObjectWithUUID:(NSString *)uuid
{
    return [self existingObjectWithUUID:uuid context:[CoreDataManager defaultContext]];
}

+ (instancetype)existingObjectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc
{
    if (!moc) ThrowInvalidNilArgument(context);
    if (UUIDIsValid(uuid)) return [self findFirstByAttribute:@"uuid" withValue:uuid inContext:moc];
    else return nil;
}

+ (instancetype)objectWithUUID:(NSString *)uuid {
    return [self objectWithUUID:uuid context:[CoreDataManager defaultContext]];
}


/// This method will create a new model object with the specified uuid. if `uuid` is nil or invalid
/// an automatically generated uuid is used. Throws an exception if the context is nil or if an object
/// with the specified uuid already exists.
///
/// @param uuid description
/// @param moc description
/// @return instancetype
+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)moc {
    if (!moc) ThrowInvalidNilArgument("context cannot be nil");

    ModelObject * object = [self existingObjectWithUUID:uuid context:moc];
    if (object) ThrowInvalidArgument(uuid, "an object with this uuid already exists, "
                                           "perhaps you meant to call existingObjectWithUUID:context: ?");

    object = [self createInContext:moc];
    if (UUIDIsValid(uuid)) object.primitiveUuid = uuid;

    return object;
}

- (void)updateWithData:(NSDictionary *)data {}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Subscripts
////////////////////////////////////////////////////////////////////////////////

- (id)keySubscriptedCollection { return nil; }

- (id)indexSubscriptedCollection { return nil; }

- (id)objectForKeyedSubscript:(NSString *)uuid
{
    return memberOfCollectionWithUUID([self keySubscriptedCollection], uuid);
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return memberOfCollectionAtIndex([self indexSubscriptedCollection], idx);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Descriptions
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)deepDescriptionDictionary
{
    MSDictionary * dd = [MSDictionary dictionary];
    dd[@"class"]   = ClassString([self class]);
    dd[@"address"] = $(@"%p", self);
    dd[@"uuid"]    = self.uuid;
    dd[@"context"] = $(@"%p%@",
                       self.managedObjectContext,
                       (self.managedObjectContext.nametag
                        ? $(@":'%@'",self.managedObjectContext.nametag)
                        : @""));

    return (MSDictionary *)dd;
}

- (NSString *)deepDescription { return [self deepDescriptionWithOptions:0 indentLevel:1]; }

- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level
{
    MSDictionary * dd = [self deepDescriptionDictionary];
    return [dd  formattedDescriptionWithOptions:options levelIndent:level];
}

- (NSString *)modelObjectDescription
{
        return (([self conformsToProtocol:@protocol(NamedModelObject)])
                ? namedModelObjectDescription((ModelObject<NamedModelObject> *)self)
                : unnamedModelObjectDescription(self)
                );
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark JSON export
////////////////////////////////////////////////////////////////////////////////

- (NSString *)JSONString { return [self.JSONDictionary JSONString]; }


- (MSDictionary *)JSONDictionary
{
    assert(self.uuid);
    return [MSDictionary dictionaryWithObject:self.uuid forKey:@"uuid"];
}

- (id)JSONObject { return [self.JSONDictionary JSONObject]; }

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Functions
////////////////////////////////////////////////////////////////////////////////


ModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid)
{
    NSSet * set = nil;
    
    if ([collection isKindOfClass:[NSSet class]])
        set = (NSSet *)collection;

    else if ([collection isKindOfClass:[NSOrderedSet class]])
        set = [(NSOrderedSet *)collection set];
    
    if (!set.count || StringIsEmpty(uuid))
        return nil;
    
    else
        return [set objectPassingTest:
                 ^BOOL(id obj)
                 {
                     return (   [obj isKindOfClass:[ModelObject class]]
                             && [((ModelObject *)obj).uuid isEqualToString:uuid]);
                 }];
}

ModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx)
{
    return ([collection respondsToSelector:@selector(objectAtIndexedSubscript:)]
            ? collection[idx]
            : nil);
}

NSString * namedModelObjectDescription(ModelObject<NamedModelObject> * modelObject)
{
    return (modelObject
            ? $(@"%@(%p):'%@'", modelObject.uuid, modelObject, (modelObject.name ?: @""))
            : @"nil");
}

NSString * unnamedModelObjectDescription(ModelObject * modelObject)
{
    return (modelObject? $(@"%@(%p)", modelObject.uuid, modelObject) : @"nil");
}

