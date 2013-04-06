// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateIconImageSet.h instead.

#import <CoreData/CoreData.h>
#import "ControlStateImageSet.h"



extern const struct ControlStateIconImageSetAttributes {
	 NSString *styledIconStates;
} ControlStateIconImageSetAttributes;



extern const struct ControlStateIconImageSetRelationships {
	 NSString *button;
	 NSString *iconColors;
} ControlStateIconImageSetRelationships;






@class REButton;
@class ControlStateColorSet;




@interface ControlStateIconImageSetID : ControlStateImageSetID {}
@end

@interface _ControlStateIconImageSet : ControlStateImageSet {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ControlStateIconImageSetID*)objectID;





@property (nonatomic, retain) NSNumber* styledIconStates;




@property (atomic) int16_t styledIconStatesValue;
- (int16_t)styledIconStatesValue;
- (void)setStyledIconStatesValue:(int16_t)value_;


//- (BOOL)validateStyledIconStates:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) REButton *button;

//- (BOOL)validateButton:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ControlStateColorSet *iconColors;

//- (BOOL)validateIconColors:(id*)value_ error:(NSError**)error_;





@end



@interface _ControlStateIconImageSet (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveStyledIconStates;
- (void)setPrimitiveStyledIconStates:(NSNumber*)value;

- (int16_t)primitiveStyledIconStatesValue;
- (void)setPrimitiveStyledIconStatesValue:(int16_t)value_;





- (REButton*)primitiveButton;
- (void)setPrimitiveButton:(REButton*)value;



- (ControlStateColorSet*)primitiveIconColors;
- (void)setPrimitiveIconColors:(ControlStateColorSet*)value;


@end
