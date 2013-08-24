//
// SendIR.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "BOIRCode.h"
#import "BOComponentDevice.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation RESendIRCommand

@dynamic code, portOverride;

- (void)updateCachedCode
{
    BOIRCode * code = self.code;
    if (code)
    {
        __port        = (self.portOverride ? _portOverride : code.device.port);
        __offset      = code.offset;
        __frequency   = code.frequency;
        __repeatCount = code.repeatCount;
        __pattern     = code.onOffPattern;
        __name        = code.name;
    }
}

- (void)clearCachedCode
{
    __port        = self.portOverride;
    __offset      = 0;
    __frequency   = 0;
    __repeatCount = 0;
    __pattern     = nil;
    __name        = nil;
}

- (void)setCode:(BOIRCode *)code
{
    [self willChangeValueForKey:@"code"];
    self.primitiveCode = code;
    [self didChangeValueForKey:@"code"];
    [self updateCachedCode];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    if (self.code) [self updateCachedCode];
    else [self clearCachedCode];
}

- (void)setPortOverride:(BODevicePort)portOverride
{
    [self willChangeValueForKey:@"portOverride"];
    _portOverride = portOverride;
    [self didChangeValueForKey:@"portOverride"];
    __port = (_portOverride  ? : (self.code ? self.code.device.port : 0));
}

- (BODevicePort)portOverride
{
    [self willAccessValueForKey:@"portOverride"];
    BODevicePort portOverride = _portOverride;
    [self didAccessValueForKey:@"portOverride"];
    return portOverride;
}

- (BOComponentDevice *)device { return self.primitiveCode.device; }

- (BODevicePort)port { return __port; }

- (int16_t)offset { return __offset; }

- (int16_t)repeatCount { return __repeatCount; }

- (int64_t)frequency { return __frequency; }

- (NSString *)pattern { return __pattern; }

- (NSString *)name { return __name; }

- (NSString *)commandString
{
    return $(@"sendir,1:%i,<tag>,%lld,%i,%i,%@\r",
             __port,
             __frequency,
             __repeatCount,
             __offset,
             __pattern);
}

+ (RESendIRCommand *)commandWithIRCode:(BOIRCode *)code
{
    RESendIRCommand * sendIR = [self commandInContext:code.managedObjectContext];
    sendIR.code = code;
    return sendIR;
}

- (NSString *)shortDescription
{
    return $(@"SendIRCommand(%@)",//:'%@'",
             __name);//,
                     //[[self commandString] stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"]);
}

@end
