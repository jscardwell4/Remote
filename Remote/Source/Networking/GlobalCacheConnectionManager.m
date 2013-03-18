//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "GlobalCacheConnectionManager.h"
#import "ConnectionManager.h"
#import "ConnectionManager_Private.h"
#import "CoreDataManager.h"
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>
#include "networking.h"

#define IGNORE_SAVED_ITACH_DEVICES              NO
#define LEAVE_MULTICAST_ON_DISCOVERY            YES
#define AUTO_ASSIGN_DEFAULT_DEVICE_ON_DISCOVERY YES

// static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = NETWORKING_F;

// notifications
MSKIT_STRING_CONST   kiTachDeviceDiscoveryNotification = @"kiTachDeviceDiscoveryNotification";

// connection state bit settings
typedef NS_ENUM (UInt8, ConnectionState) {
    ConnectionStateWifiAvailable              = 1 << 0,
        ConnectionStateDefaultDevice          = 1 << 1,
        ConnectionStateMulticastGroup         = 1 << 2,
        ConnectionStateDefaultDeviceConnected = 1 << 3
} static connectionState                      = 0;

// static ConnectionState connectionState = 0;

@interface GlobalCacheMulticastConnection : NSObject
+ (GlobalCacheMulticastConnection *)multicastConnection;
- (BOOL)                            joinMulticastGroup;
- (void)                            leaveMulticastGroup;
@property (nonatomic, readonly) BOOL   isMemberOfMulticastGroup;
@end

@interface GlobalCacheDeviceConnection : NSObject
+ (GlobalCacheDeviceConnection *)connectionForDevice:(ITachDevice *)device;
- (GlobalCacheDeviceConnection *)initWithDevice:(ITachDevice *)iTachDevice;
- (BOOL)                         connect;
- (void)                         disconnect;
- (void)queueCommand:(NSString *)command;
@property (nonatomic, readonly) BOOL       isConnecting;
@property (nonatomic, readonly) BOOL       isConnected;
@property (nonatomic, readonly) NSString * deviceUUID;
@end

/*
 * @interface GlobalCacheConnectionManager ()
 *
 * - (void)deviceDiscoveredWithAttributes:(NSDictionary *)attributes;
 * - (void)receivedMulticastGroupMessage:(NSString *)message;
 * - (void)parseiTachReturnMessage:(NSString *)returnMessage;
 * - (void)deviceDisconnected:(NSString *)deviceUUID;
 * - (void)disconnectResources;
 * - (void)reconnectResources;
 *
 * @end
 *
 */
@implementation GlobalCacheConnectionManager {
    NSMutableDictionary            * _networkDevices;
    NSMutableDictionary            * _connectedDevices;
    NSString                       * _capturedCommand;
    GlobalCacheMulticastConnection * _multicastConnection;
    NSManagedObjectContext         * _context;
    @package
    NSOperationQueue * _operationQueue;
}

/**
 * Returns shared singleton instance
 */
+ (GlobalCacheConnectionManager *)sharedInstance {
    static dispatch_once_t   pred          = 0;
    __strong static id       _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = [[self alloc] init]; }

                  );

    return _sharedObject;
}

/**
 * Initialize ivars and establish necessary I/O resources
 */
