//
// GlobalCacheDeviceConnection.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheDeviceConnection.h"
#import "NetworkDevice.h"
#import <netdb.h>
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


@interface CommandQueueEntry : NSObject

@property (nonatomic, copy) NSString * command;
@property (nonatomic, copy) void (^completion)(BOOL, NSError *);

+ (instancetype)entryWithCommand:(NSString *)command completion:(void(^)(BOOL success, NSError * error))completion;

@end

@implementation CommandQueueEntry

+ (instancetype)entryWithCommand:(NSString *)command
                      completion:(void(^)(BOOL success, NSError * error))completion
{
  if (StringIsEmpty(command)) ThrowInvalidNilArgument(command);
  CommandQueueEntry * entry = [self new];
  entry.command = command;
  entry.completion = completion;

  return entry;
}

@end

@interface GlobalCacheDeviceConnection ()
@property (nonatomic, strong, readwrite) dispatch_source_t   tcpSourceRead;  // Receiving I/O source
@property (nonatomic, strong, readwrite) dispatch_source_t   tcpSourceWrite; // Sending I/O source
@property (nonatomic, strong, readwrite) MSQueue           * commandQueue;   // Message send buffer
@property (nonatomic, assign, readwrite) BOOL                isConnecting;   // Connection in progress
@property (nonatomic, strong, readwrite) NDiTachDevice     * device;         // Model for connected device

@property (nonatomic, copy) void (^disconnectCallback)(BOOL, NSError *);     // Block to execute on disconnecting

@end

/**

 The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 Messages to be sent to the device are received from the connection manager and messages received
 from the iTach device are passed up to the connection manager.

 */
@implementation GlobalCacheDeviceConnection

