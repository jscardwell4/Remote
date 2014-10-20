//
// NetworkDeviceMulticastConnection.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "NetworkDeviceConnection_Subclass.h"
#import "NetworkDeviceMulticastConnection.h"
#import <netdb.h>
#import "ConnectionManager.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface NetworkDeviceMulticastConnection ()
@property (nonatomic, copy)   NSString      * address;
@property (nonatomic, copy)   NSString      * port;
@end

@implementation NetworkDeviceMulticastConnection


+ (instancetype)connectionWithAddress:(NSString *)address
                                 port:(NSString *)port
                             delegate:(id<NetworkDeviceConnectionDelegate>)delegate
{

  if (StringIsEmpty(address)) ThrowInvalidNilArgument(address);
  if (StringIsEmpty(port))    ThrowInvalidNilArgument(port);

  NetworkDeviceMulticastConnection * connection = [self new];
  connection.address              = address;
  connection.port                 = port;
  connection.delegate             = delegate;

  return connection;

}


- (dispatch_fd_t)sourceFileDescriptor {

  /// Create a UDP socket for receiving the multicast group broadcast
  ////////////////////////////////////////////////////////////////////////////////


  // Get the address info

  struct sockaddr * socketAddress = NULL;
  socklen_t         socketAddressLength;
  int               error;
  struct addrinfo   socketHints, * resolve;

  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_DGRAM;

  const char * address = [self.address UTF8String];
  const char * port    = [self.port    UTF8String];

  error = getaddrinfo(address, port, &socketHints, &resolve);

  if (error) {

    MSLogErrorTag(@"error getting address info for %s, %s: %s", address, port, gai_strerror(error));
    return -1;

  }

  // Resolve into a useable socket

  dispatch_fd_t     socketFileDescriptor = -1;

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

    MSLogErrorTag(@"error creating multicast socket for %s, %s", address, port);
    return -1;
  }

  // Bind socket to multicast address info

  if (bind(socketFileDescriptor, socketAddress, socketAddressLength) < 0) {

    close(socketFileDescriptor);
    free(socketAddress);

    MSLogErrorTag(@"failed to bind multicast socket: %d - %s...closing socket", errno, strerror(errno));
    return -1;
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

    return -1;
  }

  free(socketAddress);
  
  return socketFileDescriptor;

}


@end
