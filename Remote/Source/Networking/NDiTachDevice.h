//
//  NDiTachDevice.h
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

// constants
MSEXTERN_STRING NDiTachDeviceMulticastGroupAddress;
MSEXTERN_STRING NDiTachDeviceMulticastGroupPort;
MSEXTERN_STRING NDiTachDeviceTCPPort;

// keys
MSEXTERN_KEY(NDiTachDevicePCB);
MSEXTERN_KEY(NDiTachDevicePkg);
MSEXTERN_KEY(NDiTachDeviceSDK);
MSEXTERN_KEY(NDiTachDeviceMake);
MSEXTERN_KEY(NDiTachDeviceModel);
MSEXTERN_KEY(NDiTachDeviceRevision);
MSEXTERN_KEY(NDiTachDeviceStatus);
MSEXTERN_KEY(NDiTachDeviceConfigURL);
MSEXTERN_KEY(NDiTachDeviceUniqueIdentifier);

@interface NDiTachDevice : NetworkDevice

@property (nonatomic, copy, readonly) NSString * make;
@property (nonatomic, copy, readonly) NSString * model;
@property (nonatomic, copy, readonly) NSString * status;
@property (nonatomic, copy, readonly) NSString * configURL;
@property (nonatomic, copy, readonly) NSString * revision;
@property (nonatomic, copy, readonly) NSString * pcb_pn;
@property (nonatomic, copy, readonly) NSString * pkg_level;
@property (nonatomic, copy, readonly) NSString * sdkClass;

@end

