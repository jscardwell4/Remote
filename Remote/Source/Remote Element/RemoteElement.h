//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"
#import "REEditableBackground.h"
#import "REConfigurationDelegate.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element
////////////////////////////////////////////////////////////////////////////////
@class RERemoteController, RELayoutConfiguration, REConstraintManager, BOImage;

@interface RemoteElement : NSManagedObject <REEditableBackground>

// model backed properties
@property (nonatomic, assign)                   int16_t                   tag;
@property (nonatomic, copy)                     NSString                * key;
@property (nonatomic, copy)                     NSString                * uuid;
@property (nonatomic, copy)                     NSString                * displayName;
@property (nonatomic, strong)                   NSSet                   * constraints;
@property (nonatomic, strong)                   NSSet                   * firstItemConstraints;
@property (nonatomic, strong)                   NSSet                   * secondItemConstraints;
@property (nonatomic, assign)                   CGFloat                   backgroundImageAlpha;
@property (nonatomic, strong)                   UIColor                 * backgroundColor;
@property (nonatomic, strong)                   BOBackgroundImage       * backgroundImage;
@property (nonatomic, strong)                   RERemoteController      * controller;
@property (nonatomic, strong)                   NSOrderedSet            * subelements;
@property (nonatomic, strong, readonly)         RELayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong, readonly)         REConstraintManager     * constraintManager;

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context;
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
                        withAttributes:(NSDictionary *)attributes;

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RemoteElement (AbstractProperties)

@property (nonatomic, strong) RemoteElement           * parentElement;
@property (nonatomic, strong) REConfigurationDelegate * configurationDelegate;

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

@interface RemoteElement (FLagsAndOptions)

@property (nonatomic, assign)           REShape     shape;
@property (nonatomic, assign)           REStyle     style;
@property (nonatomic, readonly)         REType      type;
@property (nonatomic, readonly)         REType      baseType;
@property (nonatomic, readonly)         RESubtype   subtype;
@property (nonatomic, assign)           REOptions   options;
@property (nonatomic, readonly)         REState     state;

- (uint64_t)flagsWithMask:(uint64_t)mask;
- (uint64_t)appearanceWithMask:(uint64_t)mask;
- (void)setFlags:(uint64_t)flags mask:(uint64_t)mask;
- (void)setAppearance:(uint64_t)appearance mask:(uint64_t)mask;
- (void)setFlagBits:(uint64_t)flagBits;
- (void)unsetFlagBits:(uint64_t)flagsBits;
- (void)toggleFlagBits:(uint64_t)flagBits mask:(uint64_t)mask;
- (void)setAppearanceBits:(uint64_t)appearanceBits;
- (void)unsetAppearanceBits:(uint64_t)appearanceBits;
- (void)toggleAppearanceBits:(uint64_t)appearanceBits mask:(uint64_t)mask;
- (BOOL)isFlagSetForBits:(uint64_t)bits;
- (BOOL)isAppearanceSetforBits:(uint64_t)bits;

@end

@class   REConstraint;

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

- (void)addConstraint:(REConstraint *)constraint;
- (void)addConstraintsObject:(REConstraint *)constraint;
- (void)removeConstraintsObject:(REConstraint *)constraint;
- (void)addConstraints:(NSSet *)constraints;
- (void)removeConstraint:(REConstraint *)constraint;
- (void)removeConstraints:(NSSet *)constraints;

- (void)addFirstItemConstraintsObject:(REConstraint *)constraint;
- (void)removeFirstItemConstraintsObject:(REConstraint *)constraint;
- (void)addFirstItemConstraints:(NSSet *)constraints;
- (void)removeFirstItemConstraints:(NSSet *)constraints;

- (void)addSecondItemConstraintsObject:(REConstraint *)constraint;
- (void)removeSecondItemConstraintsObject:(REConstraint *)constraint;
- (void)addSecondItemConstraints:(NSSet *)constraints;
- (void)removeSecondItemConstraints:(NSSet *)constraints;

@end

@interface RemoteElement (Debugging)

- (NSString *)constraintsDescription;
- (NSString *)dumpElementHierarchy;
- (NSString *)flagsAndAppearanceDescription;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RERemote
////////////////////////////////////////////////////////////////////////////////
@class REButtonGroup;

/**
 * `Remote` is a subclass of `NSManagedObject` that models a home theater
 * remote control. It maintains a collection of <ButtonGroup> objects to implement
 * the actual execution of commands (via their collection of <Button> objects).
 * A `Remote` serves as a model for display by a <RemoteView>. Each `Remote` models
 * a single screen. Dynamically switching among `Remote` objects is handled by a
 * <RemoteController> which maintains a collection of `Remotes`.
 */
@interface RERemote : RemoteElement

/**
 * Flag that determines whether or not the remote view controller's topbar should be visible when
 * this remote is loaded.
 */
@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL topBarHiddenOnLoad;

/**
 * Retrieve a ButtonGroup contained by this Remote by the ButtonGroup's key.
 *
 * @param subscript Key for the ButtonGroup to retrieve.
 *
 * @return The ButtonGroup requested, or nil if no ButtonGroup with specified key exists.
 */
- (REButtonGroup *)objectForKeyedSubscript:(NSString *)subscript;


@property (nonatomic, strong) RERemoteConfigurationDelegate * configurationDelegate;

@end

@interface RERemote (REConfigurationDelegate)

@property (nonatomic, copy) RERemoteConfiguration currentConfiguration;

