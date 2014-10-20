//
//  MSViewController.m
//  iTachClient
//
//  Created by Jason Cardwell on 9/8/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "MSViewController.h"
#import <netdb.h>
@import MoonKit;

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

static NSString * kTCPPort      = @"4998";
static NSString * kGroupAddress = @"239.255.250.250";
static NSString * kGroupPort    = @"9131";

@interface MSViewController () <UITextViewDelegate, GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UILabel            * headerLabel;
@property (weak, nonatomic) IBOutlet UILabel            * addressLabel;
@property (weak, nonatomic) IBOutlet UILabel            * addressValue;
@property (weak, nonatomic) IBOutlet UILabel            * portLabel;
@property (weak, nonatomic) IBOutlet UILabel            * portValue;
@property (weak, nonatomic) IBOutlet UITextView         * messages;
@property (weak, nonatomic) IBOutlet UITextView         * commandLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * commandLineHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton           * sendRequestButton;

@property (strong, nonatomic) dispatch_source_t   groupSource;
@property (strong, nonatomic) GCDAsyncSocket    * tcpSocket;
@property (strong, nonatomic) dispatch_queue_t    tcpQueue;
@property (nonatomic) long nextTag;

- (IBAction)toggleCommandLineHeight:(UIButton *)sender;
- (IBAction)sendRequest:(UIButton *)sender;

@property (nonatomic, copy) NSString * location;

@end

@implementation MSViewController

/// viewDidLoad
- (void)viewDidLoad {
  [super viewDidLoad];

  // Visual stuff

  UIFont * headerFont = [UIFont fontWithName:@"User-BoldCameo" size:24.0];
  UIFont * labelFont  = [UIFont fontWithName:@"User-BoldCameo" size:15.0];
  UIFont * valueFont  = [UIFont fontWithName:@"User-Medium"    size:15.0];

  self.headerLabel.font = headerFont;

  self.addressLabel.font                 = labelFont;
  self.portLabel.font                    = labelFont;
  self.sendRequestButton.titleLabel.font = labelFont;
  self.addressValue.font                 = valueFont;
  self.portValue.font                    = valueFont;
  self.messages.font                     = valueFont;
  self.commandLine.font                  = valueFont;


  // Connection stuff

  self.addressValue.text = kGroupAddress;
  self.portValue.text    = kGroupPort;
  [self joinMulticastGroup];

}

/// setLocation:
/// @param location
- (void)setLocation:(NSString *)location {
  _location = [location copy];
  __weak MSViewController * weakself = self;

  if (StringIsNotEmpty(location)) {
    [MainQueue addOperationWithBlock:^{
      weakself.addressValue.text = location;
      weakself.portValue.text    = kTCPPort;
      dispatch_source_cancel(weakself.groupSource);
      [weakself connectToDevice];
    }];
  }

}

