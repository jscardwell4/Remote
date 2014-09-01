//
// GlobalCacheMulticastConnection.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheMulticastConnection.h"
#import <netdb.h>
#import "NetworkDevice.h"
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface GlobalCacheMulticastConnection ()
@property (strong) dispatch_source_t multicastSource;      // I/O source for multicast group
@property (copy)   void (^leaveCallback)(BOOL, NSError *); // group leave callback
@end

@implementation GlobalCacheMulticastConnection

/**

  Default method for obtaining a new `GlobalCacheMulticastConnection` object.

  @param handler The block to execute when a new message arrives over connection.

  @return The new connection object.

 */
+ (instancetype)connectionWithHandler:(void (^)(NSString *, GlobalCacheMulticastConnection *))handler {
  GlobalCacheMulticastConnection * connection = [self new];
  connection.messageHandler = handler;
  return connection;
}

/**
 Asks the connection object to establish its resources and join the multicast group.
 */
- (void)joinMulticastGroup:(void (^)(BOOL success, NSError * error))completion {


  /// Check if we have already joined a multicast group
  ////////////////////////////////////////////////////////////////////////////////


  if (self.isMemberOfMulticastGroup) {

    MSLogWarnTag(@"multicast dispatch source already exists");

    if (completion) completion(YES, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                        code:ConnectionManagerErrorConnectionExists
                                                    userInfo:nil]);

    return;
  }

  /// Create a UDP socket for receiving the multicast group broadcast
  ////////////////////////////////////////////////////////////////////////////////


  // Get the address info

  struct sockaddr * socketAddress;
  socklen_t         socketAddressLength;
  int               error;
  dispatch_fd_t     socketFileDescriptor = -1;
  struct addrinfo   socketHints, * resolve;

  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_DGRAM;

  const char * groupAddress = [NDiTachDeviceMulticastGroupAddress UTF8String];
  const char * groupPort    = [NDiTachDeviceMulticastGroupPort UTF8String];

  error = getaddrinfo(groupAddress, groupPort, &socketHints, &resolve);

  if (error) {

    MSLogErrorTag(@"error getting address info for %s, %s: %s", groupAddress, groupPort, gai_strerror(error));
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:error userInfo:nil]);
    return;

  }

  // Resolve into a useable socket

  do {

    socketFileDescriptor = socket(resolve->ai_family, resolve->ai_socktype, resolve->ai_protocol);

    if (socketFileDescriptor >= 0) { // success

      socketAddress = malloc(resolve->ai_addrlen);
      memcpy(socketAddress, resolve->ai_addr, resolve->ai_addrlen);
      socketAddressLength = resolve->ai_addrlen;

      break;
    }

  } while ((resolve = resolve->ai_next) != NULL);

  freeaddrinfo(resolve);

  if (socketAddress == NULL || socketFileDescriptor < 0) { // loop broke on NULL

    MSLogErrorTag(@"error creating multicast socket for %s, %s", groupAddress, groupPort);
    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;
  }

  // Bind socket to multicast address info

  if (bind(socketFileDescriptor, socketAddress, socketAddressLength) < 0) {

    close(socketFileDescriptor);
    free(socketAddress);

    MSLogErrorTag(@"failed to bind multicast socket: %d - %s...closing socket", errno, strerror(errno));

    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    return;
  }

  /// Join multicast group
  ////////////////////////////////////////////////////////////////////////////////

  switch (socketAddress->sa_family) {

    case AF_INET: {

      struct ip_mreq mreq;

      memcpy(&mreq.imr_multiaddr,
             &((const struct sockaddr_in *)socketAddress)->sin_addr,
             sizeof(struct in_addr));

      mreq.imr_interface.s_addr = htonl(INADDR_ANY);

      error = setsockopt(socketFileDescriptor, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));

    } break;

    case AF_INET6: {

      struct ipv6_mreq mreq6;

      memcpy(&mreq6.ipv6mr_multiaddr,
             &((const struct sockaddr_in6 *)socketAddress)->sin6_addr,
             sizeof(struct in6_addr));

      mreq6.ipv6mr_interface = 0;

      error = setsockopt(socketFileDescriptor, IPPROTO_IPV6, IPV6_JOIN_GROUP, &mreq6, sizeof(mreq6));

    } break;

    default: break;

  }

  if (error < 0) {

    close(socketFileDescriptor);
    free(socketAddress);

    MSLogErrorTag(@"failed to join multicast group: %d - %s...closing socket", errno, strerror(errno));

    if (completion) completion(NO, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    
    return;
  }

  /// Create dispatch source with multicast socket
  ////////////////////////////////////////////////////////////////////////////////

  dispatch_queue_t queue = dispatch_queue_create("com.moondeerstudios.multicast", DISPATCH_QUEUE_SERIAL);
  self.multicastSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, socketFileDescriptor, 0, queue);


  /// Set the event handler on the dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  __weak GlobalCacheMulticastConnection * weakself = self;

  dispatch_source_set_event_handler(self.multicastSource, ^{

    // Get the number of bytes we can read and read them into buffer

    ssize_t bytesAvailable = dispatch_source_get_data(weakself.multicastSource);

    char msg[bytesAvailable + 1];

    ssize_t bytesRead = read(socketFileDescriptor, msg, bytesAvailable);

    // Check if we failed to read anything
    if (bytesRead < 0) {

      MSLogErrorWeakTag(@"read failed for multicast socket - error: %i - %s", errno, strerror(errno));

      dispatch_source_cancel(weakself.multicastSource);

    }

    // Otherwise call message received handler
    else {

      msg[bytesAvailable] = '\0'; // null terminate string
      NSString * message = @(msg);

      if (weakself.messageHandler)
        [MainQueue addOperationWithBlock:^{ weakself.messageHandler(message, weakself); }];

    }

  });


  /// Set cancelation handler on the dispatch source
  ////////////////////////////////////////////////////////////////////////////////

  dispatch_source_set_cancel_handler(self.multicastSource, ^{

    // Close the underlying file descriptor and nullify ivar
    close((int)dispatch_source_get_handle(weakself.multicastSource));
    weakself.multicastSource = nil;

    // Invoke leave callback if set
    if (weakself.leaveCallback) {
      BOOL success = YES;
      NSError * error = nil;

      if (errno) {
        success = NO;
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
      }

      weakself.leaveCallback(success, error);
    }

  });


  /// Set registration handler on the dispatch source
  ////////////////////////////////////////////////////////////////////////////////


  dispatch_source_set_registration_handler(self.multicastSource, ^{ if (completion) completion(YES, nil); });

  dispatch_resume(self.multicastSource);
  free(socketAddress);

}

/// Indicates whether a connection to the multicast group has been established and is currently active.
- (BOOL)isMemberOfMulticastGroup {
  return (self.multicastSource && !dispatch_source_testcancel(self.multicastSource));
}

/**
 Asks the connection object to leave the multicast group and relinquish its resources.
 */
- (void)leaveMulticastGroup:(void (^)(BOOL success, NSError * error))completion {

  if (self.isMemberOfMulticastGroup) {

    self.leaveCallback = completion;
    dispatch_source_cancel(self.multicastSource);

  }

  else if (completion) completion(YES, nil);

}

/// Cancel dispatch source before being deallocated
- (void)dealloc { if (self.isMemberOfMulticastGroup) dispatch_source_cancel(self.multicastSource); }

@end
