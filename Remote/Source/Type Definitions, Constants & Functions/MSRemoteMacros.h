//
// RemoteMacros.h
// Remote
//
// Created by Jason Cardwell on 6/13/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"

#define DefaultDDLogLevel LOG_LEVEL_WARN

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Extending MSKit's Lumberjack Extensions
////////////////////////////////////////////////////////////////////////////////


// contexts
#define LOG_CONTEXT_EDITOR        0b00000000000100000
#define LOG_CONTEXT_PAINTER       0b00000000001000000
#define LOG_CONTEXT_NETWORKING    0b00000000010000000
#define LOG_CONTEXT_REMOTE        0b00000000100000000
#define LOG_CONTEXT_COREDATA      0b00000001000000000
#define LOG_CONTEXT_UITESTING     0b00000010000000000
#define LOG_CONTEXT_CONSTRAINT    0b00000100000000000
#define LOG_CONTEXT_COMMAND       0b00001000000000000
#define LOG_CONTEXT_BUILDING      0b00010000000000000
#define LOG_CONTEXT_MAGICALRECORD 0b00100000000000000
#define LOG_CONTEXT_COREDATATESTS 0b01000000000000000
#define LOG_CONTEXT_IMPORT        0b10000000000000000