- (id)init {
    if (self = [super init]) {
        _context = [DataManager newContext];
        assert(_context);

        if (!IGNORE_SAVED_ITACH_DEVICES) {
            self.defaultDeviceUUID = UserDefaults[kDefaultiTachDeviceKey];

            if (![ITachDevice networkDeviceExistsForUUID:self.defaultDeviceUUID]) {
                MSLogDebug(@"%@ removing default device setting without a backing model object", ClassTagSelectorString);
                self.defaultDeviceUUID               = nil;
                UserDefaults[kDefaultiTachDeviceKey] = nil;
            }
        }

        _operationQueue      = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"com.moondeerstudios.globalcache";
        _multicastConnection = [GlobalCacheMulticastConnection multicastConnection];
        _connectedDevices    = [NSMutableDictionary dictionaryWithCapacity:5];
        [NotificationCenter addObserverForName:kConnectionStatusNotification
                                        object:nil
                                         queue:nil
                                    usingBlock:^(NSNotification * note) {
                                        BOOL wifiAvailable = [[note userInfo][kConnectionStatusWifiAvailable] boolValue];
                                        connectionState = (wifiAvailable ? connectionState | ConnectionStateWifiAvailable : connectionState & ~ConnectionStateWifiAvailable);
                                        MSLogDebug(@"%@ received notification with connection status update: wifi? %@ connection state:%u",
                                        ClassTagSelectorString, BOOLString(wifiAvailable), connectionState);
                                    }

        ];

        NSArray * devices = [ITachDevice allDevicesInContext:_context];

        _networkDevices = (devices
                           ?[NSMutableDictionary dictionaryWithObjects:devices forKeys:[devices valueForKeyPath:@"uuid"]]
                           :[NSMutableDictionary dictionaryWithCapacity:5]);
                MSLogDebug(@"%@iTach devices retrieved from database:\n\t%@", ClassTagSelectorString, _networkDevices);

        [NotificationCenter addObserverForName:UIApplicationDidEnterBackgroundNotification
                                        object:[UIApplication sharedApplication]
                                         queue:nil
                                    usingBlock:^(NSNotification * note) {[self disconnectResources]; }

        ];
        [NotificationCenter addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:[UIApplication sharedApplication]
                                         queue:nil
                                    usingBlock:^(NSNotification * note) {[self reconnectResources]; }

        ];
    }

    return self;
}  /* init */

- (void)disconnectResources {
    if (connectionState & ConnectionStateMulticastGroup)
        // shutdown upd socket
        [_multicastConnection leaveMulticastGroup];

    for (GlobalCacheDeviceConnection * connection in[_connectedDevices allValues]) {
        // disconnect tcp socket
                MSLogDebug(@"%@ disconnecting device: %@", ClassTagSelectorString, connection.deviceUUID);
        [connection disconnect];
    }
}

- (void)reconnectResources {
    if (connectionState & ConnectionStateMulticastGroup)
        // shutdown upd socket
        [_multicastConnection joinMulticastGroup];

    for (GlobalCacheDeviceConnection * connection in[_connectedDevices allValues]) {
        // disconnect tcp socket
        [_operationQueue addOperationWithBlock:^{
                             BOOL success = [connection connect];
                             MSLogDebug(@"%@ %@ to device: %@", ClassTagSelectorString, success ? @"reconnected" : @"failed to reconnect", connection.deviceUUID);

                             if (success && [connection.deviceUUID
                             isEqualToString:self.defaultDeviceUUID]) connectionState |= ConnectionStateDefaultDeviceConnected;
                         }

        ];
    }
}

#pragma mark - Device Discovery

/**
 * Join multicast group for iTach device broadcasts
 */
- (BOOL)detectNetworkDevices {
    // Make sure we are connected to wifi
    if (!connectionState & ConnectionStateWifiAvailable) {
        MSLogWarn(@"%@ cannot detect network devices without valid wifi connection", ClassTagSelectorString);

        return NO;
    }

    if (connectionState & ConnectionStateMulticastGroup) {
        MSLogWarn(@"%@ multicast socket already exists", ClassTagSelectorString);

        return YES;
    }

    [_operationQueue addOperationWithBlock:^{
                         if (![_multicastConnection joinMulticastGroup]) MSLogError(@"%@ failed to join multicast group", ClassTagSelectorString);
                         else connectionState |= ConnectionStateMulticastGroup;
                     }

    ];

    return YES;
}

/**
 * Close/cancel device discovery related resources
 */
- (void)stopNetworkDeviceDetection {
    [_operationQueue addOperationWithBlock:^{
                         [_multicastConnection leaveMulticastGroup];
                         connectionState &= ~ConnectionStateMulticastGroup;
                     }

    ];
}

/**
 * Parse the message broadcast by an iTach device to obtain its attributes
 */
