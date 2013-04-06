//
// REButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = REMOTE_F_C;
#pragma unused(ddLogLevel,msLogContext)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation REButtonGroup

@dynamic label;
@dynamic labelConstraints;
@dynamic configurationDelegate;
@dynamic parentElement;
@dynamic commandSet;

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    __block REButtonGroup * element = nil;
    [context performBlockAndWait:
     ^{
         element = [super remoteElementInContext:context];
         element.type = RETypeButtonGroup;
     }];
    return element;
}

- (RERemote *)remote { return self.parentElement; }

- (void)setPanelLocation:(REButtonGroupPanelLocation)panelLocation
{
    self.subtype = panelLocation << 0x10;
}

- (REButtonGroupPanelLocation)panelLocation
{
    return (REButtonGroupPanelLocation)(self.subtype >> 0x10);
}

- (REButton *)objectForKeyedSubscript:(NSString *)subscript
{
    return (REButton *)[super objectForKeyedSubscript:subscript];
}

/**
 * Updates the Command for each Button contained by the ButtonGroup with Command object from
 * the current CommandSet
 */
- (void)updateButtons
{
    RECommandSet * commandSet = self.commandSet;

    if (ValueIsNil(commandSet)) return;

    for (REButton * button in self.subelements)
    {
        RECommand * cmd = ([commandSet isValidKey:button.key] ? commandSet[button.key] : nil);

        if (ValueIsNotNil(cmd))
        {
            button.command = cmd;
            button.enabled = YES;
            MSLogDebugTag(@"new command: %@", button.key, [cmd description]);
        }
        else
        {
            button.enabled = NO;
            MSLogDebugTag(@"command not found for key \"%@\"", button.key);
        }
    }
}

- (void)setCommandSet:(RECommandSet *)commandSet
{
    [self willChangeValueForKey:@"commandSet"];
    self.primitiveCommandSet = commandSet;
    [self didChangeValueForKey:@"commandSet"];

    [self updateButtons];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REPickerLabelButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation REPickerLabelButtonGroup

@dynamic commandSetCollection;

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    __block REPickerLabelButtonGroup * element = nil;
    [context performBlockAndWait:
     ^{
         element = [super remoteElementInContext:context];
         element.type = REButtonGroupTypePickerLabel;
         element.commandSetCollection = [RECommandSetCollection commandContainerInContext:context];
     }];
    return element;
}

- (void)addCommandSet:(RECommandSet *)commandSet withLabel:(NSAttributedString *)label
{
    self.commandSetCollection[commandSet] = label;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Miscellaneous Functions
////////////////////////////////////////////////////////////////////////////////

NSString *NSStringFromPanelLocation(REButtonGroupPanelLocation location)
{
    switch (location)
    {
        case REPanelLocationNotAPanel:
            return @"REPanelLocationNotAPanel";

        case REPanelLocationTop:
            return @"REPanelLocationTop";

        case REPanelLocationBottom:
            return @"REPanelLocationBottom";

        case REPanelLocationLeft:
            return @"REPanelLocationLeft";

        case REPanelLocationRight:
            return @"REPanelLocationRight";

        default:
            return nil;
    }
}
