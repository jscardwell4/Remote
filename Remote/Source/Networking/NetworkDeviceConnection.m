//
//  NetworkDeviceConnection.m
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
#import "ConnectionManager.h"
#import "NetworkDeviceConnection_Subclass.h"
#import "NetworkDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


@implementation MessageQueueEntry

+ (instancetype)entryWithMessage:(NSString *)message
                      completion:(void(^)(BOOL success, NSError * error))completion
{
  if (StringIsEmpty(message)) ThrowInvalidNilArgument(message);
  MessageQueueEntry * entry = [self new];
  entry.message = message;
  entry.completion = completion;

  return entry;
}

@end

@interface NetworkDeviceConnection ()
@property (assign) int sourcesRegistered;
@end

@implementation NetworkDeviceConnection

/**

 Method for creating a new `NetworkDeviceConnection` for connecting to the specified `device`.

 @param device The device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `NetworkDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(NetworkDevice *)device
                           delegate:(id<NetworkDeviceConnectionDelegate>)delegate
{
  if (!device) ThrowInvalidNilArgument(device);

	NetworkDeviceConnection * connection = [self new];
	connection.device = device;
	connection.delegate = delegate;

	return connection;
}

- (instancetype)init {

  if ((self = [super init])) {
    self.messageQueue = [MSQueue queue];
  }

  return self;

}

/**

 Commence communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)connect:(void (^)(BOOL success, NSError * error))completion {

  MSLogInfoTag(@"");
  
  // Exit early if an attempt to connect is already in progress
  if (self.isConnecting) {
    MSLogWarnTag(@"already trying to connect");
    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorConnectionInProgress
                                                   userInfo:nil]);
    return;
  }

  // Or if we are already connected
  else if (  (self.readSource && !dispatch_source_testcancel(self.readSource))
           || (self.writeSource && !dispatch_source_testcancel(self.writeSource)))
  {
    MSLogWarnTag(@"already connected to device");
    if (completion) completion(YES, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                        code:ConnectionManagerErrorConnectionExists
                                                    userInfo:nil]);
    return;
  }

  // Otherwise set the flag
  else self.isConnecting = YES;

  self.connectCallback = completion;

  // Get file descriptors and queues for sources
  dispatch_fd_t    sourceFileDescriptor = [self sourceFileDescriptor];
  dispatch_queue_t readQueue          = [self readSourceQueue];

  dispatch_queue_t writeQueue          = [self writeSourceQueue];

  __weak NetworkDeviceConnection * weakself = self;

  if (sourceFileDescriptor >= 0 && readQueue != NULL) {

	  self.readSource  = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,  sourceFileDescriptor, 0, readQueue);

		dispatch_block_t readEventHandler = [self readEventHandler];
		if (readEventHandler)
			dispatch_source_set_event_handler(self.readSource, readEventHandler);


		dispatch_block_t readCancelHandler        = [self readCancelHandler];
		if (readCancelHandler)
			dispatch_source_set_cancel_handler(self.readSource, readCancelHandler);

		dispatch_block_t readRegistrationHandler  = [self readRegistrationHandler];
		if (readRegistrationHandler)
			dispatch_source_set_registration_handler(self.readSource, readRegistrationHandler);

		dispatch_resume(self.readSource);

  }

  if (sourceFileDescriptor >= 0 && writeQueue != NULL) {

	  self.writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, sourceFileDescriptor, 0, writeQueue);

		dispatch_block_t writeEventHandler = [self writeEventHandler];
		if (writeEventHandler)
			dispatch_source_set_event_handler(self.writeSource, writeEventHandler);


		dispatch_block_t writeCancelHandler        = [self writeCancelHandler];
		if (writeCancelHandler)
			dispatch_source_set_cancel_handler(self.writeSource, writeCancelHandler);

		dispatch_block_t writeRegistrationHandler  = [self writeRegistrationHandler];
		if (writeRegistrationHandler)
			dispatch_source_set_registration_handler(self.writeSource, writeRegistrationHandler);

		dispatch_resume(self.writeSource);

  }


}

- (dispatch_fd_t)sourceFileDescriptor { return -1; }

- (dispatch_queue_t)readSourceQueue  {
  static dispatch_once_t onceToken;
  static dispatch_queue_t queue;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("com.moondeerstudios.receive", DISPATCH_QUEUE_CONCURRENT);
  });
	return queue;
}

- (dispatch_queue_t)writeSourceQueue {
  static dispatch_once_t onceToken;
  static dispatch_queue_t queue;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("com.moondeerstudios.send", DISPATCH_QUEUE_CONCURRENT);
  });
	return queue;
}

- (dispatch_block_t)readEventHandler {

	__weak NetworkDeviceConnection * weakself = self;

	dispatch_block_t handler = ^{

	  ssize_t bytesAvailable = dispatch_source_get_data(weakself.readSource);
	  char msg[bytesAvailable + 1];
	  ssize_t bytesRead = read((int)dispatch_source_get_handle(weakself.readSource), msg, bytesAvailable);

	  if (bytesRead < 0) {

	    MSLogErrorWeakTag(@"read failed for socket: %i - %s", errno, strerror(errno));
	    dispatch_source_cancel(weakself.readSource);

	  } else {

	    msg[bytesAvailable] = '\0';
      NSString * message = @(msg);

	    if (weakself.delegate)
	      [MainQueue addOperationWithBlock:^{
            [weakself.delegate messageReceived:message overConnection:weakself];
	      }];

	  }

	};

	return handler;

}

- (dispatch_block_t)writeEventHandler {

  __weak NetworkDeviceConnection * weakself = self;

  dispatch_block_t handler = ^{

    // Exit early if the queue is empty
    if (![weakself.messageQueue isEmpty]) {

      BOOL success = YES;
      NSError * error = nil;

      // Dequeue an entry
      MessageQueueEntry * entry = [weakself.messageQueue dequeue];

      NSString * message = entry.message;
      assert(StringIsNotEmpty(message));

      ssize_t bytesWritten = write((int)dispatch_source_get_handle(weakself.writeSource),
                                   [message UTF8String], [message length]);

      // Check if string was written
      if (bytesWritten < 0) {

        MSLogErrorWeakTag(@"write failed for socket: %i - %s", errno, strerror(errno));
        success = NO;
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];

        dispatch_source_cancel(weakself.writeSource);

      }

      // Invoke completion block if set
      if (entry.completion) entry.completion(success, error);

    }


  };

  return handler;

}
- (dispatch_block_t)readCancelHandler {

	__weak NetworkDeviceConnection * weakself = self;

	dispatch_block_t handler = ^{

		weakself.sourcesRegistered = weakself.sourcesRegistered - 1;

    close((int)dispatch_source_get_handle(weakself.readSource));

    weakself.readSource = nil;

    if (weakself.writeSource && !dispatch_source_testcancel(weakself.writeSource))
      dispatch_source_cancel(weakself.writeSource);

    else
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

	};

	return handler;

}

- (dispatch_block_t)writeCancelHandler {

	__weak NetworkDeviceConnection * weakself = self;

	dispatch_block_t handler = ^{

		weakself.sourcesRegistered = weakself.sourcesRegistered - 1;

    close((int)dispatch_source_get_handle(weakself.writeSource));

    weakself.writeSource = nil;

    if (weakself.readSource && !dispatch_source_testcancel(weakself.readSource))
      dispatch_source_cancel(weakself.readSource);

    else
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

	};

	return handler;

}

- (dispatch_block_t)readRegistrationHandler  {

	__weak NetworkDeviceConnection * weakself = self;

	dispatch_block_t handler = ^{

		weakself.sourcesRegistered = weakself.sourcesRegistered + 1;

		if (weakself.sourcesRegistered == 2) {

			weakself.isConnecting = NO;
			[MainQueue addOperationWithBlock:^{

				if (weakself.connectCallback) weakself.connectCallback(YES, nil);
				if (weakself.delegate) [weakself.delegate deviceConnected:weakself];

			}];

		}

	};

	return handler;

}

- (dispatch_block_t)writeRegistrationHandler {

	__weak NetworkDeviceConnection * weakself = self;

	dispatch_block_t handler = ^{

		weakself.sourcesRegistered = weakself.sourcesRegistered + 1;

		if (weakself.sourcesRegistered == 2) {

			weakself.isConnecting = NO;
			[MainQueue addOperationWithBlock:^{

				if (weakself.connectCallback) weakself.connectCallback(YES, nil);
				if (weakself.delegate) [weakself.delegate deviceConnected:weakself];

			}];

		}

	};

	return handler;

}



/**

 Ends communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)disconnect:(void (^)(BOOL success, NSError * error))completion {
  MSLogInfoTag(@"");

  self.disconnectCallback = completion;

  if (!dispatch_source_testcancel(self.readSource)) dispatch_source_cancel(self.readSource);
	if (!dispatch_source_testcancel(self.writeSource)) dispatch_source_cancel(self.writeSource);

}

/// Whether the connection has been successfully established and is available for send operations.
- (BOOL)isConnected {

	return (   self.readSource && !dispatch_source_testcancel(self.readSource)
	        && self.writeSource && !dispatch_source_testcancel(self.writeSource)   );

}


/// Disposes of dispatch sources before being deallocated
- (void)dealloc { [self disconnect:nil]; }

@end