- (void)receivedMulticastGroupMessage:(NSString *)message {
    MSLogDebug(@"%@ message:%@", ClassTagSelectorString, message);

    if (StringIsEmpty(message)) return;

    NSArray * stringSegments = [[message stringByReplacingOccurrencesOfString:@"http://"
                                                                   withString:@""]
                                substringsByMatchingOccurrencesOfRegEx:@"(?<=<-)(.*?)(?=>)"];
    NSMutableDictionary * attributeDictionary =
        [NSMutableDictionary dictionaryWithCapacity:[stringSegments count]];

    for (NSString * stringSegment in stringSegments) {
        // Split string using '=' and enter key=value pair in dictionary
        NSArray * keyValuePair = [stringSegment componentsSeparatedByString:@"="];

        if ([keyValuePair count] == 2) attributeDictionary[keyValuePair[0]] = [keyValuePair lastObject];
    }

    attributeDictionary[kNetworkDeviceTypeKey] = @(iTachNetworkDeviceType);

    MSLogDebug(@"%@ parsed message:\n%@\n", ClassTagSelectorString, attributeDictionary);
    [self deviceDiscoveredWithAttributes:attributeDictionary];
}

/**
 * Store discovered device and post notification
 */
- (void)deviceDiscoveredWithAttributes:(NSDictionary *)attributes {
    assert(attributes);

    NSString * uuid = attributes[kiTachDeviceUUID];

    assert(uuid);

    if (_networkDevices[uuid]) {
        MSLogDebug(@"%@ device with attributes already discovered:\n%@\n", ClassTagSelectorString, attributes);

        return;
    }

    assert(_context);

    ITachDevice * device = [ITachDevice iTachDeviceWithAttributes:attributes context:_context];

    assert(device);
    [_context performBlockAndWait:^{
                  [_context save:nil];
              }

    ];
    _networkDevices[uuid] = device;
    MSLogDebug(@"%@ added device with uuid %@ to known devices",        ClassTagSelectorString, uuid);

    MSLogDebug(@"%@ posting notification for new device with UUID: %@", ClassTagSelectorString, uuid);
    [NotificationCenter postNotificationName:kiTachDeviceDiscoveryNotification
                                      object:self
                                    userInfo:@{kNetworkDeviceKey : attributes}
    ];

    if (AUTO_ASSIGN_DEFAULT_DEVICE_ON_DISCOVERY) self.defaultDeviceUUID = uuid;

    if (LEAVE_MULTICAST_ON_DISCOVERY) [self stopNetworkDeviceDetection];
}

/**
 * Returns whether socket is open to receive multicast group broadcast messages
 */
- (BOOL)isDetectingNetworkDevices {
    return (connectionState & ConnectionStateMulticastGroup);
}

#pragma mark - Default Device Connection

- (void)setDefaultDeviceUUID:(NSString *)defaultDeviceUUID {
    _defaultDeviceUUID                   = defaultDeviceUUID;
    UserDefaults[kDefaultiTachDeviceKey] = defaultDeviceUUID;
    connectionState                      = (defaultDeviceUUID ? connectionState | ConnectionStateDefaultDevice : connectionState & ~ConnectionStateDefaultDevice);
}

- (BOOL)connectWithDefaultDevice {
    if (!(connectionState & ConnectionStateDefaultDevice)) {
            MSLogWarn(@"%@ no default device registered, checking for known devices...",              ClassTagSelectorString);

        if (_networkDevices.count > 0) {
            MSLogWarn(@"%@ setting default device from known devices, this should be done elsewhere", ClassTagSelectorString);
            [self setDefaultDeviceUUID:[_networkDevices allKeys][0]];
        } else
            return NO;
    }

    [_operationQueue addOperationWithBlock:^{
                         [self connectWithDevice:self.defaultDeviceUUID];
                     }

    ];

    return YES;
}

/**
 * Returns whether a socket connection has been estabilished with the default device
 */
- (BOOL)isDefaultDeviceConnected {
    return (connectionState & ConnectionStateDefaultDeviceConnected);
}

/**
 * Attempts to connect with default device, if one has been set
 */
