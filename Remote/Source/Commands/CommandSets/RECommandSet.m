//
// CommandSet.m
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer_Private.h"
#import "RECommand.h"
#import "BankObject.h"

static int   ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = REMOTE_F;
#pragma unused(ddLogLevel,msLogContext)

static const NSDictionary * kValidKeysets;

@implementation RECommandSet

@dynamic name, buttonGroup, commands;

+ (void)initialize
{
    if (self == [RECommandSet class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kValidKeysets =
            @{
                @(RECommandSetTypeDPad):
                    [@[REDPadUpButtonKey,
                       REDPadDownButtonKey,
                       REDPadLeftButtonKey,
                       REDPadRightButtonKey,
                       REDPadOkButtonKey] set],
                
                @(RECommandSetTypeNumberPad):
                    [@[REDigitZeroButtonKey,
                       REDigitOneButtonKey,
                       REDigitTwoButtonKey,
                       REDigitThreeButtonKey,
                       REDigitFourButtonKey,
                       REDigitFiveButtonKey,
                       REDigitSixButtonKey,
                       REDigitSevenButtonKey,
                       REDigitEightButtonKey,
                       REDigitNineButtonKey,
                       REAuxOneButtonKey,
                       REAuxTwoButtonKey] set],

                @(RECommandSetTypeRocker):
                    [@[RERockerButtonPlusButtonKey,
                       RERockerButtonMinusButtonKey] set],
                
                @(RECommandSetTypeTransport):
                    [@[RETransportRewindButtonKey,
                       RETransportRecordButtonKey,
                       RETransportNextButtonKey,
                       RETransportStopButtonKey,
                       RETransportFastForwardButtonKey,
                       RETransportPreviousButtonKey,
                       RETransportPauseButtonKey,
                       RETransportPlayButtonKey] set]
            };
        });
    }
}

+ (instancetype)commandSetWithType:(RECommandSetType)type
{
    RECommandSet * commandSet = [self MR_createEntity];
    commandSet.type = type;
    return commandSet;
}

+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(RECommandSetType)type
{
    __block RECommandSet * commandSet = nil;
    [context performBlockAndWait:
     ^{
         commandSet = [self commandContainerInContext:context];
         commandSet.type = type;
     }];
    return commandSet;
}

- (void)setObject:(RECommand *)command forKeyedSubscript:(NSString *)key
{
    if (kValidKeysets[self.primitiveType] && [kValidKeysets[self.primitiveType] containsObject:key])
    {
        NSMutableDictionary * index = [self.index mutableCopy];
        index[key] = [command permanentURI];
        self.index = [NSDictionary dictionaryWithDictionary:index];
    }
}

- (RECommand *)objectForKeyedSubscript:(NSString *)key
{
    return (RECommand *)([self isValidKey:key]
                         ? [self.managedObjectContext objectForURI:self.index[key]]
                         : nil);
}

- (RECommandSetType)type
{
    [self willAccessValueForKey:@"type"];
    RECommandSetType type = NSUIntegerValue(self.primitiveType);
    [self didAccessValueForKey:@"type"];
    return type;
}

- (void)setType:(RECommandSetType)type
{
    [self willChangeValueForKey:@"type"];
    self.primitiveType = @(type);
    [self didChangeValueForKey:@"type"];
}

@end

/// DPad keys
MSKIT_STRING_CONST   REDPadUpButtonKey               = @"REDPadUpButtonKey";
MSKIT_STRING_CONST   REDPadDownButtonKey             = @"REDPadDownButtonKey";
MSKIT_STRING_CONST   REDPadLeftButtonKey             = @"REDPadLeftButtonKey";
MSKIT_STRING_CONST   REDPadRightButtonKey            = @"REDPadRightButtonKey";
MSKIT_STRING_CONST   REDPadOkButtonKey               = @"REDPadOkButtonKey";

/// Numberpad keys
MSKIT_STRING_CONST   REDigitZeroButtonKey            = @"REDigitZeroButtonKey";
MSKIT_STRING_CONST   REDigitOneButtonKey             = @"REDigitOneButtonKey";
MSKIT_STRING_CONST   REDigitTwoButtonKey             = @"REDigitTwoButtonKey";
MSKIT_STRING_CONST   REDigitThreeButtonKey           = @"REDigitThreeButtonKey";
MSKIT_STRING_CONST   REDigitFourButtonKey            = @"REDigitFourButtonKey";
MSKIT_STRING_CONST   REDigitFiveButtonKey            = @"REDigitFiveButtonKey";
MSKIT_STRING_CONST   REDigitSixButtonKey             = @"REDigitSixButtonKey";
MSKIT_STRING_CONST   REDigitSevenButtonKey           = @"REDigitSevenButtonKey";
MSKIT_STRING_CONST   REDigitEightButtonKey           = @"REDigitEightButtonKey";
MSKIT_STRING_CONST   REDigitNineButtonKey            = @"REDigitNineButtonKey";
MSKIT_STRING_CONST   REAuxOneButtonKey               = @"REAuxOneButtonKey";
MSKIT_STRING_CONST   REAuxTwoButtonKey               = @"REAuxTwoButtonKey";

/// Rocker keys
MSKIT_STRING_CONST   RERockerButtonPlusButtonKey     = @"RERockerButtonPlusButtonKey";
MSKIT_STRING_CONST   RERockerButtonMinusButtonKey    = @"RERockerButtonMinusButtonKey";

/// Transport keys
MSKIT_STRING_CONST   RETransportRewindButtonKey      = @"RETransportRewindButtonKey";
MSKIT_STRING_CONST   RETransportRecordButtonKey      = @"RETransportRecordButtonKey";
MSKIT_STRING_CONST   RETransportNextButtonKey        = @"RETransportNextButtonKey";
MSKIT_STRING_CONST   RETransportStopButtonKey        = @"RETransportStopButtonKey";
MSKIT_STRING_CONST   RETransportFastForwardButtonKey = @"RETransportFastForwardButtonKey";
MSKIT_STRING_CONST   RETransportPreviousButtonKey    = @"RETransportPreviousButtonKey";
MSKIT_STRING_CONST   RETransportPauseButtonKey       = @"RETransportPauseButtonKey";
MSKIT_STRING_CONST   RETransportPlayButtonKey        = @"RETransportPlayButtonKey";
