// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HTTPCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct HTTPCommandAttributes {
	 NSString *url;
} HTTPCommandAttributes;












@interface HTTPCommandID : CommandID {}
@end

@interface _HTTPCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (HTTPCommandID*)objectID;





@property (nonatomic, retain) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;






@end



@interface _HTTPCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;




@end
