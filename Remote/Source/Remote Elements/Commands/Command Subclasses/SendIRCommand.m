//
// SendIR.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "IRCode.h"
#import "ComponentDevice.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation SendIRCommand

@dynamic code, portOverride;

- (void)updateCachedCode
{
    IRCode * code = self.code;
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

- (void)setCode:(IRCode *)code
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

- (void)setPortOverride:(int16_t)portOverride
{
    [self willChangeValueForKey:@"portOverride"];
    _portOverride = portOverride;
    [self didChangeValueForKey:@"portOverride"];
    __port = (_portOverride  ? : (self.code ? self.code.device.port : 0));
}

- (int16_t)portOverride
{
    [self willAccessValueForKey:@"portOverride"];
    int16_t portOverride = _portOverride;
    [self didAccessValueForKey:@"portOverride"];
    return portOverride;
}

- (ComponentDevice *)device { return self.primitiveCode.device; }

- (int16_t)port { return __port; }

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

+ (SendIRCommand *)commandWithIRCode:(IRCode *)code
{
    SendIRCommand * sendIR = [self commandInContext:code.managedObjectContext];
    sendIR.code = code;
    return sendIR;
}

- (NSString *)shortDescription {return $(@"SendIRCommand(%@)", __name);}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
    /*
         {
             "class": "sendir",
             "code.uuid": "A32C02D7-6CE0-46C0-8469-8F074C6D96E5" // Tools
         }
     */

    [super updateWithData:data];

    NSDictionary * code = data[@"code"];
    if (code) self.code = [IRCode importObjectFromData:code context:self.managedObjectContext];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];


    dictionary[@"code.uuid"] = CollectionSafe(self.code.commentedUUID);
    dictionary[@"portOverride"] = (self.portOverride ? @(self.portOverride) : NullObject);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

@end
