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
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSSTRING_CONST kInsteonServiceType = @"urn:udi-com:service:X_Insteon_Lighting_Service:1";
MSSTRING_CONST kXMLContentType     = @"text/xml; charset=\"utf-8\"";

MSSTRING_CONST kContentTypeField   = @"Content-Type";
MSSTRING_CONST kSoapActionField    = @"SOAPACTION";

MSSTRING_CONST kSoapControlURL     = @"services";

MSSTRING_CONST kPostMethod         = @"POST";
MSSTRING_CONST kGetMethod          = @"GET";

@interface ISYDeviceConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) ISYDevice       * device;
@property (nonatomic, strong, readwrite) NSURL           * baseURL;
@property (nonatomic, strong, readwrite) NSURLConnection * connection;
@property (nonatomic, strong, readwrite) NSMutableData   * dataReceived;
@property (nonatomic, strong, readwrite) MSDictionary    * dataParsed;

@property (nonatomic, copy,   readwrite) void (^requestCompletion)(BOOL, NSError *);

@end

@implementation ISYDeviceConnection

/// connectionForDevice:
/// @param device
/// @return instancetype
+ (instancetype)connectionForDevice:(ISYDevice *)device {

  if (!device) ThrowInvalidNilArgument(device);

  ISYDeviceConnection * connection = [self new];
  connection.device = device;

  return connection;

}

/// This method attempts to retrieve a device description using the url provided with which it can
/// build a new `ISYDevice`. If successful, the `completion` block is executed with the connection
/// passed as its parameter. If unsuccessful, the `completion` block is passed with a nil parameter.
///
/// @param baseURL The base url of the device to which a connection shall be made.
/// @param completion The block that receives the valid connection created, if successful
+ (void)connectionWithBaseURL:(NSURL *)baseURL completion:(void (^)(ISYDeviceConnection *))completion {

  if (!baseURL) ThrowInvalidNilArgument(baseURL);
  if (!completion) ThrowInvalidNilArgument(completion);

  ISYDeviceConnection * connection = [self new];
  connection.baseURL = baseURL;

  [connection sendRequestWithText:@"desc" completion:^(BOOL success, NSError *error) {

    if (success && [connection createDeviceFromDataParsed]) completion(connection);
    else completion(nil);

  }];

}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device management
////////////////////////////////////////////////////////////////////////////////


/// setDevice:
/// @param device
- (void)setDevice:(ISYDevice *)device {

  _device = device;

  if (_device) {

    if (_device.baseURL) {

      assert(!self.baseURL || [_device.baseURL isEqualToString:[self.baseURL absoluteString]]);
      self.baseURL = [NSURL URLWithString:_device.baseURL];

    }

    [self updateDeviceNodes];

  }

}


/// createDeviceFromDataParsed
/// @return BOOL
- (BOOL)createDeviceFromDataParsed {

  __block BOOL success = NO;

  if (self.dataParsed) {

    MSDictionary * desc = self.dataParsed;

    NSArray * keys = @[ @"URLBase",
                        @"deviceType",
                        @"manufacturer",
                        @"manufacturerURL",
                        @"modelDescription",
                        @"modelName",
                        @"modelNumber",
                        @"friendlyName",
                        @"UDN" ];

    MSDictionary * attributes =
    [MSDictionary dictionaryWithValuesForKeys:keys
                                   usingBlock:^NSString *(NSString * key) {
                                     return CollectionSafe(findFirstValueForKeyInContainer(key, desc));
                                   }];

    [attributes compact];

    if ([keys count] == [attributes count]) {


      [attributes replaceKey:@"URLBase" withKey:@"baseURL"];
      [attributes replaceKey:@"UDN" withKey:@"uniqueIdentifier"];


      NSArray * services = findValuesForKeyInContainer(@"serviceType", desc);
      if ([services containsObject:kInsteonServiceType]) {


        NSManagedObjectContext * moc = [CoreDataManager defaultContext];
        __weak ISYDeviceConnection * weakself = self;

        [moc performBlockAndWait:^{

          ISYDevice * device = [ISYDevice findFirstByAttribute:@"uniqueIdentifier"
                                                     withValue:attributes[@"uniqueIdentifier"]
                                                     context:moc];

          if (!device) device = [ISYDevice createInContext:moc];

          if (device) {

            [device setValuesForKeysWithDictionary:attributes];

            NSError * error = nil;

            BOOL saved = [moc save:&error];
            if (saved && !MSHandleErrors(error)) {

              weakself.device = device;
              success = YES;

            }

          }

        }];

      }

    }

  }

  return success;

}


/// updateDeviceNodes
- (void)updateDeviceNodes {

  if (self.device) {

    __weak ISYDeviceConnection * weakself = self;

    [self sendRequestWithText:@"rest/nodes" completion:^(BOOL success, NSError *error) {

      if (success && !MSHandleErrors(error) && weakself.dataParsed) {

        NSManagedObjectContext * moc = [CoreDataManager defaultContext];

        [moc performBlock:^{

          NSArray * nodes  = findFirstValueForKeyInContainer(@"node",  weakself.dataParsed);

          NSArray * attributeKeys = @[@"flag", @"address", @"type", @"enabled", @"pnode", @"name"];
          MSDictionary * nodeModels = [MSDictionary dictionary];

          for (MSDictionary * node in nodes) {

            NSString * propertyID        = node[@"property"][@"id"];
            NSString * propertyValue     = node[@"property"][@"value"];
            NSString * propertyUOM       = node[@"property"][@"uom"];
            NSString * propertyFormatted = node[@"property"][@"formatted"];

            assert(propertyID && propertyValue && propertyUOM && propertyFormatted);


            [node filter:^BOOL(id<NSCopying> key, id value) { return [attributeKeys containsObject:key]; }];

            node[@"propertyID"]        = propertyID;
            node[@"propertyValue"]     = @([propertyValue integerValue]);
            node[@"propertyUOM"]       = propertyUOM;
            node[@"propertyFormatted"] = propertyFormatted;
            node[@"device"]            = weakself.device;
            node[@"enabled"]           = ([node[@"enabled"] isEqualToString:@"true"] ? @YES : @NO);
            node[@"flag"]              = @([node[@"flag"] integerValue]);
            
            ISYDeviceNode * nodeModel = [ISYDeviceNode createInContext:moc];
            [nodeModel setValuesForKeysWithDictionary:node];

            nodeModels[nodeModel.address] = nodeModel;
            
          }

          NSError * error = nil;
          BOOL saved = [moc save:&error];

          if (MSHandleErrors(error)) error = nil;

          NSArray * groups = findFirstValueForKeyInContainer(@"group", weakself.dataParsed);
          attributeKeys = @[@"flag", @"address", @"name", @"family", @"members"];

          for (MSDictionary * group in groups) {

            [group filter:^BOOL(id<NSCopying> key, id value) { return [attributeKeys containsObject:key]; }];
            NSArray * members = group[@"members"][@"link"];
            if (members)
              group[@"members"] = [[members mapped:^ISYDeviceNode *(MSDictionary * member, NSUInteger idx) {
                return nodeModels[member[@"link"]];
              }] set];

            group[@"device"] = weakself.device;
            if (group[@"flag"])   group[@"flag"] = @([group[@"flag"] integerValue]);
            if (group[@"family"]) group[@"family"] = @([group[@"family"] integerValue]);

            ISYDeviceGroup * groupModel = [ISYDeviceGroup createInContext:moc];
            [groupModel setValuesForKeysWithDictionary:group];

          }

          saved = [moc save:&error];
          MSHandleErrors(error);

          assert(saved);

          nsprintf(@"%@", weakself.device.JSONString);

        }];

      }

    }];


  }

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending
////////////////////////////////////////////////////////////////////////////////


/// sendRequestWithText:
/// @param text
- (void)sendRequestWithText:(NSString *)text
                 completion:(void(^)(BOOL success, NSError * error))completion
{

  NSURL * url = [NSURL URLWithString:text relativeToURL:self.baseURL];
  NSURLRequest * request = [NSURLRequest requestWithURL:url];
  self.requestCompletion = completion;
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];

}

/// sendRequestWithRequest:
/// @param request
- (void)sendRequestWithRequest:(NSURLRequest *)request
                    completion:(void(^)(BOOL success, NSError * error))completion
{
  self.requestCompletion = completion;
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}


/// sendRestCommand:toNode:parameters:completion:
/// @param command
/// @param nodeID
/// @param parameters
/// @param completion
- (void)sendRestCommand:(NSString *)command
                 toNode:(NSString *)nodeID
             parameters:(NSArray *)parameters
             completion:(void (^)(BOOL success, NSError * error))completion
{

  NSString * text = $(@"rest/nodes/%@/cmd/%@%@",
                      nodeID,
                      command,
                      ([parameters count]
                       ? $(@"/%@", [parameters componentsJoinedByString:@"/"])
                       : @""));

  [self sendRequestWithText:[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                 completion:completion];

}

/// sendSoapCommandWithBody:completion:
/// @param body
/// @param completion
- (void)sendSoapCommandWithBody:(NSString *)body completion:(void(^)(BOOL success, NSError * error))completion {

  if (StringIsEmpty(body)) ThrowInvalidNilArgument(body);

  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSoapControlURL
                                                                             relativeToURL:self.baseURL]];
  [request setHTTPMethod:kPostMethod];
  [request setValue:kXMLContentType forHTTPHeaderField:kContentTypeField];
  [request setValue:$(@"\"%@#UDIService\"", kInsteonServiceType) forHTTPHeaderField:kSoapActionField];

  [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

  [self sendRequestWithRequest:request completion:completion];

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////////////


/// connection:didFailWithError:
/// @param connection
/// @param error
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (self.requestCompletion) self.requestCompletion(NO, error);
}

/// connection:willSendRequestForAuthenticationChallenge:
/// @param connection
/// @param challenge
- (void)                         connection:(NSURLConnection *)connection
  willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  NSURLCredential * credential = [NSURLCredential credentialWithUser:@"moondeer"
                                                            password:@"1bluebear"
                                                         persistence:NSURLCredentialPersistenceForSession];
  [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDataDelegate
////////////////////////////////////////////////////////////////////////////////


/// connection:didReceiveData:
/// @param connection
/// @param data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

  if (!self.dataReceived) self.dataReceived = [NSMutableData dataWithData:data];
  else [self.dataReceived appendData:data];

}

/// connectionDidFinishLoading:
/// @param connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

  if (self.dataReceived) {

    self.dataParsed = [MSDictionary dictionaryByParsingXML:self.dataReceived];
    self.dataReceived = nil;

  }

  if (self.requestCompletion) self.requestCompletion(YES, nil);

}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////////////


/// isEqual:
/// @param other
/// @return BOOL
- (BOOL)isEqual:(ISYDeviceConnection *)other {

  if (other == self)               return YES;
  else if (![super isEqual:other]) return NO;
  else                             return [other.baseURL isEqual:self.baseURL];

}

/// hash
/// @return NSUInteger
- (NSUInteger)hash { return [self.baseURL hash]; }

@end
