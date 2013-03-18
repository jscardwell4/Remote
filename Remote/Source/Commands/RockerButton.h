//
// RockerButton.h
// Remote
//
// Created by Jason Cardwell on 6/25/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CommandSet.h"

MSKIT_EXTERN_STRING   kRockerButtonPlusButtonKey;
MSKIT_EXTERN_STRING   kRockerButtonMinusButtonKey;

@interface RockerButton : CommandSet {
    @private
}
@property (nonatomic, strong) NSURL * plus;
@property (nonatomic, strong) NSURL * minus;

+ (RockerButton *)newRockerButtonInContext:(NSManagedObjectContext *)context;

@end