- (BOOL)connectWithDevice:(NSString *)deviceUUID {
    // Check wifi connection
    if (!(connectionState & ConnectionStateWifiAvailable)) {
        MSLogError(@"%@ wifi connection required", ClassTagSelectorString);

        return NO;
    }

    // Check device id
    if (StringIsEmpty(deviceUUID)) {
        MSLogWarn(@"%@ device uuid invalid", ClassTagSelectorString);

        return NO;
    }

    // Check for existing connection
    if (_connectedDevices[deviceUUID]) {
        MSLogWarn(@"%@ device connection already exists", ClassTagSelectorString);

        return YES;
    }

    // Add device uuid to set of connected devices and update state if default device
    ITachDevice * device = [ITachDevice iTachDeviceForUUID:deviceUUID context:[DataManager mainObjectContext]];

    if (!device) {
        MSLogError(@"%@ failed to retrieve device from database with uuid: %@", ClassTagSelectorString, deviceUUID);

        return NO;
    }

    GlobalCacheDeviceConnection * deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:device];

    assert(deviceConnection);

    [_operationQueue addOperationWithBlock:^{
                         if (![deviceConnection connect]) MSLogError(@"%@ connection failed for device with uuid: %@", ClassTagSelectorString, deviceUUID);

                         _connectedDevices[deviceUUID] = deviceConnection;

                         if ([deviceUUID isEqualToString:self.defaultDeviceUUID]) connectionState |= ConnectionStateDefaultDeviceConnected;
                     }

    ];

    // Return success
    return YES;
}  /* connectWithDevice */

- (void)deviceDisconnected:(NSString *)deviceUUID {
    if ([deviceUUID isEqualToString:self.defaultDeviceUUID]) connectionState &= ~ConnectionStateDefaultDeviceConnected;
}

- (void)connectionEstablished:(GlobalCacheDeviceConnection *)deviceConnection {
    assert(deviceConnection.isConnected);
    _connectedDevices[deviceConnection.deviceUUID] = deviceConnection;
}

/**
 * Attempts to send a message with the specified command to the default device, if connected
 */
- (BOOL)sendCommandToDefaultiTachDevice:(NSString *)command
                                withTag:(NSUInteger)tag {
    return [self sendCommand:command withTag:tag toDevice:self.defaultDeviceUUID];
}

- (BOOL)sendCommand:(NSString *)command withTag:(NSUInteger)tag toDevice:(NSString *)device {
    // check for command content
    if (StringIsEmpty(command)) {
            MSLogError(@"%@ cannot send nil command", ClassTagSelectorString);

        return NO;
    }

    // check current connection
    GlobalCacheDeviceConnection * deviceConnection = _connectedDevices[device];

    if (!deviceConnection) {
        // not found among connected devices, check known devices
        ITachDevice * iTachDevice = _networkDevices[device];

        if (!iTachDevice) {
            MSLogError(@"%@ failed to retrieve info for device:%@", ClassTagSelectorString, device);

            return NO;
        }

        deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:iTachDevice];
    }

    BOOL               alreadyConnected = deviceConnection.isConnected;
    NSBlockOperation * connectOp        = [NSBlockOperation blockOperationWithBlock:^{
                                                                if (![deviceConnection connect]) MSLogError(@"%@ failed to connect to device: %@", ClassTagSelectorString, device);
                                                            }

                                          ];

    if (!alreadyConnected) [_operationQueue addOperation:connectOp];

    NSBlockOperation * queueCommandOp = [NSBlockOperation blockOperationWithBlock:^{
                                                              // insert tag if appropriate
                                                              NSMutableString * validatedCommand = [command mutableCopy];

                                                              if ([validatedCommand hasPrefix:@"sendir"] && tag <= 65535) {
                                                              NSRange tagRange = [validatedCommand                                                   rangeOfRegEx:@"sendir,\\d:\\d,([^,]+),.*"
                                                                                                        capture:1];
                                                              [validatedCommand                                                   replaceCharactersInRange:tagRange
                                                                                              withString:[NSString stringWithFormat:@"%i", tag]];
                                                              }

                                                              // ensure proper line termination
                                                              if ([validatedCommand hasSuffix:@"\n"])
                                                              [validatedCommand                                                   replaceOccurrencesOfString:@"\n"
                                                                                                withString:@"\r"
                                                                                                   options:0
                                                                                                     range:NSMakeRange(0, validatedCommand.length)];
                                                              else if (![validatedCommand hasSuffix:@"\r"]) [validatedCommand appendString:@"\r"];

                                                              [validatedCommand appendFormat:@"<tag>%u", tag];
                                                              // send command
                                                              MSLogDebug(@"%@ queueing command \"%@\"", ClassTagSelectorString, [validatedCommand                                                       stringByReplacingOccurrencesOfString:@"\r"
                                                                                                                                                                                                        withString:@"⏎"]);

                                                              [deviceConnection queueCommand:validatedCommand];
                                                          }

                                        ];

    if (!alreadyConnected) [queueCommandOp addDependency:connectOp];

    [_operationQueue addOperation:queueCommandOp];

    return YES;
}  /* sendCommand */

