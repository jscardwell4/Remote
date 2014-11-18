//
// ButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ButtonGroup.h"
#import "RemoteElement_Private.h"
#import "CommandSetCollection.h"
#import "CommandSet.h"
#import "JSONObjectKeys.h"
//#import "Button.h"
#import "Command.h"
#import "TitleAttributes.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(REButtonGroupPanel);

@interface ButtonGroup ()
@property (nonatomic, strong, readwrite) CommandContainer * commandContainer;
@end

@interface ButtonGroup (CoreDataGeneratedAccessors)
@property (nonatomic) CommandContainer * primitiveCommandContainer;
@property (nonatomic) NSNumber         * primitivePanelAssignment;
@end

@implementation ButtonGroup
{
  NSUInteger _commandSetCollectionIndex;   /// index of command set in collection currently in use
}

@dynamic labelConstraints, labelAttributes, commandContainer, autohide;

- (REType)elementType { return RETypeButtonGroup; }

- (void)setPanelLocation:(REPanelLocation)panelLocation {
  switch (panelLocation) {
    case REPanelLocationTop:
    case REPanelLocationBottom:
    case REPanelLocationLeft:
    case REPanelLocationRight: {
      self.panelAssignment = panelLocation | self.panelTrigger;
    }   break;

    default: {
      self.panelAssignment = (REPanelAssignment)self.panelTrigger;
    }   break;
  }
}

- (void)setPanelTrigger:(REPanelTrigger)panelTrigger {
  switch (panelTrigger) {
    case REPanelTrigger1:
    case REPanelTrigger2:
    case REPanelTrigger3: {
      self.panelAssignment = panelTrigger | self.panelLocation;
    }   break;

    default: {
      self.panelAssignment = (REPanelAssignment)self.panelLocation;
    }   break;
  }
}

- (void)setPanelAssignment:(REPanelAssignment)panelAssignment {
  [self willChangeValueForKey:@"panelAssignment"];
  REPanelLocation location = panelAssignment & REPanelAssignmentLocationMask;
  REPanelTrigger  trigger  = panelAssignment & REPanelAssignmentTriggerMask;
  self.primitivePanelAssignment = @(location|trigger);
  [self didChangeValueForKey:@"panelAssignment"];
}

- (REPanelAssignment)panelAssignment {
  [self willAccessValueForKey:@"panelAssignment"];
  REPanelAssignment assignment = UnsignedShortValue(self.primitivePanelAssignment);
  [self didAccessValueForKey:@"panelAssignment"];
  return assignment;
}

- (REPanelTrigger)panelTrigger { return self.panelAssignment & REPanelAssignmentTriggerMask; }

- (REPanelLocation)panelLocation { return self.panelAssignment & REPanelAssignmentLocationMask; }

- (BOOL)isPanel { return (self.panelAssignment ? YES : NO); }

- (NSAttributedString *)label {
  [self willAccessValueForKey:@"label"];
  NSAttributedString * label = self[configurationKey(self.currentMode, @"label")];

  [self didAccessValueForKey:@"label"];

  return label;
}

- (CommandContainer *)commandContainer {
  [self willAccessValueForKey:@"commandContainer"];
  NSURL * containerURI = self[configurationKey(self.currentMode, @"commandContainer")];

  [self didAccessValueForKey:@"commandContainer"];

  return [self.managedObjectContext objectForURI:containerURI];
}

- (void)setCommandContainer:(CommandContainer *)container mode:(NSString *)mode {
  self[configurationKey(self.currentMode, @"commandContainer")] = container.permanentURI;
}

- (CommandContainer *)commandContainerForMode:(NSString *)mode {
  CommandContainer * container = nil;
  NSURL            * uri       = self[configurationKey(self.currentMode, @"commandContainer")];

  if (uri) container = [self.managedObjectContext objectForURI:uri];

  return container;
}

- (void)setLabel:(id)label mode:(NSString *)mode {
  if (!isAttributedStringKind(label))
    label = (isStringKind(label) ? [NSAttributedString attributedStringWithString:label] : nil);

  if (label && mode)
    self[$(@"%@.label", mode)] = label;
}

