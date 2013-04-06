// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REPickerLabelButtonGroup.h instead.

#import <CoreData/CoreData.h>
#import "REButtonGroup.h"



extern const struct REPickerLabelButtonGroupAttributes {
	 NSString *commandSetLabels;
	 NSString *commandSets;
} REPickerLabelButtonGroupAttributes;











@class NSObject;


@class NSObject;

@interface REPickerLabelButtonGroupID : REButtonGroupID {}
@end

@interface _REPickerLabelButtonGroup : REButtonGroup {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REPickerLabelButtonGroupID*)objectID;





@property (nonatomic, retain) id commandSetLabels;



//- (BOOL)validateCommandSetLabels:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id commandSets;



//- (BOOL)validateCommandSets:(id*)value_ error:(NSError**)error_;






@end



@interface _REPickerLabelButtonGroup (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveCommandSetLabels;
- (void)setPrimitiveCommandSetLabels:(id)value;




- (id)primitiveCommandSets;
- (void)setPrimitiveCommandSets:(id)value;




@end
