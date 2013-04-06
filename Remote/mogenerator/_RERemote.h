// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RERemote.h instead.

#import <CoreData/CoreData.h>
#import "RemoteElement.h"



extern const struct RERemoteAttributes {
	 NSString *topBarHiddenOnLoad;
} RERemoteAttributes;












@interface RERemoteID : RemoteElementID {}
@end

@interface _RERemote : RemoteElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RERemoteID*)objectID;





@property (nonatomic, retain) NSNumber* topBarHiddenOnLoad;




@property (atomic) BOOL topBarHiddenOnLoadValue;
- (BOOL)topBarHiddenOnLoadValue;
- (void)setTopBarHiddenOnLoadValue:(BOOL)value_;


//- (BOOL)validateTopBarHiddenOnLoad:(id*)value_ error:(NSError**)error_;






@end



@interface _RERemote (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveTopBarHiddenOnLoad;
- (void)setPrimitiveTopBarHiddenOnLoad:(NSNumber*)value;

- (BOOL)primitiveTopBarHiddenOnLoadValue;
- (void)setPrimitiveTopBarHiddenOnLoadValue:(BOOL)value_;




@end
