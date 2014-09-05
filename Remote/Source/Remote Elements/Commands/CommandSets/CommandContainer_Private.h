//
//  CommandContainer_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/26/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "CommandContainer.h"

@interface CommandContainer ()
//{
//@protected
//    MSDictionary * _index;
//}

@property (nonatomic, strong) MSDictionary * index;

@end

@interface CommandContainer (CoreDataGeneratedAccessors)

@property (nonatomic, strong)  MSDictionary * primitiveIndex;

@end


#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "JSONObjectKeys.h"