- (void)addConfiguration:(RERemoteConfiguration)configuration;
- (BOOL)hasConfiguration:(RERemoteConfiguration)configuration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////
@class RECommandSet, REButton;

/**
 * `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
 * theater remote control. Its main function is to manage a collection of <Button> objects and to
 * interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
 * use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
 */
@interface REButtonGroup : RemoteElement

/**
 * Retrieve a Button object contained by the `ButtonGroup` by its key.
 * @param key The key for the Button object.
 * @return The Button specifed or nil if it does not exist.
 */
- (REButton *)objectForKeyedSubscript:(NSString *)subscript;

/**
 * Label text for the optional `UILabelView`.
 */
@property (nonatomic, copy) NSAttributedString * label;

/**
 * String used to generate auto layout  constraint for the label.
 */
@property (nonatomic, copy) NSString * labelConstraints;

/**
 * REButtonGroupPanelLocation referring to which side the `ButtonGroup` appears when attached to a
 * Remote as a panel.
 */
@property (nonatomic, assign) REButtonGroupPanelLocation   panelLocation;

/**
 * The configuration delegate handles dynamically swapping CommandSet objects from which
 * the Button contained by the `ButtonGroup` are assigned a Command object.
 */
@property (nonatomic, strong) REButtonGroupConfigurationDelegate * configurationDelegate;

@property (nonatomic, strong) RERemote * parentElement;

@property (nonatomic, readonly) RERemote * remote;

/**
 * CommandSet object containing the commands currently in use for the button group's Button
 * objects.
 */
@property (nonatomic, strong) RECommandSet * commandSet;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark REPickerLabelButtonGroup
////////////////////////////////////////////////////////////////////////////////
@class RECommandSetCollection;

/**
 * The PickerLabelButtonGroup is a `ButtonGroup` subclass that manages multiple CommandSet objects,
 * allowing for the buttons of the `ButtonGroup` to provide a different set of commands per user
 * selection. The command sets are represented by a label title. The titles are displayed on a
 * scroll view, which the user swipes left or right to load the next/previous command set.
 */
@interface REPickerLabelButtonGroup : REButtonGroup

#pragma mark - Managing the CommandSets
/// @name ￼Managing the CommandSets

/**
 * Add a new `CommandSet` for the specified label text.
 * @param commandSet The `CommandSet` object to add the `PickerLabelButtonGroup`'s collection.
 * @param label The display name for selecting the `CommandSet`.
 */
- (void)addCommandSet:(RECommandSet *)commandSet withLabel:(NSAttributedString *)label;

/// Container object which holds the `RECommandSet`- `Label` combiniations
@property (nonatomic, strong) RECommandSetCollection * commandSetCollection;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButton
////////////////////////////////////////////////////////////////////////////////
@class REControlStateTitleSet, REControlStateIconImageSet, REControlStateColorSet;
@class REControlStateButtonImageSet, RECommand, BOButtonImage, BOIconImage;



/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface REButton : RemoteElement

@property (nonatomic, strong)           REButtonConfigurationDelegate * configurationDelegate;
@property (nonatomic, strong)           REButtonGroup                 * parentElement;
@property (nonatomic, readonly)         RERemote                      * remote;
@property (nonatomic, strong, readonly) REControlStateTitleSet          * titles;
@property (nonatomic, strong, readonly) REControlStateIconImageSet      * icons;
@property (nonatomic, strong, readonly) REControlStateColorSet          * backgroundColors;
@property (nonatomic, strong, readonly) REControlStateButtonImageSet    * images;
@property (nonatomic, strong)           RECommand                       * command;
@property (nonatomic, strong)           RECommand                       * longPressCommand;
@property (nonatomic, assign)           UIEdgeInsets                    titleEdgeInsets;
@property (nonatomic, assign)           UIEdgeInsets                    imageEdgeInsets;
@property (nonatomic, assign)           UIEdgeInsets                    contentEdgeInsets;

@property (nonatomic, assign, getter = isSelected)    BOOL   selected;
@property (nonatomic, assign, getter = isEnabled)     BOOL   enabled;
@property (nonatomic, assign, getter = isHighlighted) BOOL   highlighted;


- (void)executeCommandWithOptions:(RECommandOptions)options
                       completion:(void (^)(BOOL finished, BOOL success))completion;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark REActivityButton
////////////////////////////////////////////////////////////////////////////////
/**
 * ActivityButton is a subclass of Button that can be used to trigger a change in the
 * `currentActivity` of a RemoteController. The `key` should be set to the match the name
 * of the associated activity. ActivityButton maintains a set of `DeviceConfiguration` objects to
 * associate with the **activity**. The remote controller associated with the button uses this
 * set to determine what state devices should be in when switching from one activity to another.
 */
@interface REActivityButton : REButton

@property (nonatomic, strong) NSSet              * deviceConfigurations;
@property (nonatomic, assign) REActivityButtonType   activityButtonType;

@end

MSKIT_EXTERN NSString * EditingModeString(REEditingMode mode);

MSKIT_EXTERN BOOL REStringIdentifiesRemoteElement(NSString * identifier, RemoteElement * re);

#define NSDictionaryOfVariableBindingsToIdentifiers(...) \
    _NSDictionaryOfVariableBindingsToIdentifiers(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSKIT_EXTERN NSDictionary * _NSDictionaryOfVariableBindingsToIdentifiers(NSString *, id , ...);

MSKIT_EXTERN NSString *NSStringFromPanelLocation(REButtonGroupPanelLocation location);