/**

 Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.

 @param uri The URI for the device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `GlobalCachedDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(NDiTachDevice *)device
                           delegate:(id<GlobalCacheDeviceConnectionDelegate>)delegate
{
  if (!device) ThrowInvalidNilArgument(device);

  GlobalCacheDeviceConnection * connection = [GlobalCacheDeviceConnection new];
  connection.device       = device;
  connection.commandQueue = [MSQueue queue];
  connection.delegate     = delegate;

  return connection;
}

/**

 Asks the `GlobalCacheDeviceConnection` to commence communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)connect:(void (^)(BOOL, NSError *))completion {

  // Exit early if an attempt to connect is already in progress
  if (self.isConnecting) {
    MSLogWarnTag(@"already trying to connect");
    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorConnectionInProgress
                                                   userInfo:nil]);
    return;
  }

  // Or if we are already connected
  else if (  (self.tcpSourceRead && !dispatch_source_testcancel(self.tcpSourceRead))
           || (self.tcpSourceWrite && !dispatch_source_testcancel(self.tcpSourceWrite)))
  {
    MSLogWarnTag(@"already connected to device");
    if (completion) completion(YES, nil);
    return;
  }

  // Otherwise set the flag
  else self.isConnecting = YES;


  /// Create the socket for the dispatch source
  ////////////////////////////////////////////////////////////////////////////////


  // Get address info

  int             error;
  dispatch_fd_t   socketFileDescriptor = -1;
  struct addrinfo socketHints, * resolve;

  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_STREAM;

  const char * configURL = [self.device.configURL UTF8String];
  const char * tcpPort   = [NDiTachDeviceTCPPort UTF8String];

  error = getaddrinfo(configURL, tcpPort, &socketHints, &resolve);

  if (error) {

    MSLogErrorTag(@"error getting address info for %s, %s: %s", configURL, tcpPort, gai_strerror(error));
    self.isConnecting = NO;
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;

  }

  // Resolve into a useable socket

  do {

    socketFileDescriptor = socket(resolve->ai_family, resolve->ai_socktype, resolve->ai_protocol);

    if (socketFileDescriptor >= 0) break; // success

  } while ((resolve = resolve->ai_next) != NULL);

  freeaddrinfo(resolve);

  if (socketFileDescriptor < 0) { // failed to get a valid socket

    MSLogErrorTag(@"error connecting to %s, %s", configURL, tcpPort);
    self.isConnecting = NO;
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;

  }

  // Make socket non-blocking

  int flags = fcntl(socketFileDescriptor, F_GETFL, 0);

  if (flags < 0) {

    MSLogErrorTag(@"error getting flags for tcp socket: %d - %s", errno, strerror(errno));
    self.isConnecting = NO;
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;

  }

  flags |= O_NONBLOCK;

  error = fcntl(socketFileDescriptor, F_SETFL, flags);

  if (error) {

    MSLogErrorTag(@"error setting flags for tcp socket: %d - %s", errno, strerror(errno));
    self.isConnecting = NO;
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;

  }


  /// Create write dispatch source for socket
  ////////////////////////////////////////////////////////////////////////////////

  dispatch_queue_t queue = dispatch_queue_create("com.moondeerstudios.tcpQueue", DISPATCH_QUEUE_CONCURRENT);

  self.tcpSourceWrite = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, socketFileDescriptor, 0, queue);

  /// Set event handler on write dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  __weak GlobalCacheDeviceConnection * weakself = self;

  dispatch_source_set_event_handler(self.tcpSourceWrite, ^{

    // Exit early if the queue is empty
    if ([weakself.commandQueue isEmpty]) return;

    // Dequeue an entry
    CommandQueueEntry * entry = [weakself.commandQueue dequeue];

    // Split by `tag` tags
    NSArray * cmdComponents = [entry.command componentsSeparatedByString:@"<tag>"];

    // Check for a string to send
    if (!cmdComponents) {

      MSLogErrorWeakTag(@"empty command string");

      if (entry.completion) entry.completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                                     code:ConnectionManagerErrorCommandEmpty
                                                                 userInfo:nil]);

    }

    // Send the string
    else {

      const char * msg = [cmdComponents[0] UTF8String];
      ssize_t bytesWritten = write(socketFileDescriptor, msg, strlen(msg));

      // Check if string was written
      if (bytesWritten < 0) {

        //???: Should the dispatch source be cancelled here?

        MSLogErrorWeakTag(@"write failed for tcp socket");

        if (entry.completion)
          entry.completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);

      }

      // Invoke completion block if all bytes were written
      else if (bytesWritten == strlen(msg) * sizeof(char) && entry.completion) entry.completion(YES, nil);

    }

  });

  /// Set cancel handler on write dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  // Since read and write share a file descriptor, the disconnect handler is only called here
  dispatch_source_set_cancel_handler(self.tcpSourceWrite, ^{

    close(socketFileDescriptor);
    weakself.tcpSourceWrite = nil;
    
    [MainQueue addOperationWithBlock:^{

      if (weakself.disconnectCallback) {

        BOOL success = YES;
        NSError * error = nil;

        if (errno)
          error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];

        weakself.disconnectCallback(success, error);
      }

      if (weakself.delegate)
        [weakself.delegate deviceDisconnected:weakself];

    }];

  });

  /// Set the registration handler on write dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  dispatch_source_set_registration_handler(self.tcpSourceWrite, ^{
    [MainQueue addOperationWithBlock:^{
      if (completion) completion(YES, nil);
      if (weakself.delegate) [weakself.delegate connectionEstablished:weakself];
    }];
  });


  /// Create read dispatch source for socket
  ////////////////////////////////////////////////////////////////////////////////


  self.tcpSourceRead = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, socketFileDescriptor, 0, queue);


  /// Set event handler on the read dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  dispatch_source_set_event_handler(self.tcpSourceRead, ^{

    ssize_t bytesAvailable = dispatch_source_get_data(weakself.tcpSourceRead);
    char msg[bytesAvailable + 1];
    ssize_t bytesRead = read(socketFileDescriptor, msg, bytesAvailable);

    if (bytesRead < 0) {

      MSLogErrorWeakTag(@"read failed for tcp socket");
      //???: Should the dispatch source be cancelled here?

    }

    else {

      msg[bytesAvailable] = '\0';
      NSArray * msgComponents = [@(msg)componentsSeparatedByString: @"\r"];

      if (weakself.delegate)
        for (NSString * msgComponent in msgComponents)
          if (msgComponent.length)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              [weakself.delegate messageReceived:msgComponent overConnection:weakself];
            });
    }
  });

  dispatch_source_set_cancel_handler(self.tcpSourceRead, ^{
    MSLogDebugTag(@"closing tcp socket...");
    close(socketFileDescriptor);
    weakself.tcpSourceRead = nil;
    if (weakself.delegate)
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakself.delegate deviceDisconnected:weakself];
      });
  });

  // Start receiving events for dispatch sources
  dispatch_resume(self.tcpSourceRead);
  dispatch_resume(self.tcpSourceWrite);

  self.isConnecting = NO;

  [self.delegate connectionEstablished:self];

  return YES;
}

/**

 Asks the `GlobalCacheDeviceConnection` to end communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)disconnect:(void (^)(BOOL success, NSError * error))completion {
  if (self.isConnected) dispatch_source_cancel(self.tcpSourceRead);
}

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.

 @param command The string to be transmitted to the device for execution.

 @param completion The block to be executed upon task completion, may be nil.

 */
- (void)enqueueCommand:(NSString *)command completion:(void (^)(BOOL, NSError *))completion {
  [self.commandQueue enqueue:[CommandQueueEntry entryWithCommand:command completion:completion]];
}

/// Whether the connection has been successfully established and is available for send operations.
- (BOOL)isConnected { return (self.tcpSourceRead && !dispatch_source_testcancel(self.tcpSourceRead)); }

/// Disposes of dispatch sources before being deallocated
- (void)dealloc { [self disconnect:nil]; }

@end

