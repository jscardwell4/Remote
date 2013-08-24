//
//  MSModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"

MSKIT_STRING_CONST MSModelObjectInitializingContextName = @"MSModelObjectInitializingContextName";

@interface MSModelObject (CoreDataGeneratedAccessors)

@property (nonatomic, copy) NSString * primitiveUuid;

@end


@implementation MSModelObject

@dynamic uuid;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize)
        self.primitiveUuid = MSNonce();

}

+ (instancetype)objectWithUUID:(NSString *)uuid
{
    return (StringIsNotEmpty(uuid)
            ? [self objectWithUUID:uuid context:[NSManagedObjectContext MR_contextForCurrentThread]]
            : nil);
}

+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context
{
    return (StringIsNotEmpty(uuid)
            ? [self MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:context]
            : nil);
}

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

- (MSDictionary *)deepDescriptionDictionary
{
    MSMutableDictionary * dd = [MSMutableDictionary dictionary];
    dd[@"class"]   = ClassString([self class]);
    dd[@"address"] = $(@"%p", self);
    dd[@"uuid"]    = self.uuid;
    dd[@"context"] = $(@"%p%@",
                                          self.managedObjectContext,
                                          (self.managedObjectContext.nametag
                                           ? $(@":'%@'",self.managedObjectContext.nametag)
                                           : @""));

    return dd;
}

- (NSString *)deepDescription { return [self deepDescriptionWithOptions:0 indentLevel:1]; }

- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level
{
    MSDictionary * dd = [self deepDescriptionDictionary];
    return [dd  formattedDescriptionWithOptions:options levelIndent:level];
//    NSNumber * maxKeyLength = [[dd allKeys] valueForKeyPath:@"@max.length"];
//
//    NSMutableString * description = [@"" mutableCopy];
//    [dd enumerateKeysAndObjectsUsingBlock:
//     ^(NSString * key, NSString * value, BOOL *stop)
//     {
//         [description appendFormat:@"%@ %@\n",
//          [[key stringByAppendingString:@":"] stringByRightPaddingToLength:([maxKeyLength longValue] + 2) withCharacter:' '],
//          [value stringByShiftingRight:23 shiftFirstLine:NO]];
//     }];
//
//    return [description stringByShiftingRight:4];
}

- (NSString *)modelObjectDescription
{
        return (([self conformsToProtocol:@protocol(MSNamedModelObject)])
                ? namedModelObjectDescription((MSModelObject<MSNamedModelObject> *)self)
                : unnamedModelObjectDescription(self)
                );
}

@end

MSModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid)
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
                     return (   [obj isKindOfClass:[MSModelObject class]]
                             && [((MSModelObject *)obj).uuid isEqualToString:uuid]);
                 }];
}

MSModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx)
{
    return ([collection respondsToSelector:@selector(objectAtIndexedSubscript:)]
            ? collection[idx]
            : nil);
}

NSString * namedModelObjectDescription(MSModelObject<MSNamedModelObject> * modelObject)
{
    return (modelObject
            ? $(@"%@(%p):'%@'", modelObject.uuid, modelObject, (modelObject.name ?: @""))
            : @"nil");
}

NSString * unnamedModelObjectDescription(MSModelObject * modelObject)
{
    return (modelObject? $(@"%@(%p)", modelObject.uuid, modelObject) : @"nil");
}

