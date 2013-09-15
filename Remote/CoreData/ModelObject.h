//
//  ModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface ModelObject : NSManagedObject

MSKIT_EXTERN_STRING ModelObjectInitializingContextName;

@property (nonatomic, copy, readonly) NSString * uuid;

+ (instancetype)objectWithUUID:(NSString *)uuid;
+ (instancetype)objectWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context;

- (id)objectForKeyedSubscript:(NSString *)uuid;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (MSDictionary *)deepDescriptionDictionary;
- (NSString *)deepDescription;
- (NSString *)deepDescriptionWithOptions:(NSUInteger)options indentLevel:(NSUInteger)level;
- (NSString *)modelObjectDescription;

@end

#define ModelObjectShouldInitialize                                              \
    ({ BOOL isOriginal = NO;                                                       \
       if (!self.uuid) isOriginal = YES;                                           \
       else if (!self.managedObjectContext.childContexts.count) isOriginal = YES;  \
       isOriginal; })


ModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid);
ModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx);

@protocol NamedModelObject <NSObject>

- (NSString *)name;

@end

NSString * namedModelObjectDescription(ModelObject<NamedModelObject> * modelObject);
NSString * unnamedModelObjectDescription(ModelObject * modelObject);
