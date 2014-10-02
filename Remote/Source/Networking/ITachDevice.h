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
@import Lumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
//#import "NetworkDevice.h"

@interface ITachDevice : NetworkDevice

@property (nonatomic, copy, readonly) NSString * make;
@property (nonatomic, copy, readonly) NSString * model;
@property (nonatomic, copy, readonly) NSString * status;
@property (nonatomic, copy, readonly) NSString * configURL;
@property (nonatomic, copy, readonly) NSString * revision;
@property (nonatomic, copy, readonly) NSString * pcbPN;
@property (nonatomic, copy, readonly) NSString * pkgLevel;
@property (nonatomic, copy, readonly) NSString * sdkClass;

@end

