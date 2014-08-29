//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Remote.h"
#import "RemoteElement_Private.h"
#import "ButtonGroup.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"

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

@dynamic panels, topBarHidden;

- (REType)elementType { return RETypeRemote; }

- (void)setParentElement:(RemoteElement *)parentElement {}

- (RemoteElement *)parentElement { return nil; }

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

  [super updateWithData:data];

  NSDictionary * panels = data[@"panels"];

  self.topBarHidden = [data[@"top-bar-hidden"] boolValue];

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
  SetValueForKeyIfNotDefault(@(self.topBarHidden), @"topBarHidden", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end

