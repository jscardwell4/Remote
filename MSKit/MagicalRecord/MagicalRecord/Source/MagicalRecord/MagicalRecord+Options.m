//
//  MagicalRecord+Options.m
//  Magical Record
//
//  Created by Saul Mora on 3/6/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import "MagicalRecord+Options.h"
#import "MagicalRecordStack.h"

static MagicalRecordLogLevel magicalRecordLogLevel = MagicalRecordLogLevelVerbose;
static int magicalRecordLogContext = 0;

@implementation MagicalRecord (Options)

+ (MagicalRecordLogLevel) logLevel;
{
    return magicalRecordLogLevel;
}

+ (void) setLogLevel:(MagicalRecordLogLevel)logLevel;
{
    magicalRecordLogLevel = logLevel;
}

+ (int) logContext;
{
    return magicalRecordLogContext;
}

+ (void) setLogContext:(int)logContext
{
    magicalRecordLogContext = logContext;
}

+ (void)log:(BOOL)asynchronous
      level:(int)level
       flag:(int)flag
    context:(int)context
       file:(const char *)file
   function:(const char *)function
       line:(int)line
        tag:(id)tag
     format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

@end
