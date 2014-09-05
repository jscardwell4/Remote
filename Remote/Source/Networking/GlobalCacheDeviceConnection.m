//
// GlobalCacheDeviceConnection.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "NetworkDeviceConnection_Subclass.h"
#import "GlobalCacheDeviceConnection.h"
#import "NDiTachDevice.h"
#import <netdb.h>
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)



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
                           delegate:(id<NetworkDeviceConnectionDelegate>)delegate
{

  GlobalCacheDeviceConnection * connection = nil;
  if ([device isKindOfClass:[NDiTachDevice class]])
    connection = [super connectionForDevice:device delegate:delegate];

  return connection;
}

- (dispatch_fd_t)sourceFileDescriptor {

  /// Create the socket for the dispatch source
  ////////////////////////////////////////////////////////////////////////////////


  // Create hints structure for socket address info

  struct addrinfo socketHints;
  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_STREAM;

  // Get address info using hints, device url and port

  struct addrinfo * resolve;
  const char * configURL = [[((NDiTachDevice *)self.device).configURL substringFromIndex:7] UTF8String];
  const char * tcpPort   = [NDiTachDeviceTCPPort UTF8String];

  int error = getaddrinfo(configURL, tcpPort, &socketHints, &resolve);

  if (error) {

    MSLogErrorTag(@"error getting address info for %s, %s: %s", configURL, tcpPort, gai_strerror(error));
    //???: Does `resolve` need to be freed if error occurred in `getaddrinfo`?
    return -1;

  }

  // Resolve into a useable socket

  dispatch_fd_t socketFileDescriptor = -1;

  do {

    socketFileDescriptor = socket(resolve->ai_family, resolve->ai_socktype, resolve->ai_protocol);

    if (socketFileDescriptor >= 0) break; // success

  } while ((resolve = resolve->ai_next) != NULL);

  freeaddrinfo(resolve);

  if (socketFileDescriptor < 0) { // failed to get a valid socket

    MSLogErrorTag(@"error connecting to %s, %s", configURL, tcpPort);
    return -1;

  }

  // Make socket non-blocking

  int flags = fcntl(socketFileDescriptor, F_GETFL, 0);

  if (flags < 0) {

    MSLogErrorTag(@"error getting flags for tcp socket: %d - %s", errno, strerror(errno));
    return -1;

  }

  flags |= O_NONBLOCK;

  error = fcntl(socketFileDescriptor, F_SETFL, flags);

  if (error) {

    MSLogErrorTag(@"error setting flags for tcp socket: %d - %s", errno, strerror(errno));
    return -1;

  }

  return socketFileDescriptor;
  
}

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.

 @param command The string to be transmitted to the device for execution.

 @param completion The block to be executed upon task completion, may be nil.

 */
- (void)enqueueCommand:(NSString *)command completion:(void (^)(BOOL, NSError *))completion {

  NSString * cmd = [[command componentsSeparatedByString:@"<tag>"] firstObject];

  if (StringIsEmpty(cmd) && completion) {

    MSLogErrorTag(@"empty command string");

    completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                       code:ConnectionManagerErrorCommandEmpty
                                   userInfo:nil]);

  } else {

    [self.messageQueue enqueue:[MessageQueueEntry entryWithMessage:cmd completion:completion]];

  }

}


@end

