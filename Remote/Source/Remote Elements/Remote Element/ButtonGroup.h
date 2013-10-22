//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

@class CommandContainer, Button;

/**
* `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
* theater remote control. Its main function is to manage a collection of <Button> objects and to
* interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
* use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
*/
@interface ButtonGroup : RemoteElement

+ (instancetype)buttonGroupWithRole:(RERole)role;
+ (instancetype)buttonGroupWithRole:(RERole)role context:(NSManagedObjectContext *)moc;


/**
* Retrieve a Button object contained by the `ButtonGroup` by its key.
* @param key The key for the Button object.
* @return The Button specified or nil if it does not exist.
*/
- (Button *)objectForKeyedSubscript:(NSString *)subscript;
- (Button *)objectAtIndexedSubscript:(NSUInteger)subscript;

- (void)addCommandContainer:(CommandContainer *)container
             mode:(RERemoteMode)mode;

/**
* Label text for the optional `UILabelView`.
*/
@property (nonatomic, copy) NSAttributedString * label;

/**
* String used to generate auto layout  constraint for the label.
*/
@property (nonatomic, copy) NSString * labelConstraints;

/**
* REPanelLocation referring to which side the `ButtonGroup` appears when attached to a
* Remote as a panel.
*/
@property (nonatomic, assign) REPanelLocation panelLocation;
@property (nonatomic, assign) REPanelTrigger panelTrigger;
@property (nonatomic, assign) REPanelAssignment panelAssignment;

@property (nonatomic, strong, readonly) Remote * parentElement;
@property (nonatomic, weak, readonly) ButtonGroupConfigurationDelegate * groupConfigurationDelegate;

- (BOOL)isPanel;
- (void)setCommandContainer:(CommandContainer *)container;

@end

MSEXTERN_NAMETAG(REButtonGroupPanel);

////////////////////////////////////////////////////////////////////////////////
#pragma mark REPickerLabelButtonGroup
////////////////////////////////////////////////////////////////////////////////
@class CommandSetCollection, CommandSet;

/**
* The PickerLabelButtonGroup is a `ButtonGroup` subclass that manages multiple CommandSet objects,
* allowing for the buttons of the `ButtonGroup` to provide a different set of commands per user
* selection. The command sets are represented by a label title. The titles are displayed on a
* scroll view, which the user swipes left or right to load the next/previous command set.
*/
@interface PickerLabelButtonGroup : ButtonGroup

#pragma mark - Managing the CommandSets
/// @name ￼Managing the CommandSets

/**
* Add a new `CommandSet` for the specified label text.
* @param commandSet The `CommandSet` object to add the `PickerLabelButtonGroup`'s collection.
* @param label The display name for selecting the `CommandSet`.
*/
- (void)addCommandSet:(CommandSet *)commandSet withLabel:(id)label;

/// Container object which holds the `CommandSet`- `Label` combiniations
@property (nonatomic, strong) CommandSetCollection * commandSetCollection;

@end
