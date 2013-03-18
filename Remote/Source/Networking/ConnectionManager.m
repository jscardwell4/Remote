//
// ConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ConnectionManager.h"
#import "ConnectionManager_Private.h"
#import "IRLearnerViewController.h"
#import "SettingsManager.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "GlobalCacheConnectionManager.h"
#import "MSRemoteAppController.h"

#define NSStringFromNetworkDeviceType(type) \
    (type == iTachNetworkDeviceType         \
     ? @"iTachNetworkDeviceType"            \
     : @"InsteonNetworkDeviceType")

// static int ddLogLevel = LOG_LEVEL_DEBUG;
static int ddLogLevel = DefaultDDLogLevel;
static int msLogContext = NETWORKING_F_C;


// device constants
MSKIT_STRING_CONST   kDefaultiTachDeviceKey = @"kDefaultiTachDeviceKey";

// other keys
MSKIT_STRING_CONST   kDevicesUserDefaultsKey = @"kDevicesUserDefaultsKey";
MSKIT_STRING_CONST   kNetworkDeviceTypeKey   = @"kNetworkDeviceTypeKey";
MSKIT_STRING_CONST   kNetworkDeviceKey       = @"kNetworkDeviceKey";

// notifications
MSKIT_STRING_CONST   kConnectionStatusNotification       = @"kConnectionStatusNotification";
MSKIT_STRING_CONST   kConnectionStatusWifiAvailable      = @"kConnectionStatusWifiAvailable";
MSKIT_STRING_CONST   kCommandDidCompleteNotification     = @"kCommandDidCompleteNotification";
MSKIT_STRING_CONST   kLearnerStatusDidChangeNotification = @"kLearnerStatusDidChangedNotification";
MSKIT_STRING_CONST   kCommandCapturedNotification        = @"kCommandCapturedNotification";

@interface ConnectionManager ()

- (NSUInteger)nextTag;

- (void)sendHTTPCommand:(NSString *)command
                withTag:(NSUInteger)tag
                 sender:(id <ConnectionManagerDelegate> )sender;

- (void)initializeReachability;
- (void)initializeConnections;

@end

@implementation ConnectionManager {
    SCNetworkReachabilityRef       wifiReachability;
    __strong dispatch_queue_t      reachabilityQueue;
    __strong NSMutableDictionary * requestLog;
    GlobalCacheConnectionManager * gcConnectionManager;

    struct {
        BOOL   autoConnect;
        BOOL   autoListen;
        BOOL   wifiAvailable;
        BOOL   learnerEnabled;
        BOOL   simulateCommandSuccess;
    }
    flags;
}

#pragma mark - Initialization

+ (ConnectionManager *)sharedConnectionManager {
    static dispatch_once_t   pred          = 0;
    __strong static id       _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = [[self alloc] init]; }

                  );

    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
        self->requestLog        = [NSMutableDictionary dictionary];
        self->flags.autoConnect = [SettingsManager boolForSetting:kAutoConnectKey];
        [NotificationCenter addObserverForName:MSSettingsManagerAutoConnectSettingDidChangeNotification
                                        object:[SettingsManager sharedSettingsManager]
                                         queue:nil
                                    usingBlock:^(NSNotification * note) {
                                        self->flags.autoConnect = [SettingsManager boolForSetting:kAutoConnectKey];
                                    }

        ];
        self->gcConnectionManager = [GlobalCacheConnectionManager sharedInstance];
        assert(self->gcConnectionManager != nil);

        self->flags.simulateCommandSuccess = [UserDefaults boolForKey:@"simulate"];
        self->flags.autoListen             = YES;

        [self initializeReachability];

        int64_t           delayInSeconds = 2.0;
        dispatch_time_t   popTime        = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            SCNetworkReachabilityFlags rflags;
            SCNetworkReachabilityGetFlags(self->wifiReachability, &rflags);
            NetworkReachabilityCallBack(self->wifiReachability, rflags, (__bridge void *)self);
            [self initializeConnections];
        }

                       );
    }

    return self;
}

