//
// IRCodeSet.h
// iPhonto
//
// Created by Jason Cardwell on 3/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Manufacturer.h"

@class   IRCode;

@interface IRCodeSet : NSManagedObject

@property (nonatomic, strong) NSString     * name;
@property (nonatomic, strong) Manufacturer * manufacturer;
@property (nonatomic, strong) NSSet        * codes;

+ (IRCodeSet *)newCodeSetInContext:(NSManagedObjectContext *)context
                          withName:(NSString *)codeSetName;

@end

@interface IRCodeSet (CoreDataGeneratedAccessors)

- (void)addCodesObject:(IRCode *)value;
- (void)removeCodesObject:(IRCode *)value;
- (void)addCodes:(NSSet *)values;
- (void)removeCodes:(NSSet *)values;

@end
