// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateSet.h instead.

#import <CoreData/CoreData.h>



extern const struct ControlStateSetAttributes {
	 NSString *disabled;
	 NSString *disabledAndSelected;
	 NSString *highlighted;
	 NSString *highlightedAndDisabled;
	 NSString *highlightedAndSelected;
	 NSString *normal;
	 NSString *selected;
	 NSString *selectedHighlightedAndDisabled;
	 NSString *uuid;
} ControlStateSetAttributes;











@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;



@interface ControlStateSetID : NSManagedObjectID {}
@end

@interface _ControlStateSet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ControlStateSetID*)objectID;





@property (nonatomic, retain) id disabled;



//- (BOOL)validateDisabled:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id disabledAndSelected;



//- (BOOL)validateDisabledAndSelected:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlighted;



//- (BOOL)validateHighlighted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlightedAndDisabled;



//- (BOOL)validateHighlightedAndDisabled:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlightedAndSelected;



//- (BOOL)validateHighlightedAndSelected:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id normal;



//- (BOOL)validateNormal:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id selected;



//- (BOOL)validateSelected:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id selectedHighlightedAndDisabled;



//- (BOOL)validateSelectedHighlightedAndDisabled:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end



@interface _ControlStateSet (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveDisabled;
- (void)setPrimitiveDisabled:(id)value;




- (id)primitiveDisabledAndSelected;
- (void)setPrimitiveDisabledAndSelected:(id)value;




- (id)primitiveHighlighted;
- (void)setPrimitiveHighlighted:(id)value;




- (id)primitiveHighlightedAndDisabled;
- (void)setPrimitiveHighlightedAndDisabled:(id)value;




- (id)primitiveHighlightedAndSelected;
- (void)setPrimitiveHighlightedAndSelected:(id)value;




- (id)primitiveNormal;
- (void)setPrimitiveNormal:(id)value;




- (id)primitiveSelected;
- (void)setPrimitiveSelected:(id)value;




- (id)primitiveSelectedHighlightedAndDisabled;
- (void)setPrimitiveSelectedHighlightedAndDisabled:(id)value;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
