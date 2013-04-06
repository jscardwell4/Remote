// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RELayoutConfiguration.h instead.

#import <CoreData/CoreData.h>



extern const struct RELayoutConfigurationAttributes {
	 NSString *bitVector;
} RELayoutConfigurationAttributes;



extern const struct RELayoutConfigurationRelationships {
	 NSString *element;
} RELayoutConfigurationRelationships;






@class RemoteElement;



@class NSObject;

@interface RELayoutConfigurationID : NSManagedObjectID {}
@end

@interface _RELayoutConfiguration : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RELayoutConfigurationID*)objectID;





@property (nonatomic, retain) id bitVector;



//- (BOOL)validateBitVector:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) RemoteElement *element;

//- (BOOL)validateElement:(id*)value_ error:(NSError**)error_;





@end



@interface _RELayoutConfiguration (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveBitVector;
- (void)setPrimitiveBitVector:(id)value;





- (RemoteElement*)primitiveElement;
- (void)setPrimitiveElement:(RemoteElement*)value;


@end
