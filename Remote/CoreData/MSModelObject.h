//
//  MSModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface MSModelObject : NSManagedObject

MSKIT_EXTERN_STRING MSModelObjectInitializingContextName;

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

#define MSModelObjectShouldInitialize                                              \
    ({ BOOL isOriginal = NO;                                                       \
       if (!self.uuid) isOriginal = YES;                                           \
       else if (!self.managedObjectContext.childContexts.count) isOriginal = YES;  \
       isOriginal; })


MSModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid);
MSModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx);

@protocol MSNamedModelObject <NSObject>

- (NSString *)name;

@end

NSString * namedModelObjectDescription(MSModelObject<MSNamedModelObject> * modelObject);
NSString * unnamedModelObjectDescription(MSModelObject * modelObject);