/**
 * Creates SCNetworkReachabilityRef and its dispatch queue
 */
- (void)initializeReachability {
    SCNetworkReachabilityContext   context = {0, (__bridge void *)(self), NULL, NULL, NULL};

    assert(self->wifiReachability == NULL);

    struct sockaddr_in   addr;

    memset(&addr, 0, sizeof(addr));
    addr.sin_len           = sizeof(addr);
    addr.sin_family        = AF_INET;
    addr.sin_addr.s_addr   = htonl(IN_LINKLOCALNETNUM);
    self->wifiReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&addr);
    assert(self->wifiReachability != NULL);
    if (!SCNetworkReachabilitySetCallback(self->wifiReachability, NetworkReachabilityCallBack, &context))
        MSLogError(@"%@ failed to set callback for wifi reachability", ClassTagSelectorString);
    else {
        assert(self->reachabilityQueue == nil);
        self->reachabilityQueue = dispatch_queue_create("com.moondeerstudios.reachability", DISPATCH_QUEUE_SERIAL);
        assert(self->reachabilityQueue != nil);
        if (!(SCNetworkReachabilitySetDispatchQueue(self->wifiReachability, self->reachabilityQueue) == TRUE)) MSLogError(@"%@ failed reachability dispatch", ClassTagSelectorString);
        else MSLogDebug(@"%@ reachability object dispatched", ClassTagSelectorString);
    }
}

- (void)initializeConnections {
/*
 *  [NotificationCenter addObserverForName:kiTachDeviceDiscoveryNotification
 *                                  object:self->gcConnectionManager
 *                                   queue:nil
 *                              usingBlock:^(NSNotification *note) {
 *                                  NSDictionary * deviceAttrs = note.userInfo[kNetworkDeviceKey];
 *                                  assert(deviceAttrs != nil);
 *
 *                                  MSLogDebug(@"%@ notification received
 * with discovered device:\n%@\nstopping device discovery...",
 *                                               ClassTagSelectorString, deviceAttrs);
 *                              }
 *   ];
 *
 */
    if (self->flags.autoConnect) {
        // TODO:refine initialization
            MSLogDebug(@"%@ (autoConnect) trying to connect with default device...", ClassTagSelectorString);

        BOOL   success = [self->gcConnectionManager connectWithDefaultDevice];

        if (!success && flags.autoListen) {
            MSLogDebug(@"%@ (autoConnect|autoListen) connect failed, listening for devices...", ClassTagSelectorString);
            [self->gcConnectionManager detectNetworkDevices];
        } else
            MSLogDebug(@"%@ (autoConnect) default device connected",                            ClassTagSelectorString);
    }
}

#pragma mark - Logging

- (void)logStatus {
    // TODO: Implement meaningful logging code
    MSLogInfo(@"%@ %@", ClassTagSelectorString, [self->gcConnectionManager statusDescription]);
}

#pragma mark - Sending commands

- (NSUInteger)nextTag {
    static NSUInteger   nextTag = 0; // used when assigning tags to command requests

    if (++nextTag == 100) nextTag = 1;

    return nextTag;
}

- (NSUInteger)sendCommand:(NSString *)commandString
                   ofType:(ConnectionCommandType)type
                 toDevice:(NSString *)device {
    return [self sendCommand:commandString ofType:type toDevice:device sender:nil];
}

- (NSUInteger)sendCommand:(NSString *)commandString
                   ofType:(ConnectionCommandType)type
                 toDevice:(NSString *)device
                   sender:(id <ConnectionManagerDelegate> )sender {
    NSUInteger   commandTag = [self nextTag];

    if (self->flags.simulateCommandSuccess) {
        MSLogDebug(@"%@ simulating successful send command", ClassTagSelectorString);
        // save sender by tag
        if (ValueIsNotNil(sender)) [self->requestLog setObject:sender forKey:@(commandTag)];

        [self notifySenderForTag:@(commandTag) success:YES];
    } else if (type == IRConnectionCommandType) {
        if (!device) device = self->gcConnectionManager.defaultDeviceUUID;

        if (ValueIsNotNil(sender)) self->requestLog[@(commandTag)] = sender;

        [self->gcConnectionManager sendCommand:commandString withTag:commandTag toDevice:device];
    } else if (type == URLConnectionCommandType)
        [self sendHTTPCommand:commandString withTag:commandTag sender:sender];


    return commandTag;
}

