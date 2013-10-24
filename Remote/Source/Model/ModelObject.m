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

    if (ModelObjectShouldInitialize)
        self.primitiveUuid = MSNonce();

}

+ (instancetype)objectWithUUID:(NSString *)uuid
{
    return [self objectWithUUID:uuid context:[CoreDataManager defaultContext]];
}

+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context
{
    if (!context) ThrowInvalidNilArgument(context);
    else if (!UUIDIsValid(uuid)) ThrowInvalidArgument(uuid, is not of proper form);
    return [self MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:context];
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


- (MSDictionary *)JSONDictionary { assert(self.uuid); return [MSDictionary dictionaryWithObject:self.uuid
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