/// sendRequestWithText:
/// @param text
- (void)sendRequestWithText:(NSString *)text {

  if (self.tcpSocket && [self.tcpSocket isConnected]) {

    [self appendLogMessage:$(@"sending message '%@' with tag '%li'", [text stringByReplacingReturnsWithSymbol], _nextTag)];
    [self.tcpSocket writeData:[text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:30 tag:_nextTag++];

  }

}

/// appendLogMessage:
/// @param message
- (void)appendLogMessage:(NSString *)message {

  static NSDictionary    * msgAttrs = nil;
  static NSDictionary    * tmsAttrs = nil;

  static dispatch_once_t   onceToken;
  dispatch_once(&onceToken, ^{

    msgAttrs = @{ NSFontAttributeName : [UIFont fontWithName:@"User-Medium" size:15.0],
                  NSForegroundColorAttributeName : [WhiteColor colorWithAlphaComponent:0.75] };
    tmsAttrs = @{ NSFontAttributeName : [UIFont fontWithName:@"User-MediumCameo" size:14.0],
                  NSForegroundColorAttributeName : [WhiteColor colorWithAlphaComponent:0.5] };

  });

  [self appendString:message stringAttributes:msgAttrs timestampAttributes:tmsAttrs];

}

/// appendMessage:
/// @param message
- (void)appendMessage:(NSString *)message {

  assert(IsMainQueue);

  static NSDictionary    * msgAttrs = nil;
  static NSDictionary    * tmsAttrs = nil;
  static dispatch_once_t   onceToken;

  dispatch_once(&onceToken, ^{

    msgAttrs = @{ NSFontAttributeName : [UIFont fontWithName:@"User-Medium" size:15.0],
                  NSForegroundColorAttributeName : WhiteColor };

    tmsAttrs = @{ NSFontAttributeName : [UIFont fontWithName:@"User-MediumCameo" size:14.0],
                  NSForegroundColorAttributeName : WhiteColor };
  });

  [self appendString:message stringAttributes:msgAttrs timestampAttributes:tmsAttrs];

}

/// appendString:stringAttributes:timestampAttributes:
/// @param string
/// @param stringAttributes
/// @param timestampAttributes
- (void)appendString:(NSString *)string
    stringAttributes:(NSDictionary *)stringAttributes
 timestampAttributes:(NSDictionary *)timestampAttributes
{

  static NSDateFormatter * df = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{

    df = [NSDateFormatter new];
    [df setDateFormat:@"_H•mm•ss.SSS_"];

  });

  if (StringIsEmpty(string)) return;

  [MainQueue addOperationWithBlock:^{

    NSUInteger len = 0;

    NSString           * time     = [[df stringFromDate:[NSDate date]] stringByAppendingString:@"\n"];
    NSAttributedString * attrTime = [NSAttributedString attributedStringWithString:time
                                                                        attributes:timestampAttributes];

    len += [attrTime length];

    NSString           * msg     = [string stringByAppendingString:@"\n\n"];
    NSAttributedString * attrMsg = [NSAttributedString attributedStringWithString:msg
                                                                       attributes:stringAttributes];
    len += [attrMsg length];


    NSMutableAttributedString * attrTxt = [self.messages.attributedText mutableCopy];
    if (!attrTxt) attrTxt = [NSMutableAttributedString attributedStringWithString:@""];
    [attrTxt appendAttributedString:attrTime];
    [attrTxt appendAttributedString:attrMsg];
    self.messages.attributedText = attrTxt;

    NSRange vis = NSMakeRange(0, [attrTxt length]);
    vis.location = vis.length - len;
    vis.length   = len;

    [self.messages scrollRangeToVisible:vis];

  }];

}

/// joinMulticastGroup
- (void)joinMulticastGroup {

  dispatch_queue_t q = dispatch_queue_create("com.moondeerstudios.itachclient", DISPATCH_QUEUE_CONCURRENT);

  dispatch_fd_t fd = self.groupFileDescriptor;
  if (!fd > 0) return;

  self.groupSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, q);
  if (!self.groupSource) return;

  __weak MSViewController * weakself = self;

  // add event handler for multicast group message receiving
  dispatch_source_set_event_handler(_groupSource, ^{

    if (StringIsNotEmpty(weakself.location)) {
      return;
    }

    [MainQueue addOperationWithBlock:^{

      [weakself appendLogMessage:@"receiving beacon…"];

    }];

    ssize_t bytesAvailable = dispatch_source_get_data(weakself.groupSource);

    if (bytesAvailable) {

      char msg[bytesAvailable + 1];
      ssize_t bytesRead = read(fd, msg, bytesAvailable);

      if (bytesRead < 0) {

        NSLog(@"read failed: %i - %s", errno, strerror(errno));

        [MainQueue addOperationWithBlock:^{

          [weakself appendLogMessage:@"read failed, canceling…"];

        }];

        dispatch_source_cancel(weakself.groupSource);

      } else {

        msg[bytesAvailable] = '\0';
        NSString * message = @(msg);
        [MainQueue addOperationWithBlock:^{
          __strong NSString * messageCopy = [message copy];
          [weakself appendMessage:messageCopy];
        }];

        NSArray * entries = [message matchingSubstringsForRegEx:@"(?<=<-)(.*?)(?=>)"];
        MSDictionary * attributes = [MSDictionary dictionaryByParsingArray:entries separator:@"="];
        weakself.location = [attributes[@"Config-URL"] substringFromIndex:7];

      }
    }

  });

  // add cancel handler to clean up multicast group resources
  dispatch_source_set_cancel_handler(weakself.groupSource, ^{

    [MainQueue addOperationWithBlock:^{

      NSLog(@"closing multicast file descriptor…");
      [weakself appendLogMessage:@"leaving multicast group…"];
      close(fd);
      weakself.groupSource = nil;

    }];

  });

  // add registration handler to log setup completion of multicast group source
  dispatch_source_set_registration_handler(weakself.groupSource, ^{

    [MainQueue addOperationWithBlock:^{

      [weakself appendLogMessage:@"ready to receive"];
      NSLog(@"multicast source setup complete");

    }];

  });

  // resume the multicast group source to connect and begin receiving beacons
  [self appendLogMessage:@"joining multicast group…"];
  dispatch_resume(self.groupSource);


}

