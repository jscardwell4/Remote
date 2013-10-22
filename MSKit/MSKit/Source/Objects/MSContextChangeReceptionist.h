//
//  MSContextChangeReceptionist.h
//  MSKit
//
//  Created by Jason Cardwell on 3/11/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MSKitDefines.h"

@class MSContextChangeReceptionist;
typedef void (^ MSContextChangeHandler)(MSContextChangeReceptionist * receptionist,
                                        NSManagedObject             * object,
                                        NSNotification              * note);

typedef void (^ MSContextChangeObjectUpdateHandler)(MSContextChangeReceptionist * receptionist,
                                                     NSManagedObject             * object);

typedef void (^ MSContextChangeObjectDeleteHandler)(MSContextChangeReceptionist * receptionist,
                                                     NSManagedObject             * object);


@interface MSContextChangeReceptionist : NSObject

+ (MSContextChangeReceptionist *)receptionistForObject:(NSManagedObject *)object
                                      notificationName:(NSString *)name
                                                 queue:(NSOperationQueue *)queue
                                               handler:(MSContextChangeHandler)handler;

+ (MSContextChangeReceptionist *)receptionistForObject:(NSManagedObject *)object
                                      notificationName:(NSString *)name
                                                 queue:(NSOperationQueue *)queue
                                         updateHandler:(MSContextChangeObjectUpdateHandler)updateHandler
                                         deleteHandler:(MSContextChangeObjectDeleteHandler)deleteHandler;


@property (nonatomic, assign, getter = shouldIgnore) BOOL ignore;

@end

#define MSMakeContextChangeHandler(block)         \
    ^(MSContextChangeReceptionist * receptionist, \
      NSManagedObject             * object,       \
      NSNotification              * note)         \
    block

#define MSMakeContextChangeObjectUpdateHandler(block)   \
    ^(MSContextChangeReceptionist * receptionist, \
      NSManagedObject             * object)       \
    block

#define MSMakeContextChangeObjectDeleteHandler(block)   MSMakeContextChangeObjectUpdateHandler(block)