// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateColorSet.h instead.

#import <CoreData/CoreData.h>
#import "ControlStateSet.h"



extern const struct ControlStateColorSetAttributes {
	 NSString *colorSetType;
	 NSString *disabledAndSelectedPatternImage;
	 NSString *disabledPatternImage;
	 NSString *highlightedAndDisabledPatternImage;
	 NSString *highlightedAndSelectedPatternImage;
	 NSString *highlightedPatternImage;
	 NSString *normalPatternImage;
	 NSString *patternColorStates;
	 NSString *selectedHighlightedAndDisabledPatternImage;
	 NSString *selectedPatternImage;
} ControlStateColorSetAttributes;



extern const struct ControlStateColorSetRelationships {
	 NSString *button;
	 NSString *icons;
} ControlStateColorSetRelationships;






@class REButton;
@class ControlStateIconImageSet;





@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;


@class NSObject;




@class NSObject;


@class NSObject;

@interface ControlStateColorSetID : ControlStateSetID {}
@end

@interface _ControlStateColorSet : ControlStateSet {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ControlStateColorSetID*)objectID;





@property (nonatomic, retain) NSNumber* colorSetType;




@property (atomic) int16_t colorSetTypeValue;
- (int16_t)colorSetTypeValue;
- (void)setColorSetTypeValue:(int16_t)value_;


//- (BOOL)validateColorSetType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id disabledAndSelectedPatternImage;



//- (BOOL)validateDisabledAndSelectedPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id disabledPatternImage;



//- (BOOL)validateDisabledPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlightedAndDisabledPatternImage;



//- (BOOL)validateHighlightedAndDisabledPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlightedAndSelectedPatternImage;



//- (BOOL)validateHighlightedAndSelectedPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id highlightedPatternImage;



//- (BOOL)validateHighlightedPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id normalPatternImage;



//- (BOOL)validateNormalPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* patternColorStates;




@property (atomic) int16_t patternColorStatesValue;
- (int16_t)patternColorStatesValue;
- (void)setPatternColorStatesValue:(int16_t)value_;


//- (BOOL)validatePatternColorStates:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id selectedHighlightedAndDisabledPatternImage;



//- (BOOL)validateSelectedHighlightedAndDisabledPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id selectedPatternImage;



//- (BOOL)validateSelectedPatternImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) REButton *button;

//- (BOOL)validateButton:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ControlStateIconImageSet *icons;

//- (BOOL)validateIcons:(id*)value_ error:(NSError**)error_;





@end



@interface _ControlStateColorSet (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveColorSetType;
- (void)setPrimitiveColorSetType:(NSNumber*)value;

- (int16_t)primitiveColorSetTypeValue;
- (void)setPrimitiveColorSetTypeValue:(int16_t)value_;




- (id)primitiveDisabledAndSelectedPatternImage;
- (void)setPrimitiveDisabledAndSelectedPatternImage:(id)value;




- (id)primitiveDisabledPatternImage;
- (void)setPrimitiveDisabledPatternImage:(id)value;




- (id)primitiveHighlightedAndDisabledPatternImage;
- (void)setPrimitiveHighlightedAndDisabledPatternImage:(id)value;




- (id)primitiveHighlightedAndSelectedPatternImage;
- (void)setPrimitiveHighlightedAndSelectedPatternImage:(id)value;




- (id)primitiveHighlightedPatternImage;
- (void)setPrimitiveHighlightedPatternImage:(id)value;




- (id)primitiveNormalPatternImage;
- (void)setPrimitiveNormalPatternImage:(id)value;




- (NSNumber*)primitivePatternColorStates;
- (void)setPrimitivePatternColorStates:(NSNumber*)value;

- (int16_t)primitivePatternColorStatesValue;
- (void)setPrimitivePatternColorStatesValue:(int16_t)value_;




- (id)primitiveSelectedHighlightedAndDisabledPatternImage;
- (void)setPrimitiveSelectedHighlightedAndDisabledPatternImage:(id)value;




- (id)primitiveSelectedPatternImage;
- (void)setPrimitiveSelectedPatternImage:(id)value;





- (REButton*)primitiveButton;
- (void)setPrimitiveButton:(REButton*)value;



- (ControlStateIconImageSet*)primitiveIcons;
- (void)setPrimitiveIcons:(ControlStateIconImageSet*)value;


@end
