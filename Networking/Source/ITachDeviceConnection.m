//
// ITachDeviceConnection.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ITachDeviceConnection.h"
#import "ConnectionManager.h"
#import "MessageQueueEntry.h"
@import DataModel;
@import MoonKit;

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

static dispatch_queue_t kITachQueue;

static const uint16_t kITachTCPPort = 4998;

/// responses

MSSTATIC_STRING_CONST kLearnerResponse          = @"IR Learner";
MSSTATIC_STRING_CONST kCompleteIRResponse       = @"completeir";
MSSTATIC_STRING_CONST kSendIRCommandResponse    = @"sendir";
MSSTATIC_STRING_CONST kSendIRErrorResponse      = @"ERR";
MSSTATIC_STRING_CONST kUnknownCommandResponse   = @"unknowncommand";
MSSTATIC_STRING_CONST kDeviceResponse           = @"device";
MSSTATIC_STRING_CONST kEndDeviceResponse        = @"endlistdevices";
MSSTATIC_STRING_CONST kVersionResponse          = @"version";
MSSTATIC_STRING_CONST kBusyIRResponse           = @"busyIR";
MSSTATIC_STRING_CONST kNetworkResponse          = @"NET";
MSSTATIC_STRING_CONST kIRConfigResponse         = @"IR";
MSSTATIC_STRING_CONST kStopIRResponse           = @"stopir";

/// Beacon keys

MSSTATIC_STRING_CONST kITachDevicePCB              = @"PCB_PN";
MSSTATIC_STRING_CONST kITachDevicePkg              = @"Pkg_Level";
MSSTATIC_STRING_CONST kITachDeviceSDK              = @"SDKClass";
MSSTATIC_STRING_CONST kITachDeviceMake             = @"Make";
MSSTATIC_STRING_CONST kITachDeviceModel            = @"Model";
MSSTATIC_STRING_CONST kITachDeviceRevision         = @"Revision";
MSSTATIC_STRING_CONST kITachDeviceStatus           = @"Status";
MSSTATIC_STRING_CONST kITachDeviceConfigURL        = @"Config-URL";
MSSTATIC_STRING_CONST kITachDeviceUniqueIdentifier = @"UUID";

/// Message keys

MSSTATIC_STRING_CONST kPortKey        = @"port";
MSSTATIC_STRING_CONST kTagKey         = @"tag";

typedef NS_ENUM(uint8_t, ITachDevicePort) {
  ITachDevicePortUnspecified = 0,
  ITachDevicePort1           = 1,
  ITachDevicePort2           = 2,
  ITachDevicePort3           = 3
};

ITachDevicePort ITachDevicePortInString(NSString * string) {

  NSString * match = [string stringByMatchingFirstOccurrenceOfRegEx:@"(?<=1:)[1-3]"];
  return (match ? (ITachDevicePort)[match intValue] : ITachDevicePortUnspecified);

}

static NSArray const * kITachErrorCodes;

@interface ITachDeviceConnection () <GCDAsyncSocketDelegate>

@property (nonatomic, strong, readwrite) MSDictionary   * messagesSending;    /// Messages being sent
@property (nonatomic, strong, readwrite) MSDictionary   * messagesSent;       /// Messages awaiting response
@property (nonatomic, assign, readwrite) BOOL             isConnecting;       /// Connection in progress
@property (nonatomic, strong, readwrite) ITachDevice    * device;             /// Model for device
@property (nonatomic, strong, readwrite) MSQueue        * messageQueue;       /// Message send buffer
@property (nonatomic, strong, readwrite) GCDAsyncSocket * socket;             /// Connection to device
@property (nonatomic, assign, readwrite) long             currentTag;         /// Current tag for new messages

@property (nonatomic, copy) void (^connectCallback)   (BOOL, NSError *);      /// Executed on connect
@property (nonatomic, copy) void (^disconnectCallback)(BOOL, NSError *);      /// Executed on disconnect

@end


/**

 The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 Messages to be sent to the device are received from the connection manager and messages received
 from the iTach device are passed up to the connection manager.

 */
@implementation ITachDeviceConnection

