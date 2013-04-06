// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateButtonImageSet.h instead.

#import <CoreData/CoreData.h>
#import "ControlStateImageSet.h"





extern const struct ControlStateButtonImageSetRelationships {
	 NSString *button;
} ControlStateButtonImageSetRelationships;






@class REButton;


@interface ControlStateButtonImageSetID : ControlStateImageSetID {}
@end

@interface _ControlStateButtonImageSet : ControlStateImageSet {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ControlStateButtonImageSetID*)objectID;





@property (nonatomic, retain) REButton *button;

//- (BOOL)validateButton:(id*)value_ error:(NSError**)error_;





@end



@interface _ControlStateButtonImageSet (CoreDataGeneratedPrimitiveAccessors)



- (REButton*)primitiveButton;
- (void)setPrimitiveButton:(REButton*)value;


@end
