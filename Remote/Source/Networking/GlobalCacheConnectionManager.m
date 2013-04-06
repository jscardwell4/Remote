//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheConnectionManager_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs and Class variables
////////////////////////////////////////////////////////////////////////////////

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = NETWORKING_F_C;
#pragma unused(ddLogLevel, msLogContext)

static NSMutableDictionary   * _requestLog;        /// Holds completion handlers for ongoing commands

MSKIT_STRING_CONST   NDiTachDeviceDiscoveryNotification = @"NDiTachDeviceDiscoveryNotification";
MSKIT_STRING_CONST   NDDefaultiTachDeviceKey             = @"NDDefaultiTachDeviceKey";

// connection state bit settings
typedef NS_ENUM (uint8_t, ConnectionState){
    ConnectionStateDefaultDevice          = 1 << 0,
    ConnectionStateMulticastGroup         = 1 << 1,
    ConnectionStateDefaultDeviceConnected = 1 << 2
} static kConnectionState                 = 0;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - GlobalCacheConnectionManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation GlobalCacheConnectionManager

+ (GlobalCacheConnectionManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static GlobalCacheConnectionManager * _sharedObject = nil;
    dispatch_once(&pred,
                  ^{
                      _sharedObject = [self new];

                      _requestLog = [@{} mutableCopy];

                      _sharedObject->_context = [CoreDataManager
                                                 newContextWithConcurrencyType:NSPrivateQueueConcurrencyType
                                                                   undoSupport:NO
                                                                       nametag:@"global cache"];

                      
                      _sharedObject.defaultDeviceUUID = UserDefaults[NDDefaultiTachDeviceKey];
                      
                      if (![NDiTachDevice deviceExistsWithUUID:_sharedObject.defaultDeviceUUID])
                      {
                          MSLogDebugTag(@"removing orphaned default device setting...");
                          _sharedObject.defaultDeviceUUID       = nil;
                          UserDefaults[NDDefaultiTachDeviceKey] = nil;
                      }

                      _sharedObject->_operationQueue =
                          [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.globalcache"];

                      _sharedObject->_multicastConnection =
                          [GlobalCacheMulticastConnection multicastConnection];
                      
                      _sharedObject->_connectedDevices = [NSMutableDictionary dictionaryWithCapacity:5];

                      NSArray * devices = [NDiTachDevice fetchAllInContext:_sharedObject->_context];

                      _sharedObject->_networkDevices =
                          (devices
                           ? [NSMutableDictionary dictionaryWithObjects:devices
                                                                forKeys:[devices
                                                                         valueForKeyPath:@"uuid"]]
                           : [NSMutableDictionary dictionaryWithCapacity:5]);
                      
                      _sharedObject->_beaconsReceived = [NSMutableSet setWithCapacity:5];

                      MSLogDebugTag(@"iTach devices retrieved from database:\n\t%@",
                                    _sharedObject->_networkDevices);

                      [NotificationCenter
                       addObserverForName:UIApplicationDidEnterBackgroundNotification
                                  object:SharedApp
                                   queue:nil
                              usingBlock:^(NSNotification * note)
                                         {
                                             if (kConnectionState & ConnectionStateMulticastGroup)
                                                 [_sharedObject->_multicastConnection leaveMulticastGroup];

                                             for (GlobalCacheDeviceConnection * connection
                                                  in [_sharedObject->_connectedDevices allValues])
                                             { // disconnect tcp socket
                                                 MSLogDebugTag(@"disconnecting device: %@",
                                                               connection.deviceUUID);
                                                 [connection disconnect];
                                             }
                                         }];

                     [NotificationCenter
                      addObserverForName:UIApplicationWillEnterForegroundNotification
                                  object:SharedApp
                                   queue:nil
                              usingBlock:^(NSNotification * note)
                                         {
                                             if (kConnectionState & ConnectionStateMulticastGroup)
                                                 [_sharedObject->_multicastConnection joinMulticastGroup];

                                             for (GlobalCacheDeviceConnection * connection
                                                  in _sharedObject->_connectedDevices)
                                             { // disconnect tcp socket
                                                 [_sharedObject->_operationQueue addOperationWithBlock:
                                                  ^{
                                                      BOOL success = [connection connect];
                                                      MSLogDebugTag(@"%@ to device: %@",
                                                                    (success
                                                                     ? @"reconnected"
                                                                     : @"failed to reconnect"),
                                                                    connection.deviceUUID);
                                                      
                                                      if (   success
                                                          && [connection.deviceUUID isEqualToString:
                                                              _sharedObject.defaultDeviceUUID])
                                                      {
                                                          kConnectionState |=
                                                              ConnectionStateDefaultDeviceConnected;
                                                      }
                                                  }];
                                             }
                                         }];
                  });
    return _sharedObject;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device Discovery
////////////////////////////////////////////////////////////////////////////////

- (BOOL)detectNetworkDevices
{
    // Make sure we are connected to wifi
    if (![ConnectionManager sharedConnectionManager].isWifiAvailable)
    {
        MSLogWarnTag(@"cannot detect network devices without valid wifi connection");
        return NO;
    }

    if (kConnectionState & ConnectionStateMulticastGroup)
    {
        MSLogWarnTag(@"multicast socket already exists");
        return YES;
    }

    [_operationQueue addOperationWithBlock:
     ^{
         if (![_multicastConnection joinMulticastGroup])
             MSLogErrorTag(@"failed to join multicast group");
         else
             kConnectionState |= ConnectionStateMulticastGroup;
     }];

    return YES;
}

- (void)stopNetworkDeviceDetection
{
    [_operationQueue addOperationWithBlock:
     ^{
         [_multicastConnection leaveMulticastGroup];
         kConnectionState &= ~ConnectionStateMulticastGroup;
     }];
}

- (void)receivedMulticastGroupMessage:(NSString *)message
{
    MSLogDebugTag(@"message:%@", message);

    if (StringIsEmpty(message)) return;

    NSArray * stringSegments = [[message stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                                substringsByMatchingOccurrencesOfRegEx:@"(?<=<-)(.*?)(?=>)"];

    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithCapacity:stringSegments.count];

    for (NSString * stringSegment in stringSegments)
    {
        // Split string using '=' and enter key=value pair in dictionary
        NSArray * keyValuePair = [stringSegment componentsSeparatedByString:@"="];

        if ([keyValuePair count] == 2) attributes[keyValuePair[0]] = [keyValuePair lastObject];
    }

    NSDictionary * keyMap = @{ @"Make"       :@"make",
                               @"Model"      :@"model",
                               @"PCB_PN"     :@"pcb_pn",
                               @"Pkg_Level"  :@"pkg_level",
                               @"Revision"   :@"revision",
                               @"SDKClass"   :@"sdkClass",
                               @"Status"     :@"status",
                               @"UUID"       :@"uuid",
                               @"Config-URL" :@"configURL" };


    [attributes mapKeysToBlock:^id(id k, id o) { return ([keyMap hasKey:k] ? keyMap[k] : k); }];

    MSLogDebugTag(@"parsed message:\n%@\n", attributes);

    NSString * uuid = attributes[@"uuid"];
    assert(uuid);

    if (_networkDevices[uuid])
        MSLogDebugTag(@"ignoring beacon from previously discovered device with uuid: %@", uuid);

    else if (![_beaconsReceived containsObject:attributes[@"uuid"]])
        [self deviceDiscoveredWithUUID:uuid attributes:attributes];

    else
        MSLogDebugTag(@"ingnoring previously received beacon for device with uuid: %@", uuid);
}

- (void)deviceDiscoveredWithUUID:(NSString *)uuid attributes:(NSDictionary *)attributes
{
    assert(uuid && attributes && !_networkDevices[uuid]);

    __block NDiTachDevice * device = nil;
    [_context performBlockAndWait:
     ^{
         device = [NDiTachDevice deviceWithAttributes:attributes context:_context];
     }];

    assert(device);

    [CoreDataManager saveContext:_context asynchronous:NO completion:^(BOOL success)
    {
        _networkDevices[uuid] = device;
        MSLogDebugTag(@"added device with uuid %@ to known devices, posting notification...", uuid);

        [NotificationCenter postNotificationName:NDiTachDeviceDiscoveryNotification
                                          object:self
                                        userInfo:@{ CMNetworkDeviceKey : attributes }];

        self.defaultDeviceUUID = uuid;

        [self stopNetworkDeviceDetection];
    }];
}

- (BOOL)isDetectingNetworkDevices { return (kConnectionState & ConnectionStateMulticastGroup); }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Default Device Connection
////////////////////////////////////////////////////////////////////////////////

- (void)setDefaultDeviceUUID:(NSString *)defaultDeviceUUID
{
    _defaultDeviceUUID = defaultDeviceUUID;
    UserDefaults[NDDefaultiTachDeviceKey] = _defaultDeviceUUID;
    kConnectionState = (_defaultDeviceUUID
                        ? kConnectionState | ConnectionStateDefaultDevice
                        : kConnectionState & ~ConnectionStateDefaultDevice);
}

- (BOOL)connectWithDefaultDevice
{
    if (!self.isDefaultDeviceConnected)
    {
            MSLogWarnTag(@"no default device registered, checking for known devices...");

        if (_networkDevices.count > 0)
        {
            MSLogWarnTag(@"setting default device from known devices, this should be done elsewhere");
            self.defaultDeviceUUID = [_networkDevices allKeys][0];
        }

        else return NO;
    }

    [_operationQueue addOperationWithBlock:^{ [self connectWithDevice:_defaultDeviceUUID]; }];

    return YES;
}

- (BOOL)isDefaultDeviceConnected { return (kConnectionState & ConnectionStateDefaultDeviceConnected); }

- (BOOL)connectWithDevice:(NSString *)uuid
{
    // Check wifi connection
    if (![ConnectionManager sharedConnectionManager].isWifiAvailable)
    {
        MSLogErrorTag(@"wifi connection required");
        return NO;
    }

    if (!uuid) uuid = self.defaultDeviceUUID;

    // Check device id
    if (StringIsEmpty(uuid)) { MSLogWarnTag(@"device uuid invalid"); return NO; }

    // Check for existing connection
    if (_connectedDevices[uuid]) { MSLogWarnTag(@"device connection already exists"); return YES; }

    // Add device uuid to set of connected devices and update state if default device
    NDiTachDevice * device = [NDiTachDevice fetchDeviceWithUUID:uuid context:_context];

    if (!device) { MSLogErrorTag(@"failed to retrieve device with uuid: %@", uuid); return NO; }

    GlobalCacheDeviceConnection * dc = [GlobalCacheDeviceConnection connectionForDevice:device];
    assert(dc);

    [_operationQueue addOperationWithBlock:
     ^{
         if (![dc connect]) MSLogErrorTag(@"connection failed for device with uuid: %@", uuid);

         _connectedDevices[uuid] = dc;

         if ([uuid isEqualToString:self.defaultDeviceUUID])
             kConnectionState |= ConnectionStateDefaultDeviceConnected;
     }];

    // Return success
    return YES;
}

- (void)deviceDisconnected:(NSString *)uuid
{
    if ([uuid isEqualToString:_defaultDeviceUUID])
        kConnectionState &= ~ConnectionStateDefaultDeviceConnected;
}

- (void)connectionEstablished:(GlobalCacheDeviceConnection *)deviceConnection
{
    assert(deviceConnection.isConnected);
    _connectedDevices[deviceConnection.deviceUUID] = deviceConnection;
}

- (BOOL)sendCommand:(NSString *)command
                tag:(NSUInteger)tag
             device:(NSString *)uuid
         completion:(RECommandCompletionHandler)completion
{

    if (!uuid) uuid = self.defaultDeviceUUID;
    MSLogDebugTag(@"tag:%u, device:%@, command:'%@'",
                  tag,
                  uuid,
                  [command stringByReplacingReturnsWithSymbol]);

    // check for command content
    if (StringIsEmpty(command)) { MSLogErrorTag(@"cannot send nil command"); return NO; }

    // check current connection
    GlobalCacheDeviceConnection * deviceConnection = _connectedDevices[uuid];

    if (!deviceConnection)
    {
        // not found among connected devices, check known devices
        NDiTachDevice * iTachDevice = _networkDevices[uuid];

        if (!iTachDevice) { MSLogErrorTag(@"failed to retrieve info for device:%@", uuid); return NO; }

        deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:iTachDevice];
    }

    NSBlockOperation * connectOp = nil;
    if (!deviceConnection.isConnected)
    {
        connectOp = [NSBlockOperation blockOperationWithBlock:
                     ^{
                         if (![deviceConnection connect])
                             MSLogErrorTag(@"failed to connect to device: %@", uuid);
                     }];

        [_operationQueue addOperation:connectOp];
    }

    if (completion) _requestLog[@(tag)] = completion;
    
    NSBlockOperation * queueCommandOp =
        [NSBlockOperation blockOperationWithBlock:
         ^{
             // insert tag if appropriate
             NSString * taggedCommand = [[command stringByReplacingOccurrencesOfString:@"<tag>"
                                                                           withString:$(@"%u",tag)]
                                         stringByAppendingFormat:@"<tag>%u", tag];

             // send command
             MSLogDebugTag(@"queueing command \"%@\"",
                           [taggedCommand stringByReplacingReturnsWithSymbol]);

             [deviceConnection enqueueCommand:taggedCommand];
         }];

    if (connectOp) [queueCommandOp addDependency:connectOp];

    [_operationQueue addOperation:queueCommandOp];

    return YES;
}

- (void)dispatchCompletionHandlerForTag:(NSNumber *)tag success:(BOOL)success
{
    RECommandCompletionHandler completion = _requestLog[tag];
    if (completion) completion(YES, success);
}

- (void)parseiTachReturnMessage:(NSString *)message
{
    // iTach completeir command: completeir,<module address>:<connector address>,<ID>
    // TODO: handle error messages
    MSKIT_STATIC_STRING_CONST   kIREnabled  = @"IR Learner Enabled\r";
    MSKIT_STATIC_STRING_CONST   kIRDisabled = @"IR Learner Disabled\r";
    MSKIT_STATIC_STRING_CONST   kCompleteIR = @"completeir";
    MSKIT_STATIC_STRING_CONST   kSendIR     = @"sendir";
    MSKIT_STATIC_STRING_CONST   kError      = @"ERR";

    MSLogDebugTag(@"Return message from device: \"%@\"",
                  [message stringByReplacingReturnsWithSymbol]);

    // command success
    if ([message hasPrefix:kCompleteIR])
        [self
             dispatchCompletionHandlerForTag:@(NSIntegerValue([message substringFromIndex:15]))
                                     success:YES];

    // error
    else if ([message hasPrefix:kError])
        [self dispatchCompletionHandlerForTag:@(-1) success:NO];

    // learner enabled
    else if ([kIREnabled isEqualToString:message])
    {
        MSLogInfoTag(@"IR Learner has been enabled on the iTach device");
        [NotificationCenter postNotificationName:kLearnerStatusDidChangeNotification
                                          object:self
                                        userInfo:@{ kLearnerStatusDidChangeNotification : @YES }];
    }

    // learner disabled
    else if ([kIRDisabled isEqualToString:message])
    {
        MSLogInfoTag(@"IR Learner has been disabled on the iTach device");
        [NotificationCenter postNotificationName:kLearnerStatusDidChangeNotification
                                          object:self
                                        userInfo:@{ kLearnerStatusDidChangeNotification : @NO }];
    }

    // captured commands
    else if ([message hasPrefix:kSendIR]) _capturedCommand = message;

    else if (ValueIsNotNil(_capturedCommand))
    {
        _capturedCommand = [_capturedCommand stringByAppendingString:message];
        MSLogDebugTag(@"capturedCommand = %@", _capturedCommand);
        [NotificationCenter postNotificationName:kCommandCapturedNotification
                                          object:self
                                        userInfo:@{ kCommandCapturedNotification : _capturedCommand }];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)statusDescription
{
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:4];

    if (kConnectionState & ConnectionStateMulticastGroup)
        [a addObject:@"ConnectionStateMulticastGroup"];

    if (kConnectionState & ConnectionStateDefaultDevice)
        [a addObject:@"ConnectionStateDefaultDevice"];

    if (kConnectionState & ConnectionStateDefaultDeviceConnected)
        [a addObject:@"ConnectionStateDefaultDeviceConnected"];

    return $(@"{\n\tkConnectionState:%@\n"
              "\tconnected devices:%@\n"
              "\tknown devices:%@\n}\n",
              [a componentsJoinedByString:@"|"],
              [[[_connectedDevices keysOfEntriesPassingTest:
                 ^BOOL (id key, id obj, BOOL * stop)
                 {
                     return [(GlobalCacheDeviceConnection*)obj isConnected];
                 }]
                allObjects] componentsJoinedByString:@", "],
              [[_networkDevices allKeys] componentsJoinedByString:@", "]);

}

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device Connection
////////////////////////////////////////////////////////////////////////////////

@implementation GlobalCacheDeviceConnection

+ (GlobalCacheDeviceConnection *)connectionForDevice:(NDiTachDevice *)device
{
    GlobalCacheDeviceConnection * connection = [self new];
    connection->_device = device;
    connection->_commandQueue = [MSQueue queue];
    return connection;
}

- (NSString *)deviceUUID { return _device.uuid; }

- (BOOL)connect
{
    if (_isConnecting) { MSLogWarnTag(@"already trying to connect"); return NO; }

    else _isConnecting = YES;

    assert(!IsMainQueue);

    if (  (_tcpSourceRead && !dispatch_source_testcancel(_tcpSourceRead))
       || (_tcpSourceWrite && !dispatch_source_testcancel(_tcpSourceWrite)))
    {
        MSLogWarnTag(@"already connected to device");
        _isConnecting = NO;
        return NO;
    }

    assert(!_tcpSourceWrite && !_tcpSourceRead);

    dispatch_queue_t   queue = dispatch_queue_create("com.moondeerstudios.tcpQueue",
                                                     DISPATCH_QUEUE_CONCURRENT);

    NSAssert(queue, @"%@ failed to create tcp queue", ClassTagSelectorString);

    // Get address info
    int               n;
    dispatch_fd_t     sockfd;
    struct addrinfo   hints, * res, * ressave;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((n = getaddrinfo([_device.configURL UTF8String],
                         [NDiTachDeviceTCPPort UTF8String],
                         &hints,
                         &res)) != 0)
    {
        MSLogErrorTag(@"error getting address info for %@, %@: %s",
                      _device.configURL, NDiTachDeviceTCPPort, gai_strerror(n));
        _isConnecting = NO;
        return NO;
    }

    ressave = res;

    // Create socket with address info
    do
    {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

        if (sockfd < 0) continue; // ignore this one

        if (connect(sockfd, res->ai_addr, res->ai_addrlen) == 0) break; // success

        close(sockfd); // ignore this one
        
    } while ((res = res->ai_next) != NULL);

    freeaddrinfo(ressave);

    if (res == NULL) // errno set from final connect()
    {
        MSLogErrorTag(@"error connecting to %@, %@", _device.configURL, NDiTachDeviceTCPPort);
        _isConnecting = NO;
        return NO;
    }

    // Make socket non-blocking
    int flags;

    if ((flags = fcntl(sockfd, F_GETFL, 0)) < 0)
        MSLogErrorTag(@"error getting flags for tcp socket: %d - %s", errno, strerror(errno));

    flags |= O_NONBLOCK;

    if (fcntl(sockfd, F_SETFL, flags) < 0)
        MSLogErrorTag(@"error setting flags for tcp socket: %d - %s", errno, strerror(errno));

    // Create dispatch source for socket
    _tcpSourceWrite = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, sockfd, 0, queue);
    assert(_tcpSourceWrite != nil);

    dispatch_source_set_event_handler(_tcpSourceWrite, ^{
        if ([_commandQueue isEmpty]) return;

        NSArray * cmdComponents = [[_commandQueue dequeue] componentsSeparatedByString:@"<tag>"];

        if (!cmdComponents) return;

        const char * msg = [cmdComponents[0] UTF8String];
        ssize_t bytesWritten = write(sockfd, msg, strlen(msg));

        if (bytesWritten < 0) MSLogErrorTag(@"write failed for tcp socket");
    });

    dispatch_source_set_cancel_handler(_tcpSourceWrite, ^{
        MSLogDebugTag(@"closing tcp socket...");
        close(sockfd);
        _tcpSourceWrite = nil;
//        _tcpSourceRead = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [GCConnManager deviceDisconnected:_device.uuid];
        });
    });

    _tcpSourceRead = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, queue);
    assert(_tcpSourceRead != nil);

    dispatch_source_set_event_handler(_tcpSourceRead, ^{
        ssize_t bytesAvailable = dispatch_source_get_data(_tcpSourceRead);
        char msg[bytesAvailable + 1];
        ssize_t bytesRead = read(sockfd, msg, bytesAvailable);

        if (bytesRead < 0)
            MSLogErrorTag(@"read failed for tcp socket");
        else
        {
            msg[bytesAvailable] = '\0';
            NSArray * msgComponents = [@(msg)componentsSeparatedByString: @"\r"];

            for (NSString * msgComponent in msgComponents)
            {
                if (msgComponent.length)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [GCConnManager parseiTachReturnMessage:msgComponent];
                    });
                }
            }
        }
    });

    dispatch_source_set_cancel_handler(_tcpSourceRead, ^{
        MSLogDebugTag(@"closing tcp socket...");
        close(sockfd);
//        _tcpSourceWrite = nil;
        _tcpSourceRead = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [GCConnManager deviceDisconnected:_device.uuid];
        });
    });

    // Start receiving events for dispatch sources
    dispatch_resume(_tcpSourceRead);
    dispatch_resume(_tcpSourceWrite);

    _isConnecting = NO;

    [GCConnManager connectionEstablished:self];

    return YES;
}

