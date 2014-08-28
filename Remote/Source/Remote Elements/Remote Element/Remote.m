//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Remote.h"
#import "RemoteElement_Private.h"

static int       ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = LOG_CONTEXT_REMOTE;
#pragma unused(ddLogLevel, msLogContext)


@interface Remote ()
@property (nonatomic, strong, readwrite) NSDictionary * panels;
@end

@interface Remote (CoreDataGeneratedAccessors)
@property (nonatomic) NSDictionary * primitivePanels;
@end


@implementation Remote

@dynamic panels;

+ (REType)elementType { return RETypeRemote; }

- (void)setParentElement:(RemoteElement *)parentElement {}

- (RemoteElement *)parentElement { return nil; }

- (void)setTopBarHidden:(BOOL)topBarHidden {
  REOptions options = self.options;
  self.options = (topBarHidden
                  ? options | RERemoteOptionTopBarHidden
                  : options & ~RERemoteOptionTopBarHidden);
}

- (BOOL)isTopBarHidden {
  BOOL topBarHidden       = (self.options == RERemoteOptionTopBarHidden) ? YES : NO;
  BOOL faultyTopBarHidden = (self.options & RERemoteOptionTopBarHidden) ? YES : NO;
  assert(topBarHidden == faultyTopBarHidden);

  if (topBarHidden) assert(self.options == 1);

  return topBarHidden;
}

- (void)assignButtonGroup:(ButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment {
  NSMutableDictionary * panels = [self.panels mutableCopy];
  panels[@(assignment)]       = CollectionSafe(buttonGroup.uuid);
  self.panels                 = panels;
  buttonGroup.panelAssignment = assignment;
}

- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment {
  NSString * uuid = NilSafe(self.panels[@(assignment)]);
  return (uuid ? [ButtonGroup existingObjectWithUUID:uuid context:self.managedObjectContext] : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  /*
     {
      "uuid": "B0EA5B35-5CF6-40E9-B302-0F164D4A7ADD", // Home Screen
      "name": "Home Screen",
      "elementType": "remote",
      "key": "activity1",
      "options": "top-bar-hidden",
      "constraints": {
          "index": {
              "activityButtons": "F358CB82-496C-446D-8833-D4373777D23E",
              "bottomToolbar": "B81FFF61-4F56-43C1-9E60-3C399EB31C1B",
              "homeScreen": "B0EA5B35-5CF6-40E9-B302-0F164D4A7ADD" // Home Screen
          },
          "format": [
              "activityButtons.centerX = homeScreen.centerX",
              "activityButtons.centerY = homeScreen.centerY - 22",
              "bottomToolbar.bottom = homeScreen.bottom",
              "bottomToolbar.left = homeScreen.left",
              "bottomToolbar.right = homeScreen.right"
          ]
      },
      "backgroundColor": "black",
      "backgroundImage.uuid": "089D4A98-E7C1-472A-A0A3-30258BE42388", // Pro Dots.png
      "subelements": [ **ButtonGroup** ],
      "panels": {
          "left1": "7521F420-F677-44C9-97BA-4AF836779C21", // Left Overlay Panel
          "right1": "A6394F58-79C6-4B6C-962D-1DDD6BE1C36F", // Selection Panel
          "bottom1": "D505193C-C9D5-4D89-9C9F-D0B24EAE6D69", // DVR Activity Transport
          "top1": "A2EFC284-8F45-45B1-9A4B-DB448A2AEAE7" // DVR Activity Number Pad
      }
     }
   */

  [super updateWithData:data];

  NSDictionary * panels = data[@"panels"];

  if (panels && isDictionaryKind(panels)) {
    [panels enumerateKeysAndObjectsUsingBlock:
     ^(NSString * assignmentKey, NSString * uuid, BOOL * stop)
    {
      ButtonGroup * panel = (ButtonGroup *)memberOfCollectionWithUUID(self.subelements, uuid);

      if (panel) {
        REPanelAssignment assignment = panelAssignmentFromImportKey(assignmentKey);
        [self assignButtonGroup:panel assignment:assignment];
      }
    }];
  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  MSDictionary * panels = [MSDictionary dictionary];
  [self.panels enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSString * uuid, BOOL *stop){
    NSString * k = panelKeyForPanelAssignment(IntValue(key));
    SafeSetValueForKey([self buttonGroupForAssignment:IntValue(key)].commentedUUID, k, panels);
  }];

  SafeSetValueForKey(panels, @"panels", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end

@implementation Remote (Debugging)

- (MSDictionary *)deepDescriptionDictionary {
  Remote * element = [self faultedObject];
  assert(element);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
  dd[@"topBarHidden"] = BOOLString(element.topBarHidden);

  return (MSDictionary *)dd;
}

@end
