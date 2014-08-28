//
//  MSNotificationReceptionist.m
//  MSKit
//
//  Created by Jason Cardwell on 8/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import "MSNotificationReceptionist.h"
#import "MSKitMacros.h"

@interface MSNotificationReceptionist ()

@property (nonatomic, copy)   void (^handler) (MSNotificationReceptionist *, NSNotification *);
@property (nonatomic, copy)   void (^updateHandler) (MSNotificationReceptionist *);
@property (nonatomic, copy)   void (^deleteHandler) (MSNotificationReceptionist *);

@property (nonatomic, copy)   NSString          * notificationName;
@property (nonatomic, strong) NSOperationQueue  * queue;
@property (nonatomic, strong) id                  object;

@end

@implementation MSNotificationReceptionist

+ (MSNotificationReceptionist *)
receptionistForObject:(id)object
     notificationName:(NSString *)name
                queue:(NSOperationQueue *)queue
              handler:(void (^) (MSNotificationReceptionist *rec, NSNotification *note))handler
{
  if (!handler) ThrowInvalidNilArgument(handler);
  MSNotificationReceptionist * receptionist = [MSNotificationReceptionist new];
  receptionist.handler = handler;
  receptionist.updateHandler = nil;
  receptionist.deleteHandler = nil;
  receptionist.notificationName = name;
  receptionist.queue = queue;
  receptionist.object = object;

  __weak MSNotificationReceptionist * weakReceptionist = receptionist;

  [NotificationCenter addObserverForName:name
                                  object:object
                                   queue:queue
                              usingBlock:^(NSNotification *note) {
                                if (!weakReceptionist.ignore)
                                    weakReceptionist.handler(receptionist, note);
                              }];
  return receptionist;
}

- (void)dealloc { [NotificationCenter removeObserver:self name:self.notificationName object:self.object]; }

@end
