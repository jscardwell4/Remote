//
//  ISYDevice.m
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ISYDevice.h"
#import "ISYDeviceConnection.h"
#import "ISYDeviceDetailViewController.h"

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
@property (nonatomic, strong, readwrite) NSSet    * groups;

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
@property (nonatomic) NSMutableSet * primitiveGroups;

@end

@implementation ISYDevice

@dynamic modelNumber, modelName, modelDescription;
@dynamic manufacturerURL, manufacturer;
@dynamic friendlyName, deviceType, baseURL;
@dynamic nodes, groups;

/// detailViewController
/// @return ISYDeviceDetailViewController *
- (ISYDeviceDetailViewController *)detailViewController {
  return [ISYDeviceDetailViewController controllerWithItem:self];
}

/// editingViewController
/// @return ISYDeviceDetailViewController *
- (ISYDeviceDetailViewController *)editingViewController {
  return [ISYDeviceDetailViewController controllerWithItem:self editing:YES];
}


/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

	self.modelNumber      = (data[@"model-number"]      ?: self.modelNumber     );
	self.modelName        = (data[@"model-name"]        ?: self.modelName       );
	self.modelDescription = (data[@"model-description"] ?: self.modelDescription);
	self.manufacturerURL  = (data[@"manufacturer-url"]  ?: self.manufacturerURL );
	self.manufacturer     = (data[@"manufacturer"]      ?: self.manufacturer    );
	self.friendlyName     = (data[@"friendly-name"]     ?: self.friendlyName    );
	self.deviceType       = (data[@"device-type"]       ?: self.deviceType      );
	self.baseURL          = (data[@"base-url"]          ?: self.baseURL         );

	NSArray * nodes = [ISYDeviceNode importObjectsFromData:data[@"nodes"] context:self.managedObjectContext];
	if ([nodes count]) self.nodes = [nodes set];


	NSArray * groups = [ISYDeviceGroup importObjectsFromData:data[@"groups"] context:self.managedObjectContext];
	if ([groups count]) self.groups = [groups set];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  dictionary[@"type"] = @"isy";

  SafeSetValueForKey(self.modelNumber,                                @"model-number",      dictionary);
  SafeSetValueForKey(self.modelName,                                  @"model-name",        dictionary);
  SafeSetValueForKey(self.modelDescription,                           @"model-description", dictionary);
  SafeSetValueForKey(self.manufacturerURL,                            @"manufacturer-url",  dictionary);
  SafeSetValueForKey(self.manufacturer,                               @"manufacturer",      dictionary);
  SafeSetValueForKey(self.friendlyName,                               @"friendly-name",     dictionary);
  SafeSetValueForKey(self.deviceType,                                 @"device-type",       dictionary);
  SafeSetValueForKey(self.baseURL,                                    @"base-url",          dictionary);
  SafeSetValueForKey([self valueForKeyPath:@"nodes.JSONDictionary"],  @"nodes",             dictionary);
  SafeSetValueForKey([self valueForKeyPath:@"groups.JSONDictionary"], @"groups",            dictionary);

  return dictionary;

}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ISYDeviceNode
////////////////////////////////////////////////////////////////////////////////


@interface ISYDeviceNode ()

@property (nonatomic, copy,   readwrite) NSNumber       * flag;
@property (nonatomic, copy,   readwrite) NSString       * address;
@property (nonatomic, copy,   readwrite) NSString       * type;
@property (nonatomic, copy,   readwrite) NSNumber       * enabled;
@property (nonatomic, copy,   readwrite) NSString       * pnode;
@property (nonatomic, copy,   readwrite) NSString       * propertyID;
@property (nonatomic, copy,   readwrite) NSString       * propertyValue;
@property (nonatomic, copy,   readwrite) NSString       * propertyUOM;
@property (nonatomic, copy,   readwrite) NSString       * propertyFormatted;
@property (nonatomic, strong, readwrite) ISYDevice      * device;
@property (nonatomic, strong, readwrite) NSSet          * groups;

@end

@interface ISYDeviceNode (CoreDataGenerated)

