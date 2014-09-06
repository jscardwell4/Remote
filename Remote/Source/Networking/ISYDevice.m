//
//  ISYDevice.m
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ISYDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSSTRING_CONST ISYDeviceMulticastGroupAddress = @"239.255.255.250";
MSSTRING_CONST ISYDeviceMulticastGroupPort    = @"1900";

@interface ISYDevice ()

@property (nonatomic, copy, readwrite) NSString * modelNumber;
@property (nonatomic, copy, readwrite) NSString * modelName;
@property (nonatomic, copy, readwrite) NSString * modelDescription;
@property (nonatomic, copy, readwrite) NSString * manufacturerURL;
@property (nonatomic, copy, readwrite) NSString * manufacturer;
@property (nonatomic, copy, readwrite) NSString * friendlyName;
@property (nonatomic, copy, readwrite) NSString * deviceType;
@property (nonatomic, copy, readwrite) NSString * presentationURL;
@property (nonatomic, copy, readwrite) NSString * baseURL;

@end

@interface ISYDevice (CoreDataGenerated)

@property (nonatomic) NSString * primitiveModelNumber;
@property (nonatomic) NSString * primitiveModelName;
@property (nonatomic) NSString * primitiveModelDescription;
@property (nonatomic) NSString * primitiveManufacturerURL;
@property (nonatomic) NSString * primitiveManufacturer;
@property (nonatomic) NSString * primitiveFriendlyName;
@property (nonatomic) NSString * primitiveDeviceType;
@property (nonatomic) NSString * primitivePresentationURL;
@property (nonatomic) NSString * primitiveBaseURL;

@end

/*
 
 example of turning on a light: http://192.168.1.9/rest/nodes/1B%206E%20B2%201/cmd/DON
 in a pinch you can use http://username:password@192.168.1.9/rest/nodes/1B%206E%20B2%201/cmd/DON

 */

@implementation ISYDevice

@dynamic modelNumber, modelName, modelDescription;
@dynamic manufacturerURL, manufacturer;
@dynamic friendlyName, deviceType, presentationURL, baseURL;

/// deviceFromLocation:context:completion:
/// @param location description
/// @param moc description
/// @param completion description
+ (void)deviceFromLocation:(NSString *)location
                   context:(NSManagedObjectContext *)moc
                completion:(void(^)(ISYDevice * device, NSError * error))completion
{

  if (StringIsEmpty(location)) ThrowInvalidNilArgument(location);
  if (!moc) ThrowInvalidNilArgument(moc);

  // Create request with location url
  NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:location]];

  // Get the device description
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:MainQueue
                         completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
   {

     [moc performBlock:^{

       // Proceed if there were no errors and we have data to parse
       if (!error && [response isKindOfClass:[NSHTTPURLResponse class]] && data) {

         // Parse the xml for device attributes

         MSDictionary * parsedXML = [MSDictionary dictionaryByParsingXML:data];

         MSLogInfo(@"parsedXML:\n%@", [parsedXML formattedDescription]);

         // Convert parsed attributes into compatible key-value dictionary
         NSDictionary * attributes = @{ @"modelNumber"      : CollectionSafe(parsedXML[@"device"][@"modelNumber"]),
                                        @"modelName"        : CollectionSafe(parsedXML[@"device"][@"modelName"]),
                                        @"modelDescription" : CollectionSafe(parsedXML[@"device"][@"modelDescription"]),
                                        @"manufacturerURL"  : CollectionSafe(parsedXML[@"device"][@"manufacturerURL"]),
                                        @"manufacturer"     : CollectionSafe(parsedXML[@"device"][@"manufacturer"]),
                                        @"friendlyName"     : CollectionSafe(parsedXML[@"device"][@"friendlyName"]),
                                        @"deviceType"       : CollectionSafe(parsedXML[@"device"][@"deviceType"]),
                                        @"presentationURL"  : CollectionSafe(parsedXML[@"device"][@"presentationURL"]),
                                        @"uniqueIdentifier" : CollectionSafe(parsedXML[@"device"][@"UDN"]),
                                        @"baseURL"          : CollectionSafe(parsedXML[@"URLBase"]) };

         // First try fetching by the unique identifier
         NSString * value = attributes[@"uniqueIdentifier"];
         ISYDevice * device = [NetworkDevice findFirstByAttribute:@"uniqueIdentifier"
                                                    withValue:value
                                                    inContext:moc];

         // Create a new device if needed
         if (!device) device = [ISYDevice createInContext:moc];

         // Set the device's attributes from the data obtained
         [device setValuesForKeysWithDictionary:attributes];

         //TODO: Here is where we need to prompt for the user name and password for the device
         NSString * userName = @"moondeer";
         NSString * password = @"1bluebear";
         NSString * userNameAndPassword = [@":" join:@[userName, password]];
         NSString * base64UserNameAndPassword = [[userNameAndPassword dataUsingEncoding:NSUTF8StringEncoding]
                                                 base64EncodedStringWithOptions:0];

         NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:$(@"%@/rest/config", device.baseURL)]];
         //TODO: Need to use a delegate and see if that works, or try RestKit or AFNetworking
         [request setValue:$(@"Basic %@", base64UserNameAndPassword) forHTTPHeaderField:@"Authorization"];
         [NSURLConnection sendAsynchronousRequest:request queue:MainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

           nsprintf(@"response: %@\n", response);
           if (data) {
             NSString * dataString = [NSString stringWithData:data];
             if (dataString) nsprintf(@"data:\n%@\n", dataString);
           }

         }];

         // Invoke completion block
         if (completion)
           [MainQueue addOperationWithBlock:^{ completion(device, error); }];

       }

       // Otherwise just invoke the completion block
       else if (completion) completion(nil, error);

     }];

   }];

}

/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

//  self.pcb_pn     = data[@"pcb_pn"];
//  self.pkg_level  = data[@"pkg_level"];
//  self.sdkClass   = data[@"sdk-class"];
//  self.make       = data[@"make"];
//  self.model      = data[@"model"];
//  self.status     = data[@"status"];
//  self.configURL  = data[@"config-url"];
//  self.revision   = data[@"revision"];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

//  SafeSetValueForKey(self.pcb_pn,     @"pcb_pn",      dictionary);
//  SafeSetValueForKey(self.pkg_level,  @"pkg_level",   dictionary);
//  SafeSetValueForKey(self.sdkClass,   @"sdk-class",   dictionary);
//  SafeSetValueForKey(self.make,       @"make",        dictionary);
//  SafeSetValueForKey(self.model,      @"model",       dictionary);
//  SafeSetValueForKey(self.status,     @"status",      dictionary);
//  SafeSetValueForKey(self.configURL,  @"configURL",   dictionary);
//  SafeSetValueForKey(self.revision,   @"revision",    dictionary);

  return dictionary;

}

@end
