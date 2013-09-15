//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"
#import "REEditableBackground.h"
#import "ConfigurationDelegate.h"
#import "LayoutConfiguration.h"
#import "Constraint.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element
////////////////////////////////////////////////////////////////////////////////
@class RemoteController, LayoutConfiguration, ConstraintManager, Image, Theme;

@interface RemoteElement : ModelObject <REEditableBackground, NamedModelObject>

// model backed properties
@property (nonatomic, assign, readwrite) int16_t                     tag;
@property (nonatomic, assign, readonly ) REType                      type;
@property (nonatomic, assign, readwrite) RESubtype                   subtype;
@property (nonatomic, assign, readwrite) REOptions                   options;
@property (nonatomic, assign, readwrite) REState                     state;
@property (nonatomic, assign, readwrite) REShape                     shape;
@property (nonatomic, assign, readwrite) REStyle                     style;
@property (nonatomic, assign, readwrite) REThemeFlags                themeFlags;
@property (nonatomic, copy,   readwrite) NSString                  * key;
@property (nonatomic, copy,   readwrite) NSString                  * name;
@property (nonatomic, copy,   readonly ) NSString                  * identifier;
@property (nonatomic, strong, readwrite) NSSet                     * constraints;
@property (nonatomic, strong, readonly ) NSSet                     * firstItemConstraints;
@property (nonatomic, strong, readonly ) NSSet                     * secondItemConstraints;
@property (nonatomic, assign, readwrite) CGFloat                     backgroundImageAlpha;
@property (nonatomic, strong, readwrite) UIColor                   * backgroundColor;
@property (nonatomic, strong, readwrite) Image                   * backgroundImage;
@property (nonatomic, strong, readwrite) NSOrderedSet              * subelements;
@property (nonatomic, strong, readonly ) LayoutConfiguration     * layoutConfiguration;
@property (nonatomic, strong, readonly ) ConstraintManager       * constraintManager;
@property (nonatomic, strong, readonly ) Theme                   * theme;
@property (nonatomic, strong, readonly ) ConfigurationDelegate   * configurationDelegate;

+ (instancetype)remoteElement;
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc;
+ (instancetype)remoteElementWithAttributes:(NSDictionary *)attributes;
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                        attributes:(NSDictionary *)attributes;

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key;
- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript;
- (void)setObject:(RemoteElement *)object atIndexedSubscript:(NSUInteger)idx;

- (void)applyTheme:(Theme *)theme;

@end

@interface RemoteElement (AbstractProperties)

@property (nonatomic, readonly) RemoteElement           * parentElement;
@property (nonatomic, readonly) RemoteController      * controller;

@end

@interface RemoteElement (REConstraintManager)

- (void)setConstraintsFromString:(NSString *)constraints;

@end

@interface RemoteElement (RELayoutConfiguration)

@property (nonatomic, assign, readonly) BOOL    proportionLock;
@property (nonatomic, strong, readonly) NSSet * subelementConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentChildConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentSiblingConstraints;
@property (nonatomic, strong, readonly) NSSet * intrinsicConstraints;

@end

@class   Constraint;

@interface RemoteElement (SubelementsAccessors)

- (void)insertObject:(RemoteElement *)value inSubelementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSubelementsAtIndex:(NSUInteger)idx;
- (void)insertSubelements:(NSArray *)value atIndexes:(NSIndexSet *)indices;
- (void)removeSubelementsAtIndexes:(NSIndexSet *)indices;
- (void)replaceObjectInSubelementsAtIndex:(NSUInteger)idx withObject:(RemoteElement *)value;
- (void)replaceSubelementsAtIndexes:(NSIndexSet *)indexes withSubelements:(NSArray *)values;
- (void)addSubelementsObject:(RemoteElement *)value;
- (void)removeSubelementsObject:(RemoteElement *)value;
- (void)addSubelements:(NSOrderedSet *)values;
- (void)removeSubelements:(NSOrderedSet *)values;

@end

@interface RemoteElement (ConstraintAccessors)

- (void)addConstraint:(Constraint *)constraint;
- (void)addConstraintsObject:(Constraint *)constraint;
- (void)removeConstraintsObject:(Constraint *)constraint;
- (void)addConstraints:(NSSet *)constraints;
- (void)removeConstraint:(Constraint *)constraint;
- (void)removeConstraints:(NSSet *)constraints;

- (void)addFirstItemConstraintsObject:(Constraint *)constraint;
- (void)removeFirstItemConstraintsObject:(Constraint *)constraint;
- (void)addFirstItemConstraints:(NSSet *)constraints;
- (void)removeFirstItemConstraints:(NSSet *)constraints;

- (void)addSecondItemConstraintsObject:(Constraint *)constraint;
- (void)removeSecondItemConstraintsObject:(Constraint *)constraint;
- (void)addSecondItemConstraints:(NSSet *)constraints;
- (void)removeSecondItemConstraints:(NSSet *)constraints;

@end

@interface RemoteElement (Debugging)

- (NSString *)recursiveDeepDescription;
- (NSString *)constraintsDescription;
- (NSString *)dumpElementHierarchy;
- (NSString *)flagsAndAppearanceDescription;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RERemote
////////////////////////////////////////////////////////////////////////////////
@class ButtonGroup;

/**
 * `Remote` is a subclass of `NSManagedObject` that models a home theater
 * remote control. It maintains a collection of <ButtonGroup> objects to implement
 * the actual execution of commands (via their collection of <Button> objects).
 * A `Remote` serves as a model for display by a <RemoteView>. Each `Remote` models
 * a single screen. Dynamically switching among `Remote` objects is handled by a
 * <RemoteController> which maintains a collection of `Remotes`.
 */
@interface Remote : RemoteElement

