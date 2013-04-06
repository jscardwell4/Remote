//
// ConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "ConnectionManager_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Variables, Externs
////////////////////////////////////////////////////////////////////////////////

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = NETWORKING_F_C;

MSKIT_STRING_CONST   CMDevicesUserDefaultsKey         = @"CMDevicesUserDefaultsKey";
MSKIT_STRING_CONST   CMNetworkDeviceKey               = @"CMNetworkDeviceKey";
MSKIT_STRING_CONST   CMConnectionStatusNotification   = @"CMConnectionStatusNotification";
MSKIT_STRING_CONST   CMConnectionStatusWifiAvailable  = @"CMConnectionStatusWifiAvailable";
MSKIT_STRING_CONST   CMCommandDidCompleteNotification = @"CMCommandDidCompleteNotification";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ConnectionManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation ConnectionManager

+ (ConnectionManager *)sharedConnectionManager
{
    static dispatch_once_t pred = 0;
    __strong static ConnectionManager * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [self new];
        
        // initialize settings
        _sharedObject->_flags.autoConnect = [SettingsManager boolForSetting:kAutoConnectKey];
        _sharedObject->_flags.simulateCommandSuccess = [UserDefaults boolForKey:@"simulate"];
        _sharedObject->_flags.autoListen = YES;

        // initialize reachability
        _sharedObject->_reachability =
            [MSNetworkReachability
             reachabilityWithCallback:
             ^(SCNetworkReachabilityFlags flags)
             {
                 BOOL wifi = (   (flags & kSCNetworkReachabilityFlagsIsDirect)
                              && (flags & kSCNetworkReachabilityFlagsReachable));

                 _sharedObject->_flags.wifiAvailable = wifi;

                 [NotificationCenter
                  postNotificationName:CMConnectionStatusNotification
                                object:_sharedObject
                              userInfo:@{ CMConnectionStatusWifiAvailable : @(wifi) }];
             }];

        // get initial reachability status and try connecting to the default device
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC),
                       dispatch_get_main_queue(),
                       ^{
                           [_sharedObject->_reachability refreshFlags];
                           if (_sharedObject->_flags.autoConnect)
                           {
                               if (![GCConnManager connectWithDevice:nil])
                               {
                                   MSLogDebugTag(@"(autoConnect|autoListen) connect failed");
                                   if (_sharedObject->_flags.autoListen)
                                       [GCConnManager detectNetworkDevices];
                               }
                               
                               else MSLogDebugTag(@"(autoConnect) default device connected");
                           }
                       });
    });
    
    return _sharedObject;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending commands
////////////////////////////////////////////////////////////////////////////////

- (void)sendCommand:(NSManagedObjectID *)commandID completion:(RECommandCompletionHandler)completion
{
    if (!_flags.wifiAvailable) { MSLogWarnTag(@"wifi not available"); return; }


    BOOL   success = NO, finished = NO;
    NSManagedObject * command = [[[CoreDataManager sharedManager] mainObjectContext] existingObjectWithID:commandID
                                                                                    error:nil];

    if ([command isKindOfClass:[RESendIRCommand class]])
    {
        static NSUInteger nextTag = 0;
        RESendIRCommand * sendIRCommand = (RESendIRCommand *)command;
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
                               ^(void){ completion(YES, YES); });
            }
            
            else [[GlobalCacheConnectionManager sharedInstance] sendCommand:cmd
                                                                        tag:tag
                                                                     device:nil
                                                                 completion:completion];
        }
    }

    else if ([command isKindOfClass:[REHTTPCommand class]])
    {
        NSURL * url = ((REHTTPCommand*)command).url;

        if (StringIsEmpty([url absoluteString])) MSLogWarnTag(@"cannot send empty or nil command");

        else
        {
            MSLogDebug(@"%@ sending URL command:%@", ClassTagSelectorString, command);

            if (_flags.simulateCommandSuccess) { success = YES; finished = YES; }

            else
            {
                NSURLRequest * request = [NSURLRequest requestWithURL:url];
                success  = ([NSURLConnection connectionWithRequest:request delegate:nil] != nil);
                finished = YES;
            }
        }

        if (completion) completion(finished, success);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reachability
////////////////////////////////////////////////////////////////////////////////

- (BOOL)isWifiAvailable { return _flags.wifiAvailable; }

///////////////////////////////////////////////////////////////////////////////
#pragma mark - Logging
////////////////////////////////////////////////////////////////////////////////

- (void)logStatus { MSLogInfo(@"%@ %@", ClassTagSelectorString, [GCConnManager statusDescription]); }

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

@end
