//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheConnectionManager_Private.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs and Class variables
////////////////////////////////////////////////////////////////////////////////

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_NETWORKING|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

static const GlobalCacheConnectionManager * globalCacheConnectionManager = nil;

MSSTRING_CONST   NDiTachDeviceDiscoveryNotification = @"NDiTachDeviceDiscoveryNotification";
MSSTRING_CONST   NDDefaultiTachDeviceKey            = @"NDDefaultiTachDeviceKey";

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

/*
+ (void)initialize
{
    if (self == [GlobalCacheConnectionManager class])
    {
        if (![self globalCacheConnectionManager])
            MSLogErrorTag(@"something went horribly wrong!");
    }
}
*/

+ (const GlobalCacheConnectionManager *)globalCacheConnectionManager
{
/*
    NSMutableString * instanceMethodEncodings = [@"" mutableCopy];
    unsigned int outCount;
    Method * methods = class_copyMethodList(self, &outCount);
    for (int i = 0; i < outCount; i++) {
        [instanceMethodEncodings appendFormat:@"%@ = %s\n",
         SelectorString(method_getName(methods[i])),
         method_getTypeEncoding(methods[i])];
    }
    MSLogDebugTag(@"type encodings for instance methods:\n%@",
                  [instanceMethodEncodings stringByRemovingCharactersFromSet:NSDecimalDigitCharacters]);
*/
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred,  ^{
        globalCacheConnectionManager = [self new];

        globalCacheConnectionManager->_requestLog = [@{} mutableCopy];

        globalCacheConnectionManager->_operationQueue = [NSOperationQueue operationQueueWithName:
                                                         @"com.moondeerstudios.globalcache"];

        globalCacheConnectionManager->_multicastConnection = [GlobalCacheMulticastConnection
                                                              multicastConnection];

        globalCacheConnectionManager->_connectedDevices = [@{} mutableCopy];


        NSArray * devices = [NDiTachDevice findAll];
        if (devices.count)
            globalCacheConnectionManager->_networkDevices =
                [NSMutableDictionary
                 dictionaryWithObjects:[devices valueForKeyPath:@"permanentURI.data"]
                               forKeys:[devices valueForKeyPath:@"uuid"]];

        else
            globalCacheConnectionManager->_networkDevices = [@{} mutableCopy];

        globalCacheConnectionManager->_beaconsReceived = [NSMutableSet setWithCapacity:5];

        MSLogDebugTag(@"iTach devices retrieved from database:\n\t%@",
                      globalCacheConnectionManager->_networkDevices);

        [NotificationCenter
         addObserverForName:UIApplicationDidEnterBackgroundNotification
                     object:UIApp
                      queue:CurrentQueue
                 usingBlock:^(NSNotification * note)
                            {
                                if (kConnectionState & ConnectionStateMulticastGroup)
                                    [globalCacheConnectionManager->_multicastConnection
                                     leaveMulticastGroup];

                                for (GlobalCacheDeviceConnection * connection
                                     in [globalCacheConnectionManager->_connectedDevices allValues])
                                { // disconnect tcp socket
                                    MSLogDebugTag(@"disconnecting device: %@", connection.deviceUUID);
                                    [connection disconnect];
                                }
                            }];

        [NotificationCenter
         addObserverForName:UIApplicationWillEnterForegroundNotification
                     object:UIApp
                      queue:nil
                 usingBlock:^(NSNotification * note)
                            {
                                if (kConnectionState & ConnectionStateMulticastGroup)
                                    [globalCacheConnectionManager->_multicastConnection
                                     joinMulticastGroup];

                                for (GlobalCacheDeviceConnection * connection
                                     in globalCacheConnectionManager->_connectedDevices)
                                { // disconnect tcp socket
                                    [globalCacheConnectionManager->_operationQueue addOperationWithBlock:
                                     ^{
                                         BOOL success = [connection connect];
                                         MSLogDebugTag(@"%@ to device: %@",
                                                       (success
                                                        ? @"reconnected"
                                                        : @"failed to reconnect"),
                                                       connection.deviceUUID);
                                         
                                         if (   success
                                             && [connection.deviceUUID isEqualToString:
                                                 [globalCacheConnectionManager defaultDeviceUUID]])
                                         {
                                             kConnectionState |= ConnectionStateDefaultDeviceConnected;
                                         }
                                     }];
                                }
                            }];
    });
    return globalCacheConnectionManager;
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
/*
     connectWithDevice:  						c@:@			char, id, SEL, id
     detectNetworkDevices  						c@:				char, id, SEL
     sendCommand:tag:device:completion: 		c@:@I@@?		char, id, SEL, id, unsigned int, id, id, ?
     statusDescription  						@@:				id, id, SEL
     defaultDeviceUUID	  						@@:				id, id, SEL
     stopNetworkDeviceDetection  				v@:				void, id, SEL
     receivedMulticastGroupMessage:  			v@:@			void, id, SEL, id
     deviceDiscoveredWithUUID:attributes:   	v@:@@			void, id, SEL, id, id
     setDefaultDeviceUUID:  					v@:@			void, id, SEL, id
     isDetectingNetworkDevices  				c@:				char, id, SEL
     isDefaultDeviceConnected  					c@:				char, id, SEL
     deviceDisconnected:  						v@:@			void, id, SEL, id
     connectionEstablished:  					v@:@			void, id, SEL, id
     dispatchCompletionHandlerForTag:success:   v@:@c			void, id, SEL, char
     parseiTachReturnMessage:  					v@:@			void, id, SEL, id
     .cxx_destruct  							 						v@:				void, id, SEL

 */
    if (![self globalCacheConnectionManager]) MSLogErrorTag(@"something went horribly wrong!");

    BOOL isResolved = NO;

    Method instanceMethod = class_getInstanceMethod(self, sel);
    if (!instanceMethod) return [super resolveClassMethod:sel];

    // how many arguments does it take?
    unsigned numberOfArgs = method_getNumberOfArguments(instanceMethod);

    // get type encodings
    NSString * typeEncodings = [@(method_getTypeEncoding(instanceMethod))
                                stringByRemovingCharactersFromSet:NSDecimalDigitCharacters];
    
    const char   returnType    = [typeEncodings characterAtIndex:0];
    const char * argumentTypes = (numberOfArgs > 2
                                  ? [[typeEncodings substringFromIndex:3] UTF8String]
                                  : NULL);
    IMP classImp = NULL;
    if (![typeEncodings hasSuffix:@"?"])
    { // Create block implementation for method that does not take a block

        classImp = imp_implementationWithBlock(^(id _self, ...) {
        // create the invocation with the appropriate method signature
        NSInvocation * invocation =
            [NSInvocation invocationWithMethodSignature:
             [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(instanceMethod)]];

        // set the target to the singleton instance
        [invocation setTarget:[GlobalCacheConnectionManager globalCacheConnectionManager]];

        // set the selector to the SEL being resolved
        [invocation setSelector:sel];

        // add any arguments
        if (argumentTypes)
        {
            int i = 0;
            char arg;
            va_list args;
            va_start(args, _self);
            while (i < numberOfArgs - 2)
            {
                arg = argumentTypes[i];
                switch (arg) {
                    case 'c':
                    {
                        char c =  va_arg(args, int);
                        [invocation setArgument:&c atIndex:i++ + 2];
                    } break;

                    case '@':
                    {
                        id obj = va_arg(args, id);
                        [invocation setArgument:&obj atIndex:i++ + 2];
                        [invocation retainArguments];
                    } break;

                    case 'I':
                    {
                        unsigned int u = va_arg(args, unsigned int);
                        [invocation setArgument:&u atIndex:i+= + 2];
                    } break;

                    default:
                        break;
                }
            }
            va_end(args);
        }

        // invoke the method
        [invocation invoke];

        if (returnType != 'v')
        {
            NSUInteger length = [[invocation methodSignature] methodReturnLength];
            void * buffer = (void *)malloc(length);
            [invocation getReturnValue:buffer];
            return buffer;
        }

        else
            return nil;
    });

    }

    
    else
    { // Only one method takes a block at the moment
        if (sel == @selector(sendCommand:tag:device:completion:))
            classImp =
                imp_implementationWithBlock(^(id _self,
                                              NSString * command,
                                              NSUInteger tag,
                                              NSString * device,
                                              void (^completion)(BOOL success, NSError *))
                                            {
                                                return [[GlobalCacheConnectionManager
                                                         globalCacheConnectionManager]
                                                        sendCommand:command
                                                        tag:tag
                                                        device:device
                                                        completion:completion];
                                            });
        
    }


    isResolved = class_addMethod(objc_getMetaClass("GlobalCacheConnectionManager"),
                                 sel,
                                 classImp,
                                 method_getTypeEncoding(instanceMethod));


    return isResolved;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device Discovery
