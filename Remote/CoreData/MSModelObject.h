//
//  MSModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface MSModelObject : NSManagedObject

@property (nonatomic, copy, readonly) NSString * uuid;

+ (instancetype)objectWithUUID:(NSString *)uuid;
+ (instancetype)objectWithUUID:(NSString *)uuid inContext:(NSManagedObjectContext *)context;

- (id)objectForKeyedSubscript:(NSString *)uuid;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (MSDictionary *)deepDescriptionDictionary;
- (NSString *)deepDescription;

@end

MSModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid);
MSModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx);