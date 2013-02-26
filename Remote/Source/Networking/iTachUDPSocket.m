//
// iTachUDPSocket.m
// iPhonto
//
// Created by Jason Cardwell on 9/9/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "iTachUDPSocket.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <stdio.h>
#import <string.h>
#import <time.h>

static int   ddLogLevel = DefaultDDLogLevel;

@interface iTachUDPSocket ()

@property (nonatomic, strong) dispatch_queue_t   queue;
@property (nonatomic, strong) dispatch_io_t      channel;

@end

@implementation iTachUDPSocket {
    int                  socketDescriptor;
    struct sockaddr_in   sourceAddress;
    struct sockaddr_in   destinationAddress;
    int                  socketError;
    int                  bindError;
    uint                 addressLength;

    void   (^ receiveCallback)(NSString * message);
}

@synthesize listen = _listen;

- (id)init {
    if (self = [super init]) {
        destinationAddress.sin_family = AF_INET;
        destinationAddress.sin_port   = htons(9131);
        // inet_pton(AF_INET, "239.255.250.250", &destinationAddress.sin_addr);
        destinationAddress.sin_addr.s_addr = htons(INADDR_ANY);
        socketDescriptor                   = socket(AF_INET, SOCK_DGRAM, 0);
        if (socketDescriptor < 0) {
            socketError = errno;
            DDLogError(@"%@\n\terror creating udp socket for iTach devices, error code %d - %s", ClassTagSelectorString, errno, strerror(errno));
        } else {
            bindError = bind(socketDescriptor, (struct sockaddr *)&destinationAddress, sizeof(destinationAddress));
            if (bindError < 0) DDLogError(@"%@\n\terror binding udp socket for iTach devices, error code %d - %s", ClassTagSelectorString, bindError, strerror(bindError));
        }

        struct ip_mreq   mreq;

        mreq.imr_multiaddr.s_addr = inet_addr("239.255.250.250");
        mreq.imr_interface.s_addr = htonl(INADDR_ANY);
        if (setsockopt(socketDescriptor, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
            perror("setsockopt");
            exit(1);
        }
    }

    return self;
}

- (void)setListen:(BOOL)listen callback:(void (^)(NSString * message))callback {
    if (callback) receiveCallback = callback;
    else receiveCallback = nil;

    self.listen = listen;
}

- (void)setListen:(BOOL)listen {
    if (_listen && !listen) {
        // stop listening
    } else if (!_listen && listen) {
        // start listening

        void   (^ listenHandler)(void) = ^(void) {
            char * charBuffer = calloc(300, sizeof(char));

            addressLength = sizeof(sourceAddress);

            int   msgLength = recvfrom(socketDescriptor, charBuffer, 2000, 0, (struct sockaddr *)&sourceAddress, &addressLength);

            if (msgLength < 0)
                DDLogError(@"%@\n\terror receving: %d - %s", ClassTagSelectorString, errno, strerror(errno));
            else {
                NSString * message = @(charBuffer);

                NSLog(@"message received:\n%@\nlength:%d\n", message, msgLength);
                if (receiveCallback != nil) receiveCallback(message);
            }

            free(charBuffer);
        };

        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(self.queue, listenHandler);

/*
 *      self.channel = dispatch_io_create(DISPATCH_IO_STREAM,
 *                                        socketDescriptor,
 *                                        self.queue,
 *                                        ^(int error)
 *                                          {
 *                                              DDLogError(@"dispatch io error on closing:%d",
 * error);
 *                                              if (error == 0) { self.channel = nil; }
 *                                          }
 *                                        );
 *
 *
 *      dispatch_io_handler_t handler = ^(bool done, dispatch_data_t data, int error) {
 *          NSLog(@"data received...");
 *          NSMutableString * dataRead = [[NSMutableString alloc] init];
 *          // Build strings from the data.
 *          dispatch_data_apply(data,
 *                              (dispatch_data_applier_t)^(dispatch_data_t region,
 *                                                         size_t offset,
 *                                                         const void *buffer,
 *                                                         size_t size)
 *                                  {
 *                                      NSString * s = [[NSString alloc] initWithBytes:buffer
 *                                                                              length:size
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *                                                                   encoding:NSUTF8StringEncoding];
 *                                      [dataRead appendString:s];
 *                                      return true;
 *                                  }
 *                              );
 *          NSLog(@"%@ data read:\n%@", ClassTagSelectorString, dataRead);
 *      };
 *
 *      dispatch_io_read(self.channel, 0, SIZE_MAX, self.queue, handler);
 *
 */
    }

    _listen = listen;
}

@end
