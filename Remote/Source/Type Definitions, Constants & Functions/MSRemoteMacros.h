//
// RemoteMacros.h
// Remote
//
// Created by Jason Cardwell on 6/13/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#define DefaultDDLogLevel LOG_LEVEL_WARN

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Extending MSKit's Lumberjack Extensions 
////////////////////////////////////////////////////////////////////////////////


// contexts
#define LOG_CONTEXT_EDITOR        0b0000000000100000
#define LOG_CONTEXT_PAINTER       0b0000000001000000
#define LOG_CONTEXT_NETWORKING    0b0000000010000000
#define LOG_CONTEXT_REMOTE        0b0000000100000000
#define LOG_CONTEXT_COREDATA      0b0000001000000000
#define LOG_CONTEXT_UITESTING     0b0000010000000000
#define LOG_CONTEXT_CONSTRAINT    0b0000100000000000
#define LOG_CONTEXT_COMMAND       0b0001000000000000
#define LOG_CONTEXT_BUILDING      0b0010000000000000
#define LOG_CONTEXT_MAGICALRECORD 0b0100000000000000
#define LOG_CONTEXT_COREDATATESTS 0b1000000000000000

