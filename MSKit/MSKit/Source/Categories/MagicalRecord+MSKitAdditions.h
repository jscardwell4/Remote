//
//  MagicalRecord+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>

@class MagicalRecordStack;

typedef void (^ LogHandlerBlock)(id _self, id object, NSString * format, va_list args);

@interface MagicalRecord (MSKitAdditions)


+ (MagicalRecordStack *)
    setupAutoMigratingCoreDataStackWithSqliteStoreNamed:(NSString *)storeName
                                                  model:(NSManagedObjectModel *)model;


+ (void)performLogForObject:(id)object message:(NSString *)format args:(va_list)args;

+ (void)performLogForObject:(id)object message:(NSString *)format, ... __attribute__ ((format (__NSString__, 2, 3)));

+ (BOOL)setLogHandler:(LogHandlerBlock)handler;

+ (void)handleErrors:(NSError *)error;

- (void)handleErrors:(NSError *)error;

+ (void)setErrorHandlerTarget:(id)target action:(SEL)action;

+ (SEL)errorHandlerAction;

+ (id)errorHandlerTarget;

@end