+ (void)initialize {
  if (self == [ITachDeviceConnection class]) {


    kITachErrorCodes = @[ @"Reserved error code",  // Inserted to make index match error code
                          @"Invalid command. Command not found",
                          @"Invalid module address (does not exist)",
                          @"Invalid connector address (does not exist)",
                          @"Invalid ID value",
                          @"Invalid frequency value",
                          @"Invalid repeat value",
                          @"Invalid offset value",
                          @"Invalid pulse count",
                          @"Invalid pulse data",
                          @"Uneven amount of <on|off> statements",
                          @"No carriage return found",
                          @"Repeat count exceeded",
                          @"IR command sent to input connector",
                          @"Blaster command sent to non-blaster connector",
                          @"No carriage return before buffer full",
                          @"No carriage return",
                          @"Bad command syntax",
                          @"Sensor command sent to non-input connector",
                          @"Repeated IR transmission failure",
                          @"Above designated IR <on|off> pair limit",
                          @"Symbol odd boundary",
                          @"Undefined symbol",
                          @"Unknown option",
                          @"Invalid baud rate setting",
                          @"Invalid flow control setting",
                          @"Invalid parity setting",
                          @"Settings are locked" ];

    kITachQueue = dispatch_queue_create("com.moondeerstudios.remote.itach", DISPATCH_QUEUE_CONCURRENT);

  }
}


/**

 Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.

 @param uri The URI for the device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `GlobalCachedDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(ITachDevice *)device {

  if (![device isKindOfClass:[ITachDevice class]])
    ThrowInvalidArgument(device, "device must be an iTach device object");

  ITachDeviceConnection * connection = [self new];
  connection.device = device;
  return connection;

}

/// connectionFromDiscoveryBeacon:delegate:
/// @param beacon
/// @param delegate
/// @return instancetype
+ (instancetype)connectionFromDiscoveryBeacon:(NSString *)beacon {

  if (StringIsEmpty(beacon)) ThrowInvalidNilArgument(beacon);

  static dispatch_once_t onceToken;
  static NSDictionary * index;
  dispatch_once(&onceToken, ^{
    index = @{kITachDeviceConfigURL        : @"configURL",
              kITachDeviceMake             : @"make",
              kITachDeviceModel            : @"model",
              kITachDevicePCB              : @"pcbPN",
              kITachDeviceSDK              : @"sdkClass",
              kITachDeviceStatus           : @"status",
              kITachDeviceRevision         : @"revision",
              kITachDevicePkg              : @"pkgLevel",
              kITachDeviceUniqueIdentifier : @"uniqueIdentifier"};
  });

  NSManagedObjectContext * moc = [DataManager mainContext];

  __block ITachDevice * device = nil;

  [moc performBlockAndWait:^{

    NSArray * entries = [beacon matchingSubstringsForRegEx:@"(?<=<-)(.*?)(?=>)"];
    MSDictionary * attributes = [MSDictionary dictionaryByParsingArray:entries separator:@"="];
    [attributes replaceKeysUsingKeyMap:index];

    NSString * uniqueIdentifier = attributes[@"uniqueIdentifier"];
    NSString * model            = attributes[@"model"];

    if (uniqueIdentifier && [model hasSubstring:@"IR"]) {

      device = [ITachDevice objectWithValue:uniqueIdentifier forAttribute:@"uniqueIdentifier" context:moc];
      if (!device) device = [ITachDevice createInContext:moc];

      NSSet * validKeys = [[index allValues] set];
      [attributes filter:^BOOL(id<NSCopying> key, id value) { return [validKeys containsObject:key]; }];
      assert([attributes count]);

      [device setValuesForKeysWithDictionary:attributes];

      NSError * error = nil;
      BOOL saved = [moc save:&error];
      MSHandleErrors(error);

      assert(saved);

      nsprintf(@"%@", device.description);

    }

  }];

  return (device ? [self connectionForDevice:device] : nil);

}

/// init
/// @return instancetype
- (instancetype)init {

  if ((self = [super init])) {

    self.messageQueue    = [MSQueue queue];
    self.messagesSent    = [MSDictionary dictionary];
    self.messagesSending = [MSDictionary dictionary];

  }

  return self;

}

/// entriesSentOverPort:
/// @param port
/// @return NSArray *
- (NSArray *)entriesSentOverPort:(ITachDevicePort)port {

  return [self.messagesSent.allValues filteredArrayUsingPredicateWithBlock:
          ^BOOL(MessageQueueEntry * entry, NSDictionary *bindings) {
            return [entry.userInfo[kPortKey] isEqualToNumber:@(port)];
          }];

}

/// isConnected
/// @return BOOL
- (BOOL)isConnected { return self.socket.isConnected; }

/// sendNextMessage
- (void)sendNextMessage {

  if (!self.socket.isConnected)
    ThrowInvalidInternalInconsistency("request to send next message but there is no socket connected");

  else if (![self.messageQueue isEmpty]) {

    MessageQueueEntry * entry = [self.messageQueue dequeue];

    long tag = self.currentTag++; // Should be the ONLY place the tag is incremented

    entry.userInfo[kTagKey] = @(tag); // Add the tag to the user info

    // Remove placeholder if the entry is for a sendir command
    if ([entry.message hasPrefix:@"sendir"])
      entry.message = [entry.message stringByReplacingOccurrencesOfString:@"<tag>"
                                                               withString:[@(self.currentTag) stringValue]];

    MSLogInfo(@"sending tag '%li'", tag);

    // Send the message
    [self.socket writeData:entry.data withTimeout:-1 tag:tag];


    // Move entry to our outgoing collection
    self.messagesSending[@(tag)] = entry;

  }

}

/// connect:
/// @param completion
- (void)connect:(void (^)(BOOL, NSError *))completion {

  if (!self.device)
    ThrowInvalidInternalInconsistency("request to connect but no device is set");

  // Exit early if an attempt to connect is already in progress
  else if (self.isConnecting) {
    MSLogWarnTag(@"already trying to connect");
    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorConnectionInProgress
                                                   userInfo:nil]);
  }

  // Or if we are already connected
  else if (self.isConnected) {

    MSLogWarnTag(@"already connected to device");
    if (completion) completion(YES, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                        code:ConnectionManagerErrorConnectionExists
                                                    userInfo:nil]);
  }

  // Otherwise set the flag
  else {

    self.isConnecting = YES;
    self.connectCallback = completion;

    if (!self.socket) self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:kITachQueue];

    NSError * error = nil;
    [self.socket connectToHost:self.device.configURL onPort:kITachTCPPort error:&error];

    if (error && completion) {

      completion(NO, error);
      self.connectCallback = nil;

    } else
      MSHandleErrors(error);

  }
}

/// disconnect:
/// @param completion
- (void)disconnect:(void (^)(BOOL, NSError *))completion {

  if (self.isConnected) {

    self.disconnectCallback = completion;
    [self.socket disconnectAfterReadingAndWriting];

  } else if (completion)
    completion(YES, nil);

}

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.

 @param command The `SendIRCommand` or `NSString` object encapsulating the message to transmit to the device.


 @param completion The block to be executed upon task completion, may be nil.

 */
