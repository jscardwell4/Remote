//
// CommandContainer.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"
#import "NamedModelObject.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command Container
////////////////////////////////////////////////////////////////////////////////

@interface CommandContainer : NamedModelObject

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, readonly) NSUInteger count;

@end

#import "RETypedefs.h"
