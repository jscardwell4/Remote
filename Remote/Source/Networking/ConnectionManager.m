//
// ConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "ConnectionManager_Private.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Variables, Externs
////////////////////////////////////////////////////////////////////////////////

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_NETWORKING|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

static const ConnectionManager * connectionManager = nil;

MSSTRING_CONST   CMDevicesUserDefaultsKey         = @"CMDevicesUserDefaultsKey";
MSSTRING_CONST   CMNetworkDeviceKey               = @"CMNetworkDeviceKey";
MSSTRING_CONST   CMConnectionStatusNotification   = @"CMConnectionStatusNotification";
MSSTRING_CONST   CMConnectionStatusWifiAvailable  = @"CMConnectionStatusWifiAvailable";
MSSTRING_CONST   CMCommandDidCompleteNotification = @"CMCommandDidCompleteNotification";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ConnectionManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation ConnectionManager

+ (void)initialize
{
    if (self == [ConnectionManager class])
    {
        if (![self connectionManager])
            MSLogErrorTag(@"something went horribly wrong!");
    }
}

+ (const ConnectionManager *)connectionManager
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        connectionManager = [self new];

        // initialize settings
        connectionManager->_flags.autoConnect = [SettingsManager boolForSetting:MSSettingsAutoConnectKey];
        connectionManager->_flags.simulateCommandSuccess = [UserDefaults boolForKey:@"simulate"];
        connectionManager->_flags.autoListen = [SettingsManager boolForSetting:MSSettingsAutoListenKey];

        // initialize reachability
        connectionManager->_reachability =
        [MSNetworkReachability
         reachabilityWithCallback:
         ^(SCNetworkReachabilityFlags flags)
         {
             BOOL wifi = (   (flags & kSCNetworkReachabilityFlagsIsDirect)
                          && (flags & kSCNetworkReachabilityFlagsReachable));

             connectionManager->_flags.wifiAvailable = wifi;

             [NotificationCenter
              postNotificationName:CMConnectionStatusNotification
              object:self
              userInfo:@{ CMConnectionStatusWifiAvailable : @(wifi) }];
         }];

        // get initial reachability status and try connecting to the default device
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC),
                       dispatch_get_main_queue(),
                       ^{
                           [connectionManager->_reachability refreshFlags];
                           if (connectionManager->_flags.autoConnect)
                           {
                               if (![GlobalCacheConnectionManager connectWithDevice:nil])
                               {
                                   MSLogDebugTag(@"(autoConnect|autoListen) connect failed");
                                   if (connectionManager->_flags.autoListen)
                                       [GlobalCacheConnectionManager detectNetworkDevices];
                               }

                               else MSLogDebugTag(@"(autoConnect) default device connected");
                           }
                       });
    });
    return connectionManager;
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    BOOL isResolved = NO;

    Method instanceMethod = class_getInstanceMethod(self, sel);
    if (!instanceMethod) return [super resolveClassMethod:sel];

    // how many arguments does it take?
    unsigned numberOfArgs = method_getNumberOfArguments(instanceMethod);

        // get type encodings
    const char * typeEncodings = method_getTypeEncoding(instanceMethod);
    switch (typeEncodings[0]) {
        case 'c':
        {
            assert(numberOfArgs == 2);
            BOOL (*instanceImp)(id,SEL);
            instanceImp = (BOOL (*)(id,SEL))method_getImplementation(instanceMethod);
            IMP classImp = imp_implementationWithBlock(^(id _self) {
                return instanceImp([ConnectionManager connectionManager], sel);
            });
            isResolved = class_addMethod(objc_getMetaClass("ConnectionManager"),
                                         sel,
                                         classImp,
                                         typeEncodings);
        } break;

        case 'B':
        case 'v':
        {
            if (numberOfArgs == 2)
            {
                void (*instanceImp)(id,SEL);
                instanceImp = (void (*)(id,SEL))method_getImplementation(instanceMethod);
                IMP classImp = imp_implementationWithBlock(^(id _self) {
                    instanceImp([ConnectionManager connectionManager], sel);
                });
                isResolved = class_addMethod(objc_getMetaClass("ConnectionManager"),
                                             sel,
                                             classImp,
                                             typeEncodings);
            }

            else
            {
                assert(numberOfArgs == 4);
                void (*instanceImp)(id,SEL,id,id);
                instanceImp = (void (*)(id,SEL,id,id))method_getImplementation(instanceMethod);
                IMP classImp = imp_implementationWithBlock(^(id _self, id arg1, id arg2) {
                    instanceImp([ConnectionManager connectionManager], sel, arg1, arg2);
                });
                isResolved = class_addMethod(objc_getMetaClass("ConnectionManager"),
                                             sel,
                                             classImp,
                                             typeEncodings);
            }
        } break;

        default:
            assert(NO);
            break;
    }

    return isResolved;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending commands
////////////////////////////////////////////////////////////////////////////////


+ (void)sendCommand:(NSManagedObjectID *)commandID completion:(void (^)(BOOL success, NSError *))completion {
    [connectionManager sendCommand:commandID completion:completion];
}
- (void)sendCommand:(NSManagedObjectID *)commandID completion:(void (^)(BOOL success, NSError *))completion
{
    if (!(_flags.wifiAvailable || _flags.simulateCommandSuccess )) { MSLogWarnTag(@"wifi not available"); return; }


    BOOL   success = NO, finished = NO;
    NSManagedObject * command = [[CoreDataManager defaultContext] existingObjectWithID:commandID
                                                                                 error:nil];

    if ([command isKindOfClass:[SendIRCommand class]])
    {
        static NSUInteger nextTag = 0;
        SendIRCommand * sendIRCommand = (SendIRCommand *)command;
        NSString * cmd = sendIRCommand.commandString;
        MSLogDebugTag(@"sendIRCommand:%@", [sendIRCommand shortDescription]);

        if (StringIsEmpty(cmd))
        {
            MSLogWarnTag(@"cannot send empty or nil command");
            if (completion) completion(YES, NO);
        }

        else
        {
            NSUInteger tag = (++nextTag%100) + 1;
            if (_flags.simulateCommandSuccess && completion)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(),
                               ^(void){ completion(YES, nil); });
            }
            
            else [GlobalCacheConnectionManager sendCommand:cmd
                                                       tag:tag
                                                    device:nil
                                                completion:completion];
        }
    }

    else if ([command isKindOfClass:[HTTPCommand class]])
    {
        NSURL * url = ((HTTPCommand*)command).url;

        if (StringIsEmpty([url absoluteString])) MSLogWarnTag(@"cannot send empty or nil command");

        else
        {
            MSLogDebugTag(@"sending URL command:%@", command);

            if (_flags.simulateCommandSuccess) { success = YES; finished = YES; }

            else
            {
                NSURLRequest * request = [NSURLRequest requestWithURL:url];
                success  = ([NSURLConnection connectionWithRequest:request delegate:nil] != nil);
                finished = YES;
            }
        }

        if (completion) completion(finished, nil);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reachability
////////////////////////////////////////////////////////////////////////////////

+ (BOOL)isWifiAvailable { return [connectionManager isWifiAvailable]; }
- (BOOL)isWifiAvailable { return _flags.wifiAvailable; }

///////////////////////////////////////////////////////////////////////////////
#pragma mark - Logging
////////////////////////////////////////////////////////////////////////////////

+ (void)logStatus { [connectionManager logStatus]; }
- (void)logStatus { MSLogInfoTag(@"%@", [GlobalCacheConnectionManager statusDescription]); }

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

@end