- (void)disconnect { if (self.isConnected) dispatch_source_cancel(_tcpSourceRead); }

- (void)enqueueCommand:(NSString *)command { [_commandQueue enqueue:[command copy]]; }

- (BOOL)isConnected { return (_tcpSourceRead && !dispatch_source_testcancel(_tcpSourceRead)); }

- (void)dealloc { [self disconnect]; }

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Multicast Group Connection
////////////////////////////////////////////////////////////////////////////////

@implementation GlobalCacheMulticastConnection

+ (GlobalCacheMulticastConnection *)multicastConnection
{
    static dispatch_once_t pred = 0;
    __strong static GlobalCacheMulticastConnection * _sharedObject = nil;
    dispatch_once(&pred, ^{ _sharedObject = [GlobalCacheMulticastConnection new]; });
    return _sharedObject;
}

- (BOOL)joinMulticastGroup
{
    assert(!IsMainQueue);

    if (_multicastSource && !dispatch_source_testcancel(_multicastSource))
    {
        MSLogWarnTag(@"multicast dispatch source already exists");
        return NO;
    }

    assert(!_multicastSource);

    dispatch_queue_t queue = dispatch_queue_create("com.moondeerstudios.multicastGroupQueue",
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

    if ((n = getaddrinfo([NDiTachDeviceMulticastGroupAddress UTF8String],
                         [NDiTachDeviceMulticastGroupPort UTF8String], &hints, &res)) != 0)
        MSLogErrorTag(@"error getting address info for %@, %@: %s",
                      NDiTachDeviceMulticastGroupAddress,
                      NDiTachDeviceMulticastGroupPort, gai_strerror(n));

    ressave = res;

    do
    {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
        if (sockfd >= 0) break; // success
        
    } while ((res = res->ai_next) != NULL);

    if (res == NULL)
    { // errno set from final socket()
        MSLogErrorTag(@"error creating multicast socket for %@, %@",
                      NDiTachDeviceMulticastGroupAddress,
                      NDiTachDeviceMulticastGroupPort);
        return NO;
    }

    sa = malloc(res->ai_addrlen);
    memcpy(sa, res->ai_addr, res->ai_addrlen);
    salen = res->ai_addrlen;
    freeaddrinfo(ressave);

    if (sockfd < 0) return NO;

    // Bind socket to multicast address info
    if (bind(sockfd, sa, salen) < 0)
    {
        MSLogErrorTag(@"failed to bind multicast socket: %d - %s...closing socket",
                      errno, strerror(errno));
        close(sockfd);
        free(sa);

        return NO;
    }

    // Join multicast group
    switch (sa->sa_family)
    {
        case AF_INET:
        {
            struct ip_mreq   mreq;
            memcpy(&mreq.imr_multiaddr,
                   &((const struct sockaddr_in*)sa)->sin_addr,
                   sizeof(struct in_addr));

            mreq.imr_interface.s_addr = htonl(INADDR_ANY);
            n = setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
        } break;

        case AF_INET6:
        {
            struct ipv6_mreq   mreq6;

            memcpy(&mreq6.ipv6mr_multiaddr,
                   &((const struct sockaddr_in6*)sa)->sin6_addr,
                   sizeof(struct in6_addr));

            mreq6.ipv6mr_interface = 0;
            n = setsockopt(sockfd, IPPROTO_IPV6, IPV6_JOIN_GROUP, &mreq6, sizeof(mreq6));
        } break;
    }

    if (n < 0)
    {
        MSLogErrorTag(@"failed to join multicast group: %d - %s...closing socket",
                      errno, strerror(errno));
        close(sockfd);
        free(sa);

        return NO;
    }

    // Create dispatch source with multicast socket
    _multicastSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, queue);
    assert(_multicastSource != nil);

    dispatch_source_set_event_handler(_multicastSource, ^{
        ssize_t bytesAvailable = dispatch_source_get_data(_multicastSource);
        char msg[bytesAvailable + 1];
        ssize_t bytesRead = read(sockfd, msg, bytesAvailable);

        if (bytesRead < 0)
        {
            MSLogErrorTag(@"read failed for multicast socket");
            dispatch_source_cancel(_multicastSource);
        }
        
        else
        {
            msg[bytesAvailable] = '\0';
            NSString * message = @(msg);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [GCConnManager receivedMulticastGroupMessage:message];
            });
        }
    });

    dispatch_source_set_cancel_handler(_multicastSource, ^{
//        MSLogDebug(@"(multicastSource cancel handler)\tclosing multicast socket...");
        close(dispatch_source_get_handle(_multicastSource));
        _multicastSource = nil;
    });

    dispatch_resume(_multicastSource);
    free(sa);

    return YES;
}

- (BOOL)isMemberOfMulticastGroup
{
    return (_multicastSource && !dispatch_source_testcancel(_multicastSource));
}

- (void)leaveMulticastGroup
{
    if (self.isMemberOfMulticastGroup) dispatch_source_cancel(_multicastSource);
}

- (void)dealloc { [self leaveMulticastGroup]; }

@end