/**
 * Handles messages sent by device in response to our commands sent
 */
- (void)parseiTachReturnMessage:(NSString *)returnMessage {
    // iTach completeir command: completeir,<module address>:<connector address>,<ID>
    // TODO: handle error messages
    MSKIT_STATIC_STRING_CONST   kIREnabled  = @"IR Learner Enabled\r";
    MSKIT_STATIC_STRING_CONST   kIRDisabled = @"IR Learner Disabled\r";
    MSKIT_STATIC_STRING_CONST   kCompleteIR = @"completeir";
    MSKIT_STATIC_STRING_CONST   kSendIR     = @"sendir";
    MSKIT_STATIC_STRING_CONST   kError      = @"ERR";

        MSLogDebug(@"%@ Return message from device: \"%@\"", ClassTagSelectorString, returnMessage);

    // command success
    if ([returnMessage hasPrefix:kCompleteIR]) {
        NSString * tagString = [returnMessage substringFromIndex:15];

        [[ConnectionManager sharedConnectionManager] notifySenderForTag:@([tagString integerValue]) success:YES];
    }
    // error
    else if ([returnMessage hasPrefix:kError])
        [[ConnectionManager sharedConnectionManager] notifySenderForTag:@(-1) success:NO];
    // learner enabled
    else if ([kIREnabled isEqualToString:returnMessage]) {
        MSLogInfo(@"%@ IR Learner has been enabled on the iTach device", ClassTagSelectorString);
        [NotificationCenter postNotificationName:kLearnerStatusDidChangeNotification
                                          object:self
                                        userInfo:@{kLearnerStatusDidChangeNotification : @YES}
        ];
    }
    // learner disabled
    else if ([kIRDisabled isEqualToString:returnMessage]) {
        MSLogInfo(@"%@IR Learner has been disabled on the iTach device", ClassTagSelectorString);
        [NotificationCenter postNotificationName:kLearnerStatusDidChangeNotification
                                          object:self
                                        userInfo:@{kLearnerStatusDidChangeNotification : @NO}
        ];
    }
    // captured commands
    else if ([returnMessage hasPrefix:kSendIR])
        _capturedCommand = returnMessage;
    else if (ValueIsNotNil(_capturedCommand)) {
        _capturedCommand = [_capturedCommand stringByAppendingString:returnMessage];
        MSLogDebug(@"%@ capturedCommand = %@", ClassTagSelectorString, _capturedCommand);
        [NotificationCenter postNotificationName:kCommandCapturedNotification
                                          object:self
                                        userInfo:@{kCommandCapturedNotification : _capturedCommand}
        ];
    }
}  /* parseiTachReturnMessage */

- (NSString *)statusDescription {
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:4];

    if (connectionState & ConnectionStateMulticastGroup) [a addObject:@"ConnectionStateMulticastGroup"];

    if (connectionState & ConnectionStateDefaultDevice) [a addObject:@"ConnectionStateDefaultDevice"];

    if (connectionState & ConnectionStateDefaultDeviceConnected) [a addObject:@"ConnectionStateDefaultDeviceConnected"];

    if (connectionState & ConnectionStateWifiAvailable) [a addObject:@"ConnectionStateWifiAvailable"];

    NSMutableString * s = [NSMutableString stringWithFormat:@"{\n\tconnectionState:%@\n",
                           [a componentsJoinedByString:@"|"]];

    [s appendFormat:@"\tconnected devices:%@\n",
     [[[_connectedDevices keysOfEntriesPassingTest:^BOOL (id key, id obj, BOOL * stop) {
                    return [(GlobalCacheDeviceConnection *)obj isConnected];
                }

       ] allObjects] componentsJoinedByString:@", "]];
    [s appendFormat:@"\tknown devices:%@\n}\n", [[_networkDevices allKeys] componentsJoinedByString:@", "]];

    return s;
}

