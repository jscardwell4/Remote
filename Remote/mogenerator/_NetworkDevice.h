// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetworkDevice.h instead.

#import <CoreData/CoreData.h>



extern const struct NetworkDeviceAttributes {
	 NSString *uuid;
} NetworkDeviceAttributes;












@interface NetworkDeviceID : NSManagedObjectID {}
@end

@interface _NetworkDevice : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (NetworkDeviceID*)objectID;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end



@interface _NetworkDevice (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
