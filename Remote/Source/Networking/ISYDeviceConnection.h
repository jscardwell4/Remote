//
//  ISYDeviceConnection.h
//  Remote
//
//  Created by Jason Cardwell on 9/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

@import Foundation;
#import "MSKit/MSKit.h"
#import "Lumberjack/Lumberjack.h"

@class ISYDevice;

@interface ISYDeviceConnection : NSObject

/// connectionForDevice:
/// @param device description
/// @return instancetype
+ (instancetype)connectionForDevice:(ISYDevice *)device;

@property (nonatomic, strong, readonly) ISYDevice * device;

@end