- (void)updateForMode:(NSString *)mode {
  [super updateForMode:mode];

  self.commandContainer = [self commandContainerForMode:mode];

    [self updateButtons];
}

- (void)updateButtons {
  CommandContainer * container = self.commandContainer;

  if (!(isKind(container, CommandSet) || isKind(container, CommandSetCollection))) return;

  CommandSet * commandSet = ([container isKindOfClass:[CommandSet class]]
                             ? (CommandSet *)container
                             : [(CommandSetCollection *)container
commandSetAtIndex: _commandSetCollectionIndex]);

  if (commandSet) commandSet = [commandSet faultedObject];

  for (Button * button in self.subelements) {
    if (button.role == REButtonRoleTuck) continue;

    Command * cmd = commandSet[@(button.role)];

    button.command = cmd;
    button.enabled = (cmd != nil);
    assert(button.enabled);
  }
}

- (NSAttributedString *)labelForCommandSetAtIndex:(NSUInteger)index {
  CommandContainer * container = self.commandContainer;

  if (!(container && isKind(self.commandContainer, CommandSetCollection) && index < container.count))
    return nil;

  NSString * labelText = [(CommandSetCollection *)container labelAtIndex : index];

  if (!labelText) return nil;

  TitleAttributes * labelAttributes = self.labelAttributes;

  if (labelAttributes) labelAttributes.text = labelText;

  return (labelAttributes
          ? labelAttributes.string
          : [NSAttributedString attributedStringWithString:labelText]);
}

- (void)selectCommandSetAtIndex:(NSUInteger)index {
  CommandContainer * container = self.commandContainer;

  if (container && isKind(self.commandContainer, CommandSetCollection) && index < container.count) {
    _commandSetCollectionIndex = index;
    [self updateButtons];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.autohide = BOOLValue(data[@"autohide"]);
  NSManagedObjectContext * moc = self.managedObjectContext;

  NSDictionary * commandSetData           = data[@"command-set"];
  NSDictionary * commandSetCollectionData = data[@"command-set-collection"];
  NSDictionary * labelAttributesData      = data[@"label-attributes"];

  if (commandSetData && isDictionaryKind(commandSetData)) {
    for (NSString * mode  in commandSetData) {
      CommandContainer * container = [moc objectForURI:self[configurationKey(mode, @"container")]];
      if (container) { [moc deleteObject:container]; container = nil; }
      CommandSet * commandSet = [CommandSet importObjectFromData:commandSetData[mode] context:moc];
      if (commandSet) [self setCommandContainer:commandSet mode:mode];
    }
  } else if (commandSetCollectionData && isDictionaryKind(commandSetCollectionData))   {
    for (NSString * mode in commandSetCollectionData) {
      CommandContainer * container = [moc objectForURI:self[configurationKey(mode, @"container")]];
      if (container) { [moc deleteObject:container]; container = nil; }
      CommandSetCollection * collection =
        [CommandSetCollection importObjectFromData:commandSetCollectionData[mode] context:moc];
      if (collection) [self setCommandContainer:collection mode:mode];
    }
  }

  self.labelConstraints = data[@"label-constraints"];

  if (labelAttributesData && isDictionaryKind(labelAttributesData))
    self.labelAttributes  = [TitleAttributes importObjectFromData:labelAttributesData context:moc];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  MSDictionary * commandSets           = [MSDictionary dictionary];
  MSDictionary * commandSetCollections = [MSDictionary dictionary];

  for (NSString * mode in self.modes) {
    CommandContainer * container = [self commandContainerForMode:mode];

    if (isKind(container, CommandSetCollection))
      commandSetCollections[mode] = container.JSONDictionary;
    else if (isKind(container, CommandSet))
      commandSets[mode] = container.JSONDictionary;
  }

  dictionary[@"command-set-collection"] = commandSetCollections;
  dictionary[@"command-set"]            = commandSets;
  SafeSetValueForKey(self.labelConstraints,               @"label-constraints", dictionary);
  SafeSetValueForKey(self.label,                          @"label",             dictionary);
  SafeSetValueForKey(self.labelAttributes.JSONDictionary, @"label-attributes",  dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