////////////////////////////////////////////////////////////////////////////////

- (BOOL)detectNetworkDevices
{
    // Make sure we are connected to wifi
    if (![ConnectionManager isWifiAvailable])
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
                                matchingSubstringsForRegEx:@"(?<=<-)(.*?)(?=>)"];

    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithCapacity:stringSegments.count];

    for (NSString * stringSegment in stringSegments)
    {
        // Split string using '=' and enter key=value pair in dictionary
        NSArray * keyValuePair = [stringSegment componentsSeparatedByString:@"="];

        if ([keyValuePair count] == 2) attributes[keyValuePair[0]] = [keyValuePair lastObject];
    }

    NSString * deviceUUID = attributes[@"UUID"];
    if (   [_beaconsReceived containsObject:deviceUUID]
        || [NetworkDevice deviceExistsWithDeviceUUID:deviceUUID])
        return;

    else
        [_beaconsReceived addObject:deviceUUID];

    NSDictionary * keyMap = @{ @"Make"       :@"make",
                               @"Model"      :@"model",
                               @"PCB_PN"     :@"pcb_pn",
                               @"Pkg_Level"  :@"pkg_level",
                               @"Revision"   :@"revision",
                               @"SDKClass"   :@"sdkClass",
                               @"Status"     :@"status",
                               @"UUID"       :@"deviceUUID",
                               @"Config-URL" :@"configURL" };


    [attributes mapKeysToBlock:^id(id k, id o) { return ([keyMap hasKey:k] ? keyMap[k] : k); }];

    MSLogDebugTag(@"parsed message:\n%@\n", attributes);

    [self deviceDiscoveredWithAttributes:attributes];
}

