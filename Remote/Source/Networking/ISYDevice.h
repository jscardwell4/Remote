//
//  ISYDevice.h
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "NetworkDevice.h"


MSEXTERN_STRING ISYDeviceMulticastGroupAddress;
MSEXTERN_STRING ISYDeviceMulticastGroupPort;

@interface ISYDevice : NetworkDevice

+ (void)deviceFromLocation:(NSString *)location
                   context:(NSManagedObjectContext *)moc
                completion:(void(^)(ISYDevice * device, NSError * error))completion;

@property (nonatomic, copy, readonly) NSString * modelNumber;
@property (nonatomic, copy, readonly) NSString * modelName;
@property (nonatomic, copy, readonly) NSString * modelDescription;
@property (nonatomic, copy, readonly) NSString * manufacturerURL;
@property (nonatomic, copy, readonly) NSString * manufacturer;
@property (nonatomic, copy, readonly) NSString * friendlyName;
@property (nonatomic, copy, readonly) NSString * deviceType;
@property (nonatomic, copy, readonly) NSString * presentationURL;
@property (nonatomic, copy, readonly) NSString * baseURL;

@end