- (void)enqueueCommand:(id)command
            completion:(void (^)(BOOL success, NSString * response, NSError * error))completion
{

  MessageQueueEntry * entry = nil;

  // Check if we are queueing a sendir command
  if ([command isKindOfClass:[SendIRCommand class]]) {

    NSMutableString * message = [((SendIRCommand *)command).commandString mutableCopy];

    if(StringIsNotEmpty(message)) {

      entry = [MessageQueueEntry message:message completion:completion];
      entry.userInfo[kPortKey] = @(((SendIRCommand *)command).code.device.port); // For port specific responses

    }

  }

  // Else if `command` is a string, try to discern the type of the command from its prefix
  else if (isStringKind(command))
    entry = [MessageQueueEntry message:command completion:completion];

  if (entry) {

    [self.messageQueue enqueue:entry];

    // Check if we are connected and execute the block if we are
    if (!(self.isConnected || self.isConnecting)) {
      assert(!self.connectCallback);
      [self connect:nil];

    }

  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - GCDAsyncSocketDelegate
////////////////////////////////////////////////////////////////////////////////


/// socket:didConnectToHost:port:
/// @param sock
/// @param host
/// @param port
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {

  self.isConnecting = NO;

  if (self.connectCallback) {

    self.connectCallback(YES, nil);
    self.connectCallback = nil;

  }

  [self sendNextMessage];

}

/// socket:didReadData:withTag:
/// @param sock
/// @param data
/// @param tag
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

  NSString          * message = [NSString stringWithData:data];
  MessageQueueEntry * entry   = [self.messagesSent popObjectForKey:@(tag)];

  MSLogInfo(@"read data for tag '%li': %@", tag, [message stringByReplacingReturnsWithSymbol]);

  // Check if message indicates a successfully transmitted command
  if ((    [message hasPrefix:kCompleteIRResponse]
        || [message hasPrefix:kIRConfigResponse]
        || [message hasPrefix:kDeviceResponse]
        || [message hasPrefix:kNetworkResponse]
        || [message hasPrefix:kVersionResponse])
        && entry.completion)  entry.completion(YES, nil, nil);


  // Check if message indicates a transimission error
  else if ([message hasSubstring:kSendIRErrorResponse] && entry.completion) {

    unsigned int errorCode = [[message stringByMatchingFirstOccurrenceOfRegEx:@"[0-9]+$"] uintValue];
    assert(errorCode && [kITachErrorCodes count] > errorCode);

    NSString * errorMessage = kITachErrorCodes[errorCode];
    assert(errorMessage);

    NSError * error = [NSError errorWithDomain:ConnectionManagerErrorDomain
                                          code:ConnectionManagerErrorNetworkDeviceError
                                      userInfo:@{NSLocalizedFailureReasonErrorKey: errorMessage}];

    entry.completion(NO, nil, error);

  }

  // Check if message indicates the learner has been enabled
  else if ([message hasPrefix:kLearnerResponse] && self.learnerDelegate) {

    if ([message hasSubstring:@"Enabled"])
    [self.learnerDelegate learnerEnabledOverConnection:self];

    else if ([message hasSubstring:@"Disabled"])
    [self.learnerDelegate learnerDisabledOverConnection:self];

    else
    [self.learnerDelegate learnerUnavailableOverConnection:self];

  }

  // Check if message indicates a stopir command has been carried out
  else if ([message hasPrefix:kStopIRResponse] && entry.completion) {
    //TODO: Handle stop IR commands

    // Get the port affect by stop ir command
    ITachDevicePort port = ITachDevicePortInString(message);
    assert(port != ITachDevicePortUnspecified);

    // Create the error
    NSError * error = [NSError errorWithDomain:ConnectionManagerErrorDomain
                                          code:ConnectionManagerErrorCommandHalted
                                      userInfo:nil];

    // Execute each affected entry's completion handler if set
    entry.completion(NO, nil, error);

  }

  // Check if message indicates the ir port was busy
  else if ([message hasPrefix:kBusyIRResponse]) {
    // Perhaps implement port specific queueing to handle busy responses?

    // Get the tag for the command not carried out and stick the corresponding entry back into the queue.
    long busyTag = [[message stringByMatchingFirstOccurrenceOfRegEx:@"(?<=,)[0-9]+$"] intValue];
    assert(busyTag == tag);
    assert(entry);
    [self.messageQueue enqueue:entry];

  }

  // Check if message begins the content of a captured command
  else if ([message hasPrefix:kSendIRCommandResponse] && self.learnerDelegate)
    [self.learnerDelegate commandCaptured:[message copy] overConnection:self];

}

/// socket:didWriteDataWithTag:
/// @param sock
/// @param tag
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {

  // Take the message sent out of our pending collection
  MessageQueueEntry * entry = [self.messagesSending popObjectForKey:@(tag)];
  assert(entry);

  MSLogInfo(@"data written for tag '%li': %@", tag, [entry.message stringByReplacingReturnsWithSymbol]);

  // Insert it into our delivered collection
  self.messagesSent[@(tag)] = entry;

  MSLogInfo(@"invoking read for tag '%li'", tag);

  // Initiate a read to receive the device response
  [self.socket readDataToData:[GCDAsyncSocket CRData]
                  withTimeout:-1
                       buffer:nil
                 bufferOffset:0
                    maxLength:0
                          tag:tag];

  // Send next if queue is not empty
  [self sendNextMessage];

}

/// socketDidDisconnect:withError:
/// @param sock
/// @param err
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {

  if (self.disconnectCallback) {

    self.disconnectCallback(YES, err);
    self.disconnectCallback = nil;

  } else
    MSHandleErrors(err);

}

@end