@end

@implementation GlobalCacheDeviceConnection {
    ITachDevice       * _device;
    dispatch_source_t   _tcpSourceRead;
    dispatch_source_t   _tcpSourceWrite;
    MSQueue           * _commandQueue;
    BOOL                _isConnecting;
}

+ (GlobalCacheDeviceConnection *)connectionForDevice:(ITachDevice *)device {
    return [[GlobalCacheDeviceConnection alloc] initWithDevice:device];
}

- (GlobalCacheDeviceConnection *)initWithDevice:(ITachDevice *)iTachDevice {
    if (self = [super init]) {
        _device       = iTachDevice;
        _commandQueue = [MSQueue queue];
    }

    return self;
}

- (NSString *)deviceUUID {
    return _device.uuid;
}

- (BOOL)connect {
    if (_isConnecting) {
        MSLogWarn(@"%@ already trying to connect", ClassTagSelectorString);

        return NO;
    } else
        _isConnecting = YES;

    assert(![NSThread isMainThread]);

    if (  (_tcpSourceRead && !dispatch_source_testcancel(_tcpSourceRead))
       || (_tcpSourceWrite && !dispatch_source_testcancel(_tcpSourceWrite)))
    {
        MSLogWarn(@"%@ already connected to device", ClassTagSelectorString);
        _isConnecting = NO;

        return NO;
    }

    assert(!_tcpSourceWrite && !_tcpSourceRead);

    dispatch_queue_t   queue = dispatch_queue_create("com.moondeerstudios.tcpQueue", DISPATCH_QUEUE_CONCURRENT);

    NSAssert(queue, @"%@ failed to create tcp queue", ClassTagSelectorString);

    // Get address info
    int               n;
    dispatch_fd_t     sockfd;
    struct addrinfo   hints, * res, * ressave;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((n = getaddrinfo([_device.configURL UTF8String], [kiTachDeviceTCPPort UTF8String], &hints, &res)) != 0) {
        MSLogError(@"%@error getting address info for %@, %@: %s",
                   ClassTagSelectorString, _device.configURL, kiTachDeviceTCPPort, gai_strerror(n));
        _isConnecting = NO;

        return NO;
    }

    ressave = res;

    // Create socket with address info
    do {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

        if (sockfd < 0) continue;                                        // ignore this one

        if (connect(sockfd, res->ai_addr, res->ai_addrlen) == 0) break;  // success

        close(sockfd);                                                   // ignore this one
    } while ((res = res->ai_next) != NULL);

    freeaddrinfo(ressave);

    if (res == NULL) {                                                   // errno set from final
                                                                         // connect()
        MSLogError(@"%@ error connecting to %@, %@",
                   ClassTagSelectorString, _device.configURL, kiTachDeviceTCPPort);
        _isConnecting = NO;

        return NO;
    }

    // Make socket non-blocking
    int   flags;

    if ((flags = fcntl(sockfd, F_GETFL, 0)) < 0) MSLogError(@"%@ error getting flags for tcp socket: %d - %s", ClassTagSelectorString, errno, strerror(errno));

    flags |= O_NONBLOCK;

    if (fcntl(sockfd, F_SETFL, flags) < 0) MSLogError(@"%@ error setting flags for tcp socket: %d - %s", ClassTagSelectorString, errno, strerror(errno));

    // Create dispatch source for socket
    _tcpSourceWrite = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, sockfd, 0, queue);
    assert(_tcpSourceWrite != nil);
    dispatch_source_set_event_handler(_tcpSourceWrite, ^{
        if ([_commandQueue isEmpty]) return;

        NSArray * cmdComponents = [[_commandQueue dequeue] componentsSeparatedByString:@"<tag>"];

        if (!cmdComponents) return;

        const char * msg = [cmdComponents[0] UTF8String];
        ssize_t bytesWritten = write(sockfd, msg, strlen(msg));

        if (bytesWritten < 0) MSLogError(@"%@ write failed for tcp socket", ClassTagSelectorString);
//        else MSLogDebug(@"%@ message sent to device:%s\n", ClassTagSelectorString, msg);
    }

                                      );
    dispatch_source_set_cancel_handler(_tcpSourceWrite, ^{
        MSLogDebug(@"%@ closing tcp socket...", ClassTagSelectorString);
        close(sockfd);
        _tcpSourceWrite = nil;
        _tcpSourceRead = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[GlobalCacheConnectionManager sharedInstance] deviceDisconnected:_device.uuid];
            }

                       );
    }

                                       );
    _tcpSourceRead = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, queue);
    assert(_tcpSourceRead != nil);

    dispatch_source_set_event_handler(_tcpSourceRead, ^{
        ssize_t bytesAvailable = dispatch_source_get_data(_tcpSourceRead);
        char msg[bytesAvailable + 1];
        ssize_t bytesRead = read(sockfd, msg, bytesAvailable);

        if (bytesRead < 0)
            MSLogError(@"%@ read failed for tcp socket", ClassTagSelectorString);
        else {
            msg[bytesAvailable] = '\0';
//            MSLogDebug(@"%@ message received from device:%s\n", ClassTagSelectorString, msg);
            NSArray * msgComponents = [@(msg)componentsSeparatedByString: @"\r"];

            for (NSString * msgComponent in msgComponents) {
                if (msgComponent.length) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [[GlobalCacheConnectionManager sharedInstance] parseiTachReturnMessage:msgComponent];
                        }

                                   );
                }
            }
        }
    }

                                      );
    dispatch_source_set_cancel_handler(_tcpSourceRead, ^{
        MSLogDebug(@"%@ closing tcp socket...", ClassTagSelectorString);
        close(sockfd);
        _tcpSourceWrite = nil;
        _tcpSourceRead = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[GlobalCacheConnectionManager sharedInstance] deviceDisconnected:_device.uuid];
            }

                       );
    }

                                       );

    // Start receiving events for dispatch sources
    dispatch_resume(_tcpSourceRead);
    dispatch_resume(_tcpSourceWrite);

    _isConnecting = NO;

    [[GlobalCacheConnectionManager sharedInstance] connectionEstablished:self];

    return YES;
}  /* connect */

