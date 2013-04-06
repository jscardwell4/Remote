// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandContainer.h instead.

#import <CoreData/CoreData.h>



extern const struct CommandContainerAttributes {
	 NSString *index;
	 NSString *uuid;
} CommandContainerAttributes;











@class NSObject;



@interface CommandContainerID : NSManagedObjectID {}
@end

@interface _CommandContainer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommandContainerID*)objectID;





@property (nonatomic, retain) id index;



//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end



@interface _CommandContainer (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveIndex;
- (void)setPrimitiveIndex:(id)value;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