@property (nonatomic) NSNumber       * primitiveFlag;
@property (nonatomic) NSString       * primitiveAddress;
@property (nonatomic) NSString       * primitiveType;
@property (nonatomic) NSNumber       * primitiveEnabled;
@property (nonatomic) NSString       * primitivePnode;
@property (nonatomic) NSString       * primitivePropertyID;
@property (nonatomic) NSString       * primitivePropertyValue;
@property (nonatomic) NSString       * primitivePropertyUOM;
@property (nonatomic) NSString       * primitivePropertyFormatted;
@property (nonatomic) ISYDevice      * primitiveDevice;
@property (nonatomic) NSMutableSet   * primitiveGroups;

@end

@implementation ISYDeviceNode

@dynamic flag, address, type, enabled, pnode;
@dynamic propertyID, propertyValue, propertyUOM, propertyFormatted;
@dynamic device, groups;


/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

	self.flag              =  (data[@"flag"]               ?: self.flag             );
	self.address           =  (data[@"address"]            ?: self.address          );
	self.type              =  (data[@"type"]               ?: self.type             );
	self.enabled           =  (data[@"enabled"]            ?: self.enabled          );
	self.pnode             =  (data[@"pnode"]              ?: self.pnode            );
	self.propertyID        =  (data[@"property-id"]        ?: self.propertyID       );
	self.propertyValue     =  (data[@"property-value"]     ?: self.propertyValue    );
	self.propertyUOM       =  (data[@"property-uom"]       ?: self.propertyUOM      );
	self.propertyFormatted =  (data[@"property-formatted"] ?: self.propertyFormatted);
  self.groups = ([[[data[@"members"] mapped:^id (NSString * uuid, NSUInteger idx) {

  	return ([ISYDeviceGroup existingObjectWithUUID:uuid] ?: NullObject);

  }] compacted] set] ?: self.groups);

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.flag,                             @"flag",               dictionary);
  SafeSetValueForKey(self.address,                          @"address",            dictionary);
  SafeSetValueForKey(self.type,                             @"type",               dictionary);
  SafeSetValueForKey(self.enabled,                          @"enabled",            dictionary);
  SafeSetValueForKey(self.pnode,                            @"pnode",              dictionary);
  SafeSetValueForKey(self.propertyID,                       @"property-id",        dictionary);
  SafeSetValueForKey(self.propertyValue,                    @"property-value",     dictionary);
  SafeSetValueForKey(self.propertyUOM,                      @"property-uom",       dictionary);
  SafeSetValueForKey(self.propertyFormatted,                @"property-formatted", dictionary);
  SafeSetValueForKey(self.device.uuid,                      @"device.uuid",        dictionary);
  SafeSetValueForKey([self valueForKeyPath:@"groups.uuid"], @"groups",             dictionary);

  return dictionary;

}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ISYDeviceGroup
////////////////////////////////////////////////////////////////////////////////


@interface ISYDeviceGroup ()

@property (nonatomic, copy,   readwrite) NSNumber  * flag;
@property (nonatomic, copy,   readwrite) NSString  * address;
@property (nonatomic, copy,   readwrite) NSNumber  * family;
@property (nonatomic, strong, readwrite) NSSet     * members;
@property (nonatomic, strong, readwrite) ISYDevice * device;

@end

@interface ISYDeviceGroup (CoreDataGenerated)

@property (nonatomic) NSNumber     * primitiveFlag;
@property (nonatomic) NSString     * primitiveAddress;
@property (nonatomic) NSNumber     * primitiveFamily;
@property (nonatomic) NSMutableSet * primitiveMembers;
@property (nonatomic) ISYDevice    * primitiveDevice;

@end

@implementation ISYDeviceGroup

@dynamic flag, address, family, members, device;


/// updateWithData:
/// @param data description
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.flag    = (data[@"flag"]    ?: self.flag   );
  self.address = (data[@"address"] ?: self.address);
  self.family  = (data[@"family"]  ?: self.family );
  self.members = ([[[data[@"members"] mapped:^id (NSString * uuid, NSUInteger idx) {

  	return ([ISYDeviceNode existingObjectWithUUID:uuid] ?: NullObject);

  }] compacted] set] ?: self.members);

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.flag,                              @"flag",        dictionary);
	SafeSetValueForKey(self.address,                           @"address",     dictionary);
	SafeSetValueForKey(self.family,                            @"family",      dictionary);
	SafeSetValueForKey([self valueForKeyPath:@"members.uuid"], @"members",     dictionary);
	SafeSetValueForKey(self.device.uuid,                       @"device.uuid", dictionary);


  return dictionary;

}

@end


