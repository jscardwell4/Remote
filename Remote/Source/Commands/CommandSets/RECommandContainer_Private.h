//
//  CommandContainer_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/26/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer.h"

@interface RECommandContainer ()

@property (nonatomic, strong) NSDictionary * index;

@end

@interface RECommandContainer (CoreDataGeneratedAccessors)

@property (nonatomic, strong)  NSDictionary * primitiveIndex;
@property (nonatomic, copy)    NSString     * primitiveUuid;

@end

@interface RECommandSet ()

@property (nonatomic, readwrite) RECommandSetType   type;
@property (nonatomic, strong)    NSSet            * commands;
@property (nonatomic, strong)    REButtonGroup    * buttonGroup;

@end

@interface RECommandSet (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSMutableSet  * primitiveCommands;
@property (nonatomic, strong) REButtonGroup * primitiveButtonGroup;
@property (nonatomic, strong) NSNumber      * primitiveType;

@end


@interface RECommandSetCollection (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSMutableOrderedSet * primitiveCommandSets;

@end
