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

/*

 SOAP
 ––––

 To turn off a light:

 POST /services HTTP/1.1
 HOST: 192.168.1.9
 Content-Length: 239
 Authorization: Basic bW9vbmRlZXI6MWJsdWViZWFy
 Content-Type: text/xml; charset="utf-8"
 SOAPACTION:"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService"

 <s:Envelope>
  <s:Body>
    <u:UDIService xmlns:u="urn:udi-com:service:X_Insteon_Lighting_Service:1">
      <control>DOF</control>
      <action></action>
      <flag>65531</flag>
      <node>1B 6E B2 1</node>
    </u:UDIService>
  </s:Body>
 </s:Envelope>

 To rename a node:

 POST /services HTTP/1.1
 HOST: 192.168.1.9
 Content-Length: 239
 Authorization: Basic bW9vbmRlZXI6MWJsdWViZWFy
 Content-Type: text/xml; charset="utf-8"
 SOAPACTION:"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService"

 <s:Envelope>
   <s:Body>
     <u:RenameNode xmlns:u="urn:udi-com:service:X_Insteon_Lighting_Service:1">
       <id>1B 6E B2 1</id>
       <name>Front Door Table Lamp</name>
     </u:RenameNode>
   </s:Body>
 </s:Envelope>


 REST
 ––––

 To turn on a light:

 http://192.168.1.9/rest/nodes/1B%206E%20B2%201/cmd/DON



 */

@interface ISYDevice ()

@property (nonatomic, copy,   readwrite) NSString * modelNumber;
@property (nonatomic, copy,   readwrite) NSString * modelName;
@property (nonatomic, copy,   readwrite) NSString * modelDescription;
@property (nonatomic, copy,   readwrite) NSString * manufacturerURL;
@property (nonatomic, copy,   readwrite) NSString * manufacturer;
@property (nonatomic, copy,   readwrite) NSString * friendlyName;
@property (nonatomic, copy,   readwrite) NSString * deviceType;
@property (nonatomic, copy,   readwrite) NSString * baseURL;
@property (nonatomic, strong, readwrite) NSSet    * nodes;

@end

@interface ISYDevice (CoreDataGenerated)

@property (nonatomic) NSString     * primitiveModelNumber;
@property (nonatomic) NSString     * primitiveModelName;
@property (nonatomic) NSString     * primitiveModelDescription;
@property (nonatomic) NSString     * primitiveManufacturerURL;
@property (nonatomic) NSString     * primitiveManufacturer;
@property (nonatomic) NSString     * primitiveFriendlyName;
@property (nonatomic) NSString     * primitiveDeviceType;
@property (nonatomic) NSString     * primitiveBaseURL;
@property (nonatomic) NSMutableSet * primitiveNodes;

@end

@implementation ISYDevice

@dynamic modelNumber, modelName, modelDescription;
@dynamic manufacturerURL, manufacturer;
@dynamic friendlyName, deviceType, baseURL;
@dynamic nodes;

/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  return dictionary;

}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ISYDeviceNode
////////////////////////////////////////////////////////////////////////////////


@interface ISYDeviceNode ()

@property (nonatomic, copy,   readwrite) NSNumber  * flag;
@property (nonatomic, copy,   readwrite) NSString  * address;
@property (nonatomic, copy,   readwrite) NSString  * type;
@property (nonatomic, copy,   readwrite) NSNumber  * enabled;
@property (nonatomic, copy,   readwrite) NSString  * pnode;
@property (nonatomic, copy,   readwrite) NSString  * propertyID;
@property (nonatomic, copy,   readwrite) NSString  * propertyValue;
@property (nonatomic, copy,   readwrite) NSString  * propertyUOM;
@property (nonatomic, copy,   readwrite) NSString  * propertyFormatted;
@property (nonatomic, strong, readwrite) ISYDevice * device;

@end

@interface ISYDeviceNode (CoreDataGenerated)

@property (nonatomic) NSNumber  * primitiveFlag;
@property (nonatomic) NSString  * primitiveAddress;
@property (nonatomic) NSString  * primitiveType;
@property (nonatomic) NSNumber  * primitiveEnabled;
@property (nonatomic) NSString  * primitivePnode;
@property (nonatomic) NSString  * primitivePropertyID;
@property (nonatomic) NSString  * primitivePropertyValue;
@property (nonatomic) NSString  * primitivePropertyUOM;
@property (nonatomic) NSString  * primitivePropertyFormatted;
@property (nonatomic) ISYDevice * primitiveDevice;

@end

@implementation ISYDeviceNode

@dynamic flag, address, type, enabled, pnode;
@dynamic propertyID, propertyValue, propertyUOM, propertyFormatted;
@dynamic device;


/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  return dictionary;

}

@end

@interface ISYDeviceGroup ()

@property (nonatomic, copy,   readwrite) NSNumber  * flag;
@property (nonatomic, copy,   readwrite) NSString  * address;
@property (nonatomic, copy,   readwrite) NSNumber  * family;
@property (nonatomic, strong, readwrite) NSSet     * members;

@end

@interface ISYDeviceGroup (CoreDataGenerated)

@property (nonatomic) NSNumber     * primitiveFlag;
@property (nonatomic) NSString     * primitiveAddress;
@property (nonatomic) NSNumber     * primitiveFamily;
@property (nonatomic) NSMutableSet * primitiveMembers;

@end

@implementation ISYDeviceGroup

@dynamic flag, address, family, members;


/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  return dictionary;

}

@end


