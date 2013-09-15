//
//  CommandContainer_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/26/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "CommandContainer.h"

@interface CommandContainer ()

@property (nonatomic, strong) NSDictionary * index;

@end

@interface CommandContainer (CoreDataGeneratedAccessors)

@property (nonatomic, strong)  NSDictionary * primitiveIndex;

@end

@interface CommandSet ()

@property (nonatomic, readwrite) RECommandSetType   type;
@property (nonatomic, strong)    NSSet            * commands;
@property (nonatomic, strong)    ButtonGroup    * buttonGroup;

@end

@interface CommandSet (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSMutableSet  * primitiveCommands;
@property (nonatomic, strong) ButtonGroup * primitiveButtonGroup;
@property (nonatomic, strong) NSNumber      * primitiveType;

@end


@interface CommandSetCollection (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSMutableOrderedSet * primitiveCommandSets;

@end
