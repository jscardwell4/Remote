//
//  ISYDevice.m
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ISYDevice.h"
#import "ISYDeviceConnection.h"

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


/* KeychainWrapper adapted from Keychain Services Programming Guide  */

@import Security;

//Define an Objective-C wrapper class to hold Keychain Services code.
@interface KeychainWrapper : NSObject

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)resetKeychainItem;

@end

/* ********************************************************************** */
//Unique string used to identify the keychain item:
static const UInt8 kKeychainItemIdentifier[]    = "com.apple.dts.KeychainUI\0";

@interface KeychainWrapper (PrivateMethods)


//The following two methods translate dictionaries between the format used by
// the view controller (NSString *) and the Keychain Services API:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
// Method used to write data to the keychain:
- (void)writeToKeychain;

@end

@implementation KeychainWrapper

- (id)init
{
  if ((self = [super init])) {

    OSStatus keychainErr = noErr;
    // Set up the keychain search dictionary:
    _genericPasswordQuery = [[NSMutableDictionary alloc] init];
    // This keychain item is a generic password.
    [_genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                             forKey:(__bridge id)kSecClass];
    // The kSecAttrGeneric attribute is used to store a unique string that is used
    // to easily identify and find this keychain item. The string is first
    // converted to an NSData object:
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier
                                            length:strlen((const char *)kKeychainItemIdentifier)];
    [_genericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    // Return the attributes of the first match only:
    [_genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    // Return the attributes of the keychain item (the password is
    //  acquired in the secItemFormatToDictionary: method):
    [_genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue
                             forKey:(__bridge id)kSecReturnAttributes];

    //Initialize the dictionary used to hold return data from the keychain:
    CFMutableDictionaryRef outDictionary = nil;
    // If the keychain item exists, return the attributes of the item:
    keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                                      (CFTypeRef *)&outDictionary);
    if (keychainErr == noErr) {
      // Convert the data dictionary into the format used by the view controller:
      self.keychainData = [self secItemFormatToDictionary:(__bridge_transfer NSMutableDictionary *)outDictionary];
    } else if (keychainErr == errSecItemNotFound) {
      // Put default values into the keychain if no matching
      // keychain item is found:
      [self resetKeychainItem];
      if (outDictionary) CFRelease(outDictionary);
    } else {
      // Any other error is unexpected.
      NSAssert(NO, @"Serious error.\n");
      if (outDictionary) CFRelease(outDictionary);
    }
  }
  return self;
}

// Implement the mySetObject:forKey method, which writes attributes to the keychain:
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
  if (obj == nil) return;
  id currentObject = [_keychainData objectForKey:key];
  if (![currentObject isEqual:obj])
  {
    [_keychainData setObject:obj forKey:key];
    [self writeToKeychain];
  }
}

// Implement the myObjectForKey: method, which reads an attribute value from a dictionary:
- (id)objectForKeyedSubscript:(id<NSCopying>)key { return [_keychainData objectForKey:key]; }

// Reset the values in the keychain item, or create a new item if it
// doesn't already exist:

- (void)resetKeychainItem
{
  if (!_keychainData) //Allocate the keychainData dictionary if it doesn't exist yet.
  {
    self.keychainData = [[NSMutableDictionary alloc] init];
  }
  else if (_keychainData)
  {
    // Format the data in the keychainData dictionary into the format needed for a query
    //  and put it into tmpDictionary:
    NSMutableDictionary *tmpDictionary =
    [self dictionaryToSecItemFormat:_keychainData];
    // Delete the keychain item in preparation for resetting the values:
    OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)tmpDictionary);
    NSAssert(errorcode == noErr, @"Problem deleting current keychain item." );
  }

  // Default generic data for Keychain Item:
  [_keychainData setObject:@"Item label" forKey:(__bridge id)kSecAttrLabel];
  [_keychainData setObject:@"Item description" forKey:(__bridge id)kSecAttrDescription];
  [_keychainData setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
  [_keychainData setObject:@"Service" forKey:(__bridge id)kSecAttrService];
  [_keychainData setObject:@"Your comment here." forKey:(__bridge id)kSecAttrComment];
  [_keychainData setObject:@"password" forKey:(__bridge id)kSecValueData];

}