- (void)sendHTTPCommand:(NSString *)command
                withTag:(NSUInteger)tag
                 sender:(id <ConnectionManagerDelegate> )sender {
    BOOL   success = NO;

    if (ValueIsNil(command))
        MSLogWarn(@"%@ can't set nil command!", ClassTagSelectorString);
    else if (!self->flags.wifiAvailable)
        MSLogWarn(@"%@ wifi not available",     ClassTagSelectorString);
    else {
        MSLogDebug(@"%@ sending URL command:%@", ClassTagSelectorString, command);

        NSURLConnection * connection;
        NSURL           * url;
        NSURLRequest    * request;

        url     = [NSURL URLWithString:command];
        request = [NSURLRequest requestWithURL:url];
        assert(ValueIsNotNil(request));
        connection = [NSURLConnection connectionWithRequest:request delegate:nil];
        success    = (ValueIsNotNil(connection));
    }

    // save sender by tag
    if (ValueIsNotNil(sender)) [self->requestLog setObject:sender forKey:@(tag)];

    if (success) MSLogDebug(@"%@ URL command sent", ClassTagSelectorString);
    else MSLogDebug(@"%@ failed to send URL command", ClassTagSelectorString);

    [self notifySenderForTag:@(tag) success:success];
}

/**
 * Called to inform delegate of the completion of a command's execution
 */
- (void)notifySenderForTag:(NSNumber *)tag success:(BOOL)success {
    id <ConnectionManagerDelegate>   sender = self->requestLog[tag];

    if (sender) {
        [sender commandWithTag:tag.unsignedIntegerValue didCompleteWithStatus:success];
        MSLogDebug(@"%@ notifying sender command with tag %@ completed %ssuccessfully", ClassTagSelectorString, tag, success ? "" : "un");
    }
}

#pragma mark - Reachability

- (BOOL)isWifiAvailable {
    return self->flags.wifiAvailable;
}

static BOOL wifiAvailabilityFromReachabilityFlags(SCNetworkReachabilityFlags flags) {
    return ((flags & kSCNetworkReachabilityFlagsIsDirect) && (flags & kSCNetworkReachabilityFlagsReachable));
}

static BOOL wifiAvailabilityFromReachabilityRef(SCNetworkReachabilityRef reachabilityRef) {
    SCNetworkReachabilityFlags   flags;

    SCNetworkReachabilityGetFlags(reachabilityRef, &flags);

    return wifiAvailabilityFromReachabilityFlags(flags);
}

/**
 * System Configuration Network Reachability Callback
 */
static void NetworkReachabilityCallBack(SCNetworkReachabilityRef   target,
                                        SCNetworkReachabilityFlags flags,
                                        void                     * info) {
    if (info != (__bridge void *)([ConnectionManager sharedConnectionManager])) {
        MSLogCError(@"<ConnectionManager NetworkReachabilityCallback>\n\t`info` != self.sharedConnectionManager");

        return;
    }

    if (target == [ConnectionManager sharedConnectionManager]->wifiReachability) {
        [ConnectionManager sharedConnectionManager]->flags.wifiAvailable = wifiAvailabilityFromReachabilityFlags(flags);
        [NotificationCenter postNotificationName:kConnectionStatusNotification
                                          object:[ConnectionManager sharedConnectionManager]
                                        userInfo:@{kConnectionStatusWifiAvailable : @([ConnectionManager sharedConnectionManager]->flags.wifiAvailable)}
        ];
    }
}

@end