- (void)deviceDiscoveredWithAttributes:(NSDictionary *)attributes
{
    NSOperationQueue * queue = CurrentQueue;
    __block NSString * uuid = nil;
    __block NDiTachDevice * device = nil;
    [CoreDataManager saveWithBlock:^(NSManagedObjectContext *context)
     {
         device = [NDiTachDevice deviceWithAttributes:attributes];
         if (device) uuid = device.uuid;
         
     }
     completion:^(BOOL success, NSError *error)
     {
         if (success && StringIsNotEmpty(uuid))
         {
             if (queue)
                 [queue addOperationWithBlock:
                  ^{
                      _networkDevices[uuid] = [NDiTachDevice findFirstByAttribute:@"uuid"
                                                                           withValue:uuid];
                      MSLogDebugTag(@"added device with uuid %@ to known devices", uuid);
                      [NotificationCenter postNotificationName:NDiTachDeviceDiscoveryNotification
                                                        object:[GlobalCacheConnectionManager class]
                                                      userInfo:@{ CMNetworkDeviceKey : attributes }];
                      [self stopNetworkDeviceDetection];
                  }];
             else
             {
                 _networkDevices[uuid] = [NDiTachDevice findFirstByAttribute:@"uuid"
                                                                      withValue:uuid];
                 MSLogDebugTag(@"added device with uuid %@ to known devices", uuid);
                 [NotificationCenter postNotificationName:NDiTachDeviceDiscoveryNotification
                                                   object:[GlobalCacheConnectionManager class]
                                                 userInfo:@{ CMNetworkDeviceKey : attributes }];
                 [self stopNetworkDeviceDetection];
             }

         }

         else MSHandleErrors(error); //[MagicalRecord handleErrors:error];
     }];
}

