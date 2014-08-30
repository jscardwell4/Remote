//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

@class CommandContainer, CommandSetCollection, CommandSet, Button, TitleAttributes;

/**
* `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
* theater remote control. Its main function is to manage a collection of <Button> objects and to
* interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
* use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
*/
@interface ButtonGroup : RemoteElement

//+ (instancetype)buttonGroupWithRole:(RERole)role;
//+ (instancetype)buttonGroupWithRole:(RERole)role context:(NSManagedObjectContext *)moc;

- (void)setCommandContainer:(CommandContainer *)container mode:(NSString *)mode;
- (CommandContainer *)commandContainerForMode:(NSString *)mode;
- (void)setLabel:(id)label mode:(NSString *)mode;

- (void)selectCommandSetAtIndex:(NSUInteger)index;
- (NSAttributedString *)labelForCommandSetAtIndex:(NSUInteger)index;

/**
* Label text for the optional `UILabelView`.
*/
@property (nonatomic, strong, readonly) NSAttributedString * label;

/**
 * CommandSet or CommandSet Collection used to assign commands to button subelements
 */
@property (nonatomic, strong, readonly) CommandContainer * commandContainer;

/**
* String used to generate auto layout  constraint for the label.
*/
@property (nonatomic, copy) NSString * labelConstraints;

@property (nonatomic, strong) TitleAttributes * labelAttributes;

/**
* REPanelLocation referring to which side the `ButtonGroup` appears when attached to a
* Remote as a panel.
*/
@property (nonatomic, assign) REPanelLocation     panelLocation;
@property (nonatomic, assign) REPanelTrigger      panelTrigger;
@property (nonatomic, assign) REPanelAssignment   panelAssignment;

- (BOOL)isPanel;

@property (nonatomic, assign) BOOL autohide;

@end

MSEXTERN_NAMETAG(REButtonGroupPanel);