/**
 * Flag that determines whether or not the remote view controller's topbar should be visible when
 * this remote is loaded.
 */
@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL topBarHiddenOnLoad;

@property (nonatomic, weak, readonly) RemoteConfigurationDelegate * remoteConfigurationDelegate;

@property (nonatomic, strong, readonly) NSDictionary * panels;

/**
 * Retrieve a ButtonGroup contained by this Remote by the ButtonGroup's key.
 *
 * @param subscript Key for the ButtonGroup to retrieve.
 *
 * @return The ButtonGroup requested, or nil if no ButtonGroup with specified key exists.
 */
- (ButtonGroup *)objectForKeyedSubscript:(NSString *)subscript;
- (ButtonGroup *)objectAtIndexedSubscript:(NSUInteger)subscript;
- (void)assignButtonGroup:(ButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment;
- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment;
- (BOOL)registerConfiguration:(RERemoteConfiguration)configuration;
@end

@interface Remote (REConfigurationDelegate)

@property (nonatomic, copy) RERemoteConfiguration currentConfiguration;

- (void)addConfiguration:(RERemoteConfiguration)configuration;
- (BOOL)hasConfiguration:(RERemoteConfiguration)configuration;

@end

//////////////////////////////////////////////////////////////////////////////////
//#pragma mark - REButtonGroup
//////////////////////////////////////////////////////////////////////////////////
@class CommandContainer, Button;

/**
* `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
* theater remote control. Its main function is to manage a collection of <Button> objects and to
* interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
* use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
*/
@interface ButtonGroup : RemoteElement

+ (instancetype)buttonGroupWithType:(REType)type;
+ (instancetype)buttonGroupWithType:(REType)type context:(NSManagedObjectContext *)moc;


/**
* Retrieve a Button object contained by the `ButtonGroup` by its key.
* @param key The key for the Button object.
* @return The Button specified or nil if it does not exist.
*/
- (Button *)objectForKeyedSubscript:(NSString *)subscript;
- (Button *)objectAtIndexedSubscript:(NSUInteger)subscript;

- (void)addCommandContainer:(CommandContainer *)container
             configuration:(RERemoteConfiguration)config;

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

MSKIT_EXTERN_NAMETAG(REButtonGroupPanel);

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

/// Container object which holds the `RECommandSet`- `Label` combiniations
@property (nonatomic, strong) CommandSetCollection * commandSetCollection;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButton
////////////////////////////////////////////////////////////////////////////////
@class ControlStateTitleSet, ControlStateImageSet, ControlStateColorSet, Command, Image;



/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface Button : RemoteElement

@property (nonatomic, strong, readonly ) ButtonGroup                 * parentElement;
@property (nonatomic, weak,   readonly ) Remote                      * remote;
@property (nonatomic, weak,   readonly ) ButtonConfigurationDelegate * buttonConfigurationDelegate;

@property (nonatomic, copy,   readwrite) id                              title;
@property (nonatomic, strong, readwrite) UIImage                       * icon;
@property (nonatomic, strong, readwrite) UIImage                       * image;

@property (nonatomic, strong, readwrite) Command                     * command;
@property (nonatomic, strong, readwrite) Command                     * longPressCommand;

@property (nonatomic, assign, readwrite) UIEdgeInsets                    titleEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets                    imageEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets                    contentEdgeInsets;

@property (nonatomic, assign, readwrite, getter = isSelected)    BOOL   selected;
@property (nonatomic, assign, readwrite, getter = isEnabled)     BOOL   enabled;
@property (nonatomic, assign, readwrite, getter = isHighlighted) BOOL   highlighted;

+ (instancetype)buttonWithType:(REType)type;
+ (instancetype)buttonWithType:(REType)type context:(NSManagedObjectContext *)moc;
+ (instancetype)buttonWithTitle:(id)title;
+ (instancetype)buttonWithTitle:(id)title context:(NSManagedObjectContext *)moc;
+ (instancetype)buttonWithType:(REType)type title:(id)title;
+ (instancetype)buttonWithType:(REType)type title:(id)title context:(NSManagedObjectContext *)moc;


- (void)executeCommandWithOptions:(RECommandOptions)options
                       completion:(RECommandCompletionHandler)completion;

@end

@interface Button (REButtonConfigurationDelegate)

@property (nonatomic, strong, readonly ) NSSet                         * commands;
@property (nonatomic, strong, readonly ) ControlStateTitleSet        * titles;
@property (nonatomic, strong, readonly ) ControlStateImageSet        * icons;
@property (nonatomic, strong, readonly ) ControlStateColorSet        * backgroundColors;
@property (nonatomic, strong, readonly ) ControlStateImageSet        * images;

- (void)setCommand:(Command *)command configuration:(RERemoteConfiguration)config;

- (void)setTitle:(id)title configuration:(RERemoteConfiguration)config;
- (void)setTitles:(ControlStateTitleSet *)titleSet configuration:(RERemoteConfiguration)config;

- (void)setBackgroundColors:(ControlStateColorSet *)colors
              configuration:(RERemoteConfiguration)config;

- (void)setIcons:(ControlStateImageSet *)icons configuration:(RERemoteConfiguration)config;

- (void)setImages:(ControlStateImageSet *)images configuration:(RERemoteConfiguration)config;

@end

MSKIT_EXTERN BOOL REStringIdentifiesRemoteElement(NSString * identifier, RemoteElement * re);

#define NSDictionaryOfVariableBindingsToIdentifiers(...) \
    _NSDictionaryOfVariableBindingsToIdentifiers(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSKIT_EXTERN NSDictionary * _NSDictionaryOfVariableBindingsToIdentifiers(NSString *, id , ...);
MSKIT_EXTERN Class classForREType(REType type);
MSKIT_EXTERN Class baseClassForREType(REType type);