/// connectToDevice
- (void)connectToDevice {

  assert(self.tcpSocket == nil);
  assert(IsMainQueue);

  [self appendLogMessage:@"connecting to device…"];
  
  self.tcpQueue = dispatch_queue_create("com.moondeerstudios.itachclient.tcp", DISPATCH_QUEUE_CONCURRENT);
  self.tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.tcpQueue];
  NSError * error = nil;
  [self.tcpSocket connectToHost:self.addressValue.text onPort:[self.portValue.text intValue] error:&error];
  MSHandleErrors(error);
  [self.tcpSocket readDataToData:[@"\r" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 buffer:nil bufferOffset:0 maxLength:0 tag:1];

}

/// groupFileDescriptor
/// @return dispatch_fd_t
- (dispatch_fd_t)groupFileDescriptor {

  // Get the address info

  struct sockaddr * socketAddress;
  socklen_t         socketAddressLength = 0;
  int               error;
  struct addrinfo   socketHints, * resolve;

  memset(&socketHints, 0, sizeof(struct addrinfo));
  socketHints.ai_family   = AF_UNSPEC;
  socketHints.ai_socktype = SOCK_DGRAM;

  const char * address = [self.addressValue.text UTF8String];
  const char * port    = [self.portValue.text UTF8String];

  error = getaddrinfo(address, port, &socketHints, &resolve);

  if (error) {

    NSLog(@"error getting address info for %s, %s: %s", address, port, gai_strerror(error));
    return -1;

  }

  // Resolve into a useable socket

  dispatch_fd_t socketFileDescriptor = -1;

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

  // Join multicast group

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



////////////////////////////////////////////////////////////////////////////////
#pragma mark - GCDAsyncSocketDelegate
////////////////////////////////////////////////////////////////////////////////


/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 *
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 *
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {

}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  __weak MSViewController * weakself = self;
  [MainQueue addOperationWithBlock:^{
    [weakself appendLogMessage:@"connected to device"];
  }];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  __weak MSViewController * weakself = self;
  [MainQueue addOperationWithBlock:^{
    [weakself appendLogMessage:$(@"message with tag '%li' was received:\n%@", tag, [NSString stringWithData:data])];
  }];

  [sock readDataToData:[@"\r" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 buffer:nil bufferOffset:0 maxLength:0 tag:_nextTag];
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {

}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  __weak MSViewController * weakself = self;
  [MainQueue addOperationWithBlock:^{
    [weakself appendLogMessage:$(@"message sent with tag '%li'", tag)];
  }];
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {

}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
- (NSTimeInterval)  socket:(GCDAsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length {
  return 0;
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
  return 0;
}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {

}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  __weak MSViewController * weakself = self;
  [MainQueue addOperationWithBlock:^{
    [weakself appendLogMessage:@"disconnected from device"];
    MSHandleErrors(err);
  }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate
////////////////////////////////////////////////////////////////////////////////


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  nsprintf(@"finished edting command line\n");
}

- (void)textViewDidChange:(UITextView *)textView {

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - IBActions
////////////////////////////////////////////////////////////////////////////////


/// toggleCommandLineHeight:
/// @param sender
- (IBAction)toggleCommandLineHeight:(UIButton *)sender {

  self.commandLineHeightConstraint.constant = (sender.selected ? 20.0 : 200.0);
  sender.selected = !sender.selected;

}

/// sendRequest:
/// @param sender
- (IBAction)sendRequest:(UIButton *)sender {

  NSString * text = self.commandLine.text;

  if (StringIsNotEmpty(text))
    [self sendRequestWithText:[text stringByAppendingString:@"\r"]];

  // Clear command line
  self.commandLine.text = nil;
}

@end
