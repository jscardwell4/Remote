//
//  REBuilder.m
//  Remote
//
//  Created by Jason Cardwell on 3/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = CONSOLE_LOG_CONTEXT;
#pragma unused(ddLogLevel, msLogContext)


@implementation REBuilder

+ (instancetype)builderWithContext:(NSManagedObjectContext *)context
{
    REBuilder * builder = [self new];
    builder.buildContext = context;
    MSLogDebugTag(@"build context:<%@:%p>", builder->_buildContext.nametag, builder->_buildContext);
    return builder;
}

@end
