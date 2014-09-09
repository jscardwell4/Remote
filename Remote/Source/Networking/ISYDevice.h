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

@class ISYDeviceNode;

@interface ISYDevice : NetworkDevice

@property (nonatomic, copy,   readonly) NSString * modelNumber;
@property (nonatomic, copy,   readonly) NSString * modelName;
@property (nonatomic, copy,   readonly) NSString * modelDescription;
@property (nonatomic, copy,   readonly) NSString * manufacturerURL;
@property (nonatomic, copy,   readonly) NSString * manufacturer;
@property (nonatomic, copy,   readonly) NSString * friendlyName;
@property (nonatomic, copy,   readonly) NSString * deviceType;
@property (nonatomic, copy,   readonly) NSString * baseURL;
@property (nonatomic, strong, readonly) NSSet    * nodes;


@end


@interface ISYDeviceNode : NamedModelObject

@property (nonatomic, copy,   readonly) NSNumber  * flag;
@property (nonatomic, copy,   readonly) NSString  * address;
@property (nonatomic, copy,   readonly) NSString  * type;
@property (nonatomic, copy,   readonly) NSNumber  * enabled;
@property (nonatomic, copy,   readonly) NSString  * pnode;
@property (nonatomic, copy,   readonly) NSString  * propertyID;
@property (nonatomic, copy,   readonly) NSString  * propertyValue;
@property (nonatomic, copy,   readonly) NSString  * propertyUOM;
@property (nonatomic, copy,   readonly) NSString  * propertyFormatted;
@property (nonatomic, strong, readonly) ISYDevice * device;

@end

@interface ISYDeviceGroup : NamedModelObject

@property (nonatomic, copy,   readonly) NSNumber  * flag;
@property (nonatomic, copy,   readonly) NSString  * address;
@property (nonatomic, copy,   readonly) NSNumber  * family;
@property (nonatomic, strong, readonly) NSSet     * members;

@end