// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manufacturer.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"





extern const struct ManufacturerRelationships {
	 NSString *codesets;
} ManufacturerRelationships;






@class IRCodeSet;


@interface ManufacturerID : BankObjectID {}
@end

@interface _Manufacturer : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManufacturerID*)objectID;





@property (nonatomic, retain) NSSet *codesets;

- (NSMutableSet*)codesetsSet;





@end


@interface _Manufacturer (CodesetsCoreDataGeneratedAccessors)
- (void)addCodesets:(NSSet*)value_;
- (void)removeCodesets:(NSSet*)value_;
- (void)addCodesetsObject:(IRCodeSet*)value_;
- (void)removeCodesetsObject:(IRCodeSet*)value_;
@end


@interface _Manufacturer (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveCodesets;
- (void)setPrimitiveCodesets:(NSMutableSet*)value;


@end
