//
//  main.m
//  isy_client
//
//  Created by Jason Cardwell on 9/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
#import "unp.h"
@import Foundation;

static NSString const * kGroupAddress = @"239.255.255.250";
static NSString const * kGroupPort    = @"1900";

static dispatch_fd_t kMulticastFileDescriptor = -1;
static dispatch_queue_t kMulticastQueue = NULL;
static dispatch_source_t kMulticastSource = NULL;
static BOOL kDone = NO;
static const BOOL kExitOnMulticastCancel = YES;

#define RunOnMain(BLOCK) dispatch_async(dispatch_get_main_queue(), ^{BLOCK;})

dispatch_fd_t multicastGroupReceiveDescriptor();

void multicastGroupMessageReceived(NSString * message);

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    // create a queue for multicast group
    kMulticastQueue = dispatch_get_main_queue();

    // create a file descriptor for multicast group
    kMulticastFileDescriptor = multicastGroupReceiveDescriptor();
    if (kMulticastFileDescriptor < 0) {
      NSLog(@"failed to create valid multicast group receive file descriptor");
      return -1;
    }

    // create a dispatch source for multicast group
    kMulticastSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                              kMulticastFileDescriptor,
                                              0,
                                              kMulticastQueue);
    if (kMulticastSource == NULL) {
      NSLog(@"failed to create dispatch source for multicast group");
      return -1;
    }

    // add event handler for multicast group message receiving
    dispatch_source_set_event_handler(kMulticastSource, ^{

      ssize_t bytesAvailable = dispatch_source_get_data(kMulticastSource);
      char msg[bytesAvailable + 1];
      ssize_t bytesRead = read(kMulticastFileDescriptor, msg, bytesAvailable);

      if (bytesRead < 0) {

        NSLog(@"read failed for socket: %i - %s", errno, strerror(errno));
        dispatch_source_cancel(kMulticastSource);

      } else {

        msg[bytesAvailable] = '\0';
        NSString * message = @(msg);

        RunOnMain(multicastGroupMessageReceived(message));

      }

    });

    // add cancel handler to clean up multicast group resources
    dispatch_source_set_cancel_handler(kMulticastSource, ^{
      NSLog(@"closing multicast receive file descriptor and checking for any errors…");
      close(kMulticastFileDescriptor);
      if (errno) NSLog(@"error encountered: %i - %s", errno, strerror(errno));
      if (kExitOnMulticastCancel) {
        NSLog(@"exiting program…");
        RunOnMain(kDone = YES);
      }
    });

    // add registration handler to log setup completion of multicast group source
    dispatch_source_set_registration_handler(kMulticastSource, ^{
      NSLog(@"multicast dispatch source setup complete");
    });

    // resume the multicast group source to connect and begin receiving beacons
    dispatch_resume(kMulticastSource);


    // create loop controlled by `done` variable to keep process alive
//    while (!kDone) sleep(30);

  }

  return 0;
}

/// Log contents of message received over multicast source
void multicastGroupMessageReceived(NSString * message) {
  NSLog(@"message received over multicast source:\n%@", message);
}

/// Create a UDP socket for receiving the multicast group broadcast
dispatch_fd_t multicastGroupReceiveDescriptor() {

  // Get the address info

  struct sockaddr * socketAddress;
  socklen_t         socketAddressLength = 0;
  int               error;
  struct addrinfo   socketHints, * resolve;

  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_DGRAM;

  const char * address = [kGroupAddress UTF8String];
  const char * port    = [kGroupPort    UTF8String];

  error = getaddrinfo(address, port, &socketHints, &resolve);

  if (error) {

    NSLog(@"error getting address info for %s, %s: %s", address, port, gai_strerror(error));
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

    NSLog(@"error creating multicast socket for %s, %s", address, port);
    return -1;
  }

  // Bind socket to multicast address info

  if (bind(socketFileDescriptor, socketAddress, socketAddressLength) < 0) {

    close(socketFileDescriptor);
    free(socketAddress);

    NSLog(@"failed to bind multicast socket: %d - %s...closing socket", errno, strerror(errno));
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

    NSLog(@"failed to join multicast group: %d - %s...closing socket", errno, strerror(errno));

    return -1;
  }

  free(socketAddress);

  return socketFileDescriptor;

}