// Implement the dictionaryToSecItemFormat: method, which takes the attributes that
// you want to add to the keychain item and sets up a dictionary in the format
// needed by Keychain Services:
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
  // This method must be called with a properly populated dictionary
  // containing all the right key/value pairs for a keychain item search.

  // Create the return dictionary:
  NSMutableDictionary *returnDictionary =
  [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

  // Add the keychain item class and the generic attribute:
  NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier
                                          length:strlen((const char *)kKeychainItemIdentifier)];
  returnDictionary[(__bridge id)kSecAttrGeneric] = keychainItemID;
  returnDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

  // Convert the password NSString to NSData to fit the API paradigm:
  NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
  returnDictionary[(__bridge id)kSecValueData] = [passwordString dataUsingEncoding:NSUTF8StringEncoding];

  return returnDictionary;
}

// Implement the secItemFormatToDictionary: method, which takes the attribute dictionary
//  obtained from the keychain item, acquires the password from the keychain, and
//  adds it to the attribute dictionary:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert {
  // This method must be called with a properly populated dictionary
  // containing all the right key/value pairs for the keychain item.

  // Create a return dictionary populated with the attributes:
  NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

  // To acquire the password data from the keychain item,
  // first add the search key and class attribute required to obtain the password:
  [returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
  [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

  // Then call Keychain Services to get the password:
  CFDataRef passwordData = NULL;
  OSStatus keychainError = noErr; //
  keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData);

  if (keychainError == noErr) {

    // Remove the kSecReturnData key; we don't need it anymore:
    [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];

    // Convert the password to an NSString and add it to the return dictionary:
    NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)passwordData bytes]
                                                  length:[(__bridge NSData *)passwordData length]
                                                encoding:NSUTF8StringEncoding];

    [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];

  }

  // Don't do anything if nothing is found.
  else if (keychainError == errSecItemNotFound) {

    NSAssert(NO, @"Nothing was found in the keychain.\n");
    if (passwordData) CFRelease(passwordData);

  }

  // Any other error is unexpected.
  else {

    NSAssert(NO, @"Serious error.\n");
    if (passwordData) CFRelease(passwordData);

  }

  return returnDictionary;
}

// Implement the writeToKeychain method, which is called by the mySetObject routine,
//   which in turn is called by the UI when there is new data for the keychain. This
//   method modifies an existing keychain item, or--if the item does not already
//   exist--creates a new keychain item with the new attribute value plus
//  default values for the other attributes.
- (void)writeToKeychain {

  CFDictionaryRef attributes = nil;
  NSMutableDictionary *updateItem = nil;

  // If the keychain item already exists, modify it:
  if (SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                          (CFTypeRef *)&attributes) == noErr)
  {
    // First, get the attributes returned from the keychain and add them to the
    // dictionary that controls the update:
    updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)attributes];

    // Second, get the class value from the generic password query dictionary and
    // add it to the updateItem dictionary:
    updateItem[(__bridge id)kSecClass] = _genericPasswordQuery[(__bridge id)kSecClass];

    // Finally, set up the dictionary that contains new values for the attributes:
    NSMutableDictionary *temp = [self dictionaryToSecItemFormat:_keychainData];
    //Remove the class--it's not a keychain attribute:
    [temp removeObjectForKey:(__bridge id)kSecClass];

    // You can update only a single keychain item at a time.
    OSStatus errorcode = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)temp);
    NSAssert(errorcode == noErr, @"Couldn't update the Keychain Item." );
  }

  else {
    // No previous item found; add the new item.
    // The new value was added to the keychainData dictionary in the mySetObject routine,
    // and the other values were added to the keychainData dictionary previously.
    // No pointer to the newly-added items is needed, so pass NULL for the second parameter:
    OSStatus errorcode = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:_keychainData],
                                    NULL);
    NSAssert(errorcode == noErr, @"Couldn't add the Keychain Item." );
    if (attributes) CFRelease(attributes);
  }

}


@end