- (BOOL)isDetectingNetworkDevices { return (kConnectionState & ConnectionStateMulticastGroup); }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Default Device Connection
////////////////////////////////////////////////////////////////////////////////

- (void)setDefaultDeviceUUID:(NSString *)defaultDeviceUUID
{
    _defaultDeviceUUID = [defaultDeviceUUID copy];
    UserDefaults[NDDefaultiTachDeviceKey] = _defaultDeviceUUID;
    kConnectionState = (_defaultDeviceUUID
                        ? kConnectionState | ConnectionStateDefaultDevice
                        : kConnectionState & ~ConnectionStateDefaultDevice);
}

- (NSString *)defaultDeviceUUID
{
    if (!_defaultDeviceUUID)
    {
        NSString * uuid = UserDefaults[NDDefaultiTachDeviceKey];
        if (StringIsNotEmpty(uuid))
        {
            NSUInteger count = [NDiTachDevice countOfObjectsWithPredicate:NSPredicateMake(@"uuid == %k", uuid)];
            if (count == 1) {
                // uuid seems valid
                self.defaultDeviceUUID = uuid;

            } else {

                if (count)
                { // remove devices since uuid is not unique
                    [CoreDataManager
                     saveWithBlock:^(NSManagedObjectContext *localContext)
                     {
                         MSLogDebugTag(@"removing devices from store with non-unique uuid '%@'", uuid);
                         [NDiTachDevice deleteAllMatchingPredicate:NSPredicateMake(@"self.uuid EQUALS %k", uuid)
                                              context:localContext];
                     }
                     completion:^(BOOL success, NSError *error)
                     {
                         MSHandleErrors(error);
                         if (success)
                             MSLogDebugTag(@"devices with uuid '%@' removed successfully", uuid);
                         else
                             MSLogDebugTag(@"devices with uuid '%@' could not be removed", uuid);
                     }];
                }

                // remove uuid from user defaults
                UserDefaults[NDDefaultiTachDeviceKey] = nil;
            }
            
        }

        else if (_networkDevices.count)
        {
            self.defaultDeviceUUID = [_networkDevices allKeys][0];
        }
    }

    return _defaultDeviceUUID;
}

- (BOOL)isDefaultDeviceConnected
{
    return (kConnectionState & ConnectionStateDefaultDeviceConnected);
}

- (BOOL)connectWithDevice:(NSString *)uuid
{
    // Check wifi connection
    if (![ConnectionManager isWifiAvailable])
    {
        MSLogErrorTag(@"wifi connection required");
        return NO;
    }

    if (!uuid) uuid = [self defaultDeviceUUID];

    // Check device id
    if (StringIsEmpty(uuid)) { MSLogWarnTag(@"device uuid invalid"); return NO; }

    // Check for existing connection
    if (_connectedDevices[uuid]) { MSLogWarnTag(@"device connection already exists"); return YES; }

    // Add device uuid to set of connected devices and update state if default device

    GlobalCacheDeviceConnection * dc = [GlobalCacheDeviceConnection connectionForDevice:uuid];
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
    if ([uuid isEqualToString:self.defaultDeviceUUID])
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
         completion:(void (^)(BOOL success, NSError *))completion
{

    if (!uuid) uuid = self.defaultDeviceUUID;
    MSLogDebugTag(@"tag:%lu, device:%@, command:'%@'",
                  (unsigned long)tag,
                  uuid,
                  [command stringByReplacingReturnsWithSymbol]);

    // check for command content
    if (StringIsEmpty(command)) { MSLogErrorTag(@"cannot send nil command"); return NO; }

    // check current connection
    GlobalCacheDeviceConnection * deviceConnection = _connectedDevices[uuid];

    if (!deviceConnection)
        deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:uuid];

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
                                                                           withString:$(@"%lu",(unsigned long)tag)]
                                         stringByAppendingFormat:@"<tag>%lu", (unsigned long)tag];

             // send command
             MSLogDebugTag(@"queueing command \"%@\"",
                           [taggedCommand stringByReplacingReturnsWithSymbol]);

             [deviceConnection enqueueCommand:taggedCommand];
         }];

    if (connectOp) [queueCommandOp addDependency:connectOp];

    [_operationQueue addOperation:queueCommandOp];

    return YES;
}

