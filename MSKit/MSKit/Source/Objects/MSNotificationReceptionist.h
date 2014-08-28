//
//  MSNotificationReceptionist.h
//  MSKit
//
//  Created by Jason Cardwell on 8/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSNotificationReceptionist : NSObject

+ (MSNotificationReceptionist *)
receptionistForObject:(id)object
     notificationName:(NSString *)name
                queue:(NSOperationQueue *)queue
              handler:(void (^) (MSNotificationReceptionist *rec, NSNotification *note))handler;

@property (nonatomic, assign, getter = shouldIgnore) BOOL ignore;


@end
