// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonGroup.h instead.

#import <CoreData/CoreData.h>
#import "RemoteElement.h"



extern const struct REButtonGroupAttributes {
	 NSString *label;
	 NSString *labelConstraints;
} REButtonGroupAttributes;



extern const struct REButtonGroupRelationships {
	 NSString *commandSet;
	 NSString *topToolbarForController;
} REButtonGroupRelationships;






@class CommandSet;
@class RERemoteController;



@class NSObject;



@interface REButtonGroupID : RemoteElementID {}
@end

@interface _REButtonGroup : RemoteElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REButtonGroupID*)objectID;





@property (nonatomic, retain) id label;



//- (BOOL)validateLabel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* labelConstraints;



//- (BOOL)validateLabelConstraints:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) CommandSet *commandSet;

//- (BOOL)validateCommandSet:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RERemoteController *topToolbarForController;

//- (BOOL)validateTopToolbarForController:(id*)value_ error:(NSError**)error_;





@end



@interface _REButtonGroup (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveLabel;
- (void)setPrimitiveLabel:(id)value;




- (NSString*)primitiveLabelConstraints;
- (void)setPrimitiveLabelConstraints:(NSString*)value;





- (CommandSet*)primitiveCommandSet;
- (void)setPrimitiveCommandSet:(CommandSet*)value;



- (RERemoteController*)primitiveTopToolbarForController;
- (void)setPrimitiveTopToolbarForController:(RERemoteController*)value;


@end
