//
// CommandSetCollection.h
// iPhonto
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CommandContainer.h"

@class   CommandSet;

@interface CommandSetCollection : CommandContainer {
    @private
}
@property (nonatomic, strong) NSMutableDictionary * commandSets;

+ (CommandSetCollection *)newCommandSetCollectionInContext:(NSManagedObjectContext *)context;
- (void)addCommandSet:(CommandSet *)commandSet;

@end
