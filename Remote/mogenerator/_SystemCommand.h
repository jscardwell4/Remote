// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SystemCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct SystemCommandAttributes {
	 NSString *key;
} SystemCommandAttributes;












@interface SystemCommandID : CommandID {}
@end

@interface _SystemCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SystemCommandID*)objectID;





@property (nonatomic, retain) NSNumber* key;




@property (atomic) int16_t keyValue;
- (int16_t)keyValue;
- (void)setKeyValue:(int16_t)value_;


//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;






@end



@interface _SystemCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveKey;
- (void)setPrimitiveKey:(NSNumber*)value;

- (int16_t)primitiveKeyValue;
- (void)setPrimitiveKeyValue:(int16_t)value_;




@end
