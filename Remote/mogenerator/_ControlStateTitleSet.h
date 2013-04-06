// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateTitleSet.h instead.

#import <CoreData/CoreData.h>
#import "ControlStateSet.h"





extern const struct ControlStateTitleSetRelationships {
	 NSString *button;
	 NSString *delegate;
} ControlStateTitleSetRelationships;






@class REButton;
@class REButtonConfigurationDelegate;


@interface ControlStateTitleSetID : ControlStateSetID {}
@end

@interface _ControlStateTitleSet : ControlStateSet {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ControlStateTitleSetID*)objectID;





@property (nonatomic, retain) REButton *button;

//- (BOOL)validateButton:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) REButtonConfigurationDelegate *delegate;

//- (BOOL)validateDelegate:(id*)value_ error:(NSError**)error_;





@end



@interface _ControlStateTitleSet (CoreDataGeneratedPrimitiveAccessors)



- (REButton*)primitiveButton;
- (void)setPrimitiveButton:(REButton*)value;



- (REButtonConfigurationDelegate*)primitiveDelegate;
- (void)setPrimitiveDelegate:(REButtonConfigurationDelegate*)value;


@end
