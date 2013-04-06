// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DelayCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct DelayCommandAttributes {
	 NSString *duration;
} DelayCommandAttributes;







extern const struct DelayCommandUserInfo {
} DelayCommandUserInfo;






@interface DelayCommandID : CommandID {}
@end

@interface _DelayCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DelayCommandID*)objectID;





@property (nonatomic, retain) NSNumber* duration;




@property (atomic) float durationValue;
- (float)durationValue;
- (void)setDurationValue:(float)value_;


//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;






@end



@interface _DelayCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (float)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(float)value_;




@end
