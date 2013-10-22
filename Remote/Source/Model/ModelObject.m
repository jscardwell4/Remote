//
//  ModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"

static int ddLogLevel = LOG_LEVEL_ERROR;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSSTRING_CONST ModelObjectInitializingContextName = @"ModelObjectInitializingContextName";

@interface ModelObject (CoreDataGeneratedAccessors)

@property (nonatomic, copy) NSString * primitiveUuid;

@end


@implementation ModelObject

@dynamic uuid;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        self.primitiveUuid = MSNonce();

}

+ (instancetype)objectWithUUID:(NSString *)uuid
{
    return (StringIsNotEmpty(uuid)
            ? [self objectWithUUID:uuid context:[CoreDataManager defaultContext]]
            : nil);
}

+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context
{
    return (StringIsNotEmpty(uuid)
            ? [self MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:context]
            : nil);
}

- (void)importFromDictionary:(MSDictionary *)data
{

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark MagicalRecord overrides
////////////////////////////////////////////////////////////////////////////////

//- (BOOL) MR_importValue:(id)value forKey:(NSString *)key {}
//- (void) MR_setAttributes:(NSDictionary *)attributes forKeysWithObject:(id)objectData {}
//- (NSManagedObject *) MR_findObjectForRelationship:(NSRelationshipDescription *)relationshipInfo
//                                          withData:(id)singleRelatedObjectData {}
//- (void) MR_addObject:(NSManagedObject *)relatedObject
//      forRelationship:(NSRelationshipDescription *)relationshipInfo {}
//- (BOOL) MR_shouldImportData:(id)relatedObjectData
//        forRelationshipNamed:(NSString *)relationshipName {}
//- (void) MR_setRelationships:(NSDictionary *)relationships
//           forKeysWithObject:(id)relationshipData
//                   withBlock:(void(^)(NSRelationshipDescription *,id))setRelationshipBlock {}
//- (BOOL) MR_preImport:(id)objectData {}
//- (BOOL) MR_postImport:(id)objectData {}
//- (BOOL) MR_performDataImportFromObject:(id)objectData
//                      relationshipBlock:(void(^)(NSRelationshipDescription*, id))relationshipBlock {}

- (BOOL)shouldImport:(id)data
{
    MSLogDebug(@"data:%@", data);
    return NO;
}

- (void)willImport:(id)data
{
    MSLogDebug(@"");

}

- (void)didImport:(id)data
{
    MSLogDebug(@"");

}

- (BOOL)MR_importValuesForKeysWithObject:(id)objectData
{
    MSLogDebug(@"");
    return [super MR_importValuesForKeysWithObject:objectData];
}

+ (id)MR_importFromObject:(id)objectData inContext:(NSManagedObjectContext *)context;
{
    MSLogDebug(@"");
    return [super MR_importFromObject:objectData inContext:context];
}

+ (id)MR_importFromObject:(id)objectData
{
    MSLogDebug(@"");
    return [super MR_importFromObject:objectData];
}

+ (NSArray *)MR_importFromArray:(NSArray *)listOfObjectData
{
    MSLogDebug(@"");
    return [super MR_importFromArray:listOfObjectData];
}

+ (NSArray *)MR_importFromArray:(NSArray *)listOfObjectData
                      inContext:(NSManagedObjectContext *)context
{
    MSLogDebug(@"");
    return [super MR_importFromArray:listOfObjectData inContext:context];
}

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


- (NSDictionary *)JSONDictionary { return [MSDictionary dictionaryWithObject:self.uuid
                                                                      forKey:@"uuid"]; }

- (id)JSONObject { return [self.JSONDictionary JSONObject]; }

@end

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