+ (void)dispatchCompletionHandlerForTag:(NSNumber *)tag success:(BOOL)success
{
    [globalCacheConnectionManager dispatchCompletionHandlerForTag:tag success:success];
}
- (void)dispatchCompletionHandlerForTag:(NSNumber *)tag success:(BOOL)success
{
    void (^completion)(BOOL success, NSError *) = _requestLog[tag];
    if (completion) completion(success, nil);
}

- (void)parseiTachReturnMessage:(NSString *)message
{
    // iTach completeir command: completeir,<module address>:<connector address>,<ID>
    // TODO: handle error messages
    MSSTATIC_STRING_CONST   kIREnabled  = @"IR Learner Enabled\r";
    MSSTATIC_STRING_CONST   kIRDisabled = @"IR Learner Disabled\r";
    MSSTATIC_STRING_CONST   kCompleteIR = @"completeir";
    MSSTATIC_STRING_CONST   kSendIR     = @"sendir";
    MSSTATIC_STRING_CONST   kError      = @"ERR";

    MSLogDebugTag(@"Return message from device: \"%@\"",
                  [message stringByReplacingReturnsWithSymbol]);

    // command success
    if ([message hasPrefix:kCompleteIR])
        [self
             dispatchCompletionHandlerForTag:@(IntegerValue([message substringFromIndex:15]))
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

+ (GlobalCacheDeviceConnection *)connectionForDevice:(NSString *)uuid
{
    
    NDiTachDevice * device = [NDiTachDevice existingObjectWithUUID:uuid];

    if (device)
    {
        GlobalCacheDeviceConnection * connection = [GlobalCacheDeviceConnection new];
        connection->_device = device;
        connection->_commandQueue = [MSQueue queue];
        return connection;
    }

    else
        return nil;
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
            [globalCacheConnectionManager deviceDisconnected:_device.uuid];
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
                        [globalCacheConnectionManager parseiTachReturnMessage:msgComponent];
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
            [globalCacheConnectionManager deviceDisconnected:_device.uuid];
        });
    });

    // Start receiving events for dispatch sources
    dispatch_resume(_tcpSourceRead);
    dispatch_resume(_tcpSourceWrite);

    _isConnecting = NO;

    [globalCacheConnectionManager connectionEstablished:self];

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
    __strong static GlobalCacheMulticastConnection * globalCacheConnectionManager = nil;
    dispatch_once(&pred, ^{ globalCacheConnectionManager = [GlobalCacheMulticastConnection new]; });
    return globalCacheConnectionManager;
}

- (BOOL)joinMulticastGroup
{
//    assert(!IsMainQueue);

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
                [globalCacheConnectionManager receivedMulticastGroupMessage:message];
            });
        }
    });

    dispatch_source_set_cancel_handler(_multicastSource, ^{
//        MSLogDebug(@"(multicastSource cancel handler)\tclosing multicast socket...");
        close((int)dispatch_source_get_handle(_multicastSource));
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
