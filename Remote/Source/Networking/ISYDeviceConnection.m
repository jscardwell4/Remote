//
//  ISYDeviceConnection.m
//  Remote
//
//  Created by Jason Cardwell on 9/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import CoreData;
#import "ISYDeviceConnection.h"
#import "ISYDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface ISYDeviceConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) ISYDevice * device;

@end

@implementation ISYDeviceConnection

/// connectionForDevice:
/// @param device description
/// @return instancetype
+ (instancetype)connectionForDevice:(ISYDevice *)device {

  if (!device) ThrowInvalidNilArgument(device);

  ISYDeviceConnection * connection = [self new];
  connection.device = device;

  return connection;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////////////


/// connection:didFailWithError:
/// @param connection description
/// @param error description
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  MSHandleErrors(error);
}

/// connection:willSendRequestForAuthenticationChallenge:
/// @param connection description
/// @param challenge description
- (void)                         connection:(NSURLConnection *)connection
  willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  MSLogDebug(@"challenge: %@", [challenge debugDescription]);
  NSURLCredential * credential = [NSURLCredential credentialWithUser:@"moondeer"
                                                            password:@"1bluebear"
                                                         persistence:NSURLCredentialPersistenceForSession];
  [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDataDelegate
////////////////////////////////////////////////////////////////////////////////


/// connection:didReceiveData:
/// @param connection description
/// @param data description
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

  MSDictionary * parsedXML = [MSDictionary dictionaryByParsingXML:data];
  MSLogDebug(@"parsed response: %@", [parsedXML formattedDescription]);

}


@end
