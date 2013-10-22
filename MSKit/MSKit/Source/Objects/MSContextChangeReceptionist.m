//
//  MSContextChangeReceptionist.m
//  MSKit
//
//  Created by Jason Cardwell on 3/11/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSContextChangeReceptionist.h"
#import "MSKitMacros.h"

@interface MSContextChangeReceptionist ()
@property (nonatomic, copy)   MSContextChangeHandler               handler;
@property (nonatomic, copy)   MSContextChangeObjectUpdateHandler   updateHandler;
@property (nonatomic, copy)   MSContextChangeObjectDeleteHandler   deleteHandler;
@property (nonatomic, copy)   NSString                           * notificationName;
@property (nonatomic, strong) NSOperationQueue                   * queue;
@property (nonatomic, strong) NSManagedObject                    * object;

@end

@implementation MSContextChangeReceptionist

+ (MSContextChangeReceptionist *)receptionistForObject:(NSManagedObject *)object
                                      notificationName:(NSString *)name
                                                 queue:(NSOperationQueue *)queue
                                               handler:(MSContextChangeHandler)handler
{
    if (!object || !object.managedObjectContext || !handler) return nil;
    MSContextChangeReceptionist * receptionist = [MSContextChangeReceptionist new];
    receptionist.handler = handler;
    receptionist.updateHandler = nil;
    receptionist.deleteHandler = nil;
    receptionist.notificationName = name;
    receptionist.queue = queue;
    receptionist.object = object;

    __weak MSContextChangeReceptionist * weakReceptionist = receptionist;

    [NotificationCenter addObserverForName:name
                                    object:object.managedObjectContext
                                     queue:queue
                                usingBlock:^(NSNotification *note) {
                                    if (!weakReceptionist.ignore)
                                        [weakReceptionist.object.managedObjectContext performBlockAndWait:^{
                                            weakReceptionist.handler(receptionist,
                                                                   weakReceptionist.object, note);
                                        }];
                                }];
    return receptionist;
}

+ (MSContextChangeReceptionist *)receptionistForObject:(NSManagedObject *)object
                                      notificationName:(NSString *)name
                                                 queue:(NSOperationQueue *)queue
                                         updateHandler:(MSContextChangeObjectUpdateHandler)updateHandler
                                         deleteHandler:(MSContextChangeObjectDeleteHandler)deleteHandler
{
    if (!object || !object.managedObjectContext || !(updateHandler || deleteHandler)) return nil;
    MSContextChangeReceptionist * receptionist = [MSContextChangeReceptionist new];
    receptionist.handler = nil;
    receptionist.updateHandler = updateHandler;
    receptionist.deleteHandler = deleteHandler;
    receptionist.notificationName = name;
    receptionist.queue = queue;
    receptionist.object = object;

    __weak MSContextChangeReceptionist * weakReceptionist = receptionist;

    [NotificationCenter addObserverForName:name
                                    object:object.managedObjectContext
                                     queue:queue
                                usingBlock:^(NSNotification *note) {
                                    if (!weakReceptionist.ignore)
                                    {
                                        if (   weakReceptionist.updateHandler
                                            && [note.userInfo[NSUpdatedObjectsKey]
                                                containsObject:weakReceptionist.object]
                                            && [[weakReceptionist.object changedValues] count])
                                            [weakReceptionist.object.managedObjectContext performBlockAndWait:^{
                                                weakReceptionist.updateHandler(receptionist,
                                                                             weakReceptionist.object);
                                            }];

                                        if (   weakReceptionist.deleteHandler
                                            && [note.userInfo[NSDeletedObjectsKey]
                                                containsObject:weakReceptionist.object])
                                            [weakReceptionist.object.managedObjectContext performBlockAndWait:^{
                                                weakReceptionist.deleteHandler(receptionist,
                                                                             weakReceptionist.object);
                                            }];
                                    }

                                }];

    return receptionist;
}

- (void)dealloc {
    [NotificationCenter removeObserver:self
                                  name:_notificationName
                                object:_object.managedObjectContext];
}

@end