- (void)disconnect {
    if (self.isConnected) dispatch_source_cancel(_tcpSourceRead);
}

- (void)queueCommand:(NSString *)command {
    [_commandQueue enqueue:[command copy]];
}

- (BOOL)isConnected {
    return (_tcpSourceRead && !dispatch_source_testcancel(_tcpSourceRead));
}

- (void)dealloc {
    [self disconnect];
}

@end

@implementation GlobalCacheMulticastConnection {
    __strong dispatch_source_t   multicastSource;
}

+ (GlobalCacheMulticastConnection *)multicastConnection {
    static dispatch_once_t                           pred          = 0;
    __strong static GlobalCacheMulticastConnection * _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = [[GlobalCacheMulticastConnection alloc] init]; }

                  );

    return _sharedObject;
}

- (BOOL)joinMulticastGroup {
    assert(![NSThread isMainThread]);

    if (multicastSource && !dispatch_source_testcancel(multicastSource)) {
        MSLogWarn(@"%@ multicast dispatch source already exists", ClassTagSelectorString);

        return NO;
    }

    assert(!multicastSource);

    dispatch_queue_t   queue = dispatch_queue_create("com.moondeerstudios.multicastGroupQueue",
                                                     DISPATCH_QUEUE_SERIAL);

    NSAssert(queue, @"%@ failed to create multicast group queue", ClassTagSelectorString);

    // Create a UDP socket for receiving the multicast group broadcast
    struct sockaddr * sa;
    socklen_t         salen;
    int               n;
    dispatch_fd_t     sockfd;
    struct addrinfo   hints, * res, * ressave;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if ((n = getaddrinfo([kiTachDeviceMulticastGroupAddress UTF8String],
                         [kiTachDeviceMulticastGroupPort UTF8String], &hints, &res)) != 0)
        MSLogError(@"%@ error getting address info for %@, %@: %s",
                   ClassTagSelectorString, kiTachDeviceMulticastGroupAddress,
                   kiTachDeviceMulticastGroupPort, gai_strerror(n));

    ressave = res;

    do {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

        if (sockfd >= 0) break;  // success
    } while ((res = res->ai_next) != NULL);

    if (res == NULL) {           // errno set from final socket()
        MSLogError(@"%@ error creating multicast socket for %@, %@",
                   ClassTagSelectorString, kiTachDeviceMulticastGroupAddress,
                   kiTachDeviceMulticastGroupPort);

        return NO;
    }

    sa = malloc(res->ai_addrlen);
    memcpy(sa, res->ai_addr, res->ai_addrlen);
    salen = res->ai_addrlen;
    freeaddrinfo(ressave);

    if (sockfd < 0) return NO;

    // Bind socket to multicast address info

    if (bind(sockfd, sa, salen) < 0) {
        MSLogError(@"%@ failed to bind multicast socket: %d - %s...closing socket", ClassTagSelectorString, errno, strerror(errno));
        close(sockfd);
        free(sa);

        return NO;
    }

    // Join multicast group

    switch (sa->sa_family) {
        case AF_INET : {
            struct ip_mreq   mreq;

            memcpy(&mreq.imr_multiaddr,
                   &((const struct sockaddr_in *)sa)->sin_addr,
                   sizeof(struct in_addr));
            mreq.imr_interface.s_addr = htonl(INADDR_ANY);
            n                         = setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
        }
        break;

        case AF_INET6 : {
            struct ipv6_mreq   mreq6;

            memcpy(&mreq6.ipv6mr_multiaddr,
                   &((const struct sockaddr_in6 *)sa)->sin6_addr,
                   sizeof(struct in6_addr));
            mreq6.ipv6mr_interface = 0;
            n                      = setsockopt(sockfd, IPPROTO_IPV6, IPV6_JOIN_GROUP, &mreq6, sizeof(mreq6));
        }
        break;
    }  /* switch */

    if (n < 0) {
        MSLogError(@"%@ failed to join multicast group: %d - %s...closing socket", ClassTagSelectorString, errno, strerror(errno));
        close(sockfd);
        free(sa);

        return NO;
    }

    // Create dispatch source with multicast socket
    multicastSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, queue);
    assert(multicastSource != nil);
    dispatch_source_set_event_handler(multicastSource, ^{
        ssize_t bytesAvailable = dispatch_source_get_data(multicastSource);
        char msg[bytesAvailable + 1];
        ssize_t bytesRead = read(sockfd, msg, bytesAvailable);

        if (bytesRead < 0) {
            MSLogError(@"%@ read failed for multicast socket", ClassTagSelectorString);
            dispatch_source_cancel(multicastSource);
        } else {
            msg[bytesAvailable] = '\0';
            NSString * message = @(msg);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[GlobalCacheConnectionManager sharedInstance] receivedMulticastGroupMessage:message];
                }

                           );
        }
    }

                                      );
    dispatch_source_set_cancel_handler(multicastSource, ^{
        MSLogDebug(@"%@(multicastSource cancel handler)\tclosing multicast socket...", ClassTagSelectorString);
        close(dispatch_source_get_handle(multicastSource));
        multicastSource = nil;
    }

                                       );
    dispatch_resume(multicastSource);
    free(sa);

    return YES;
}  /* joinMulticastGroup */

- (BOOL)isMemberOfMulticastGroup {
    return multicastSource && !dispatch_source_testcancel(multicastSource);
}

- (void)leaveMulticastGroup {
    if (self.isMemberOfMulticastGroup) dispatch_source_cancel(multicastSource);
}

- (void)dealloc {
    [self leaveMulticastGroup];
}

@end
