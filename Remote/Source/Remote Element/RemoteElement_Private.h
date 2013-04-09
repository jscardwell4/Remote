//
// RemoteElement_Private.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"
#import "RELayoutConfiguration.h"
#import "REConstraint.h"

@interface RemoteElement () {
@protected
    uint64_t   _primitiveFlags;
    uint64_t   _primitiveAppearance;
    uint64_t   _index;
}

@property (nonatomic, strong, readwrite) REConstraintManager   * constraintManager;
@property (nonatomic, strong, readwrite) RELayoutConfiguration * layoutConfiguration;

@end

@interface RemoteElement (FlagsAndOptionsPrivate)
@property (nonatomic, assign)    uint64_t    primitiveFlags;
@property (nonatomic, assign)    uint64_t    primitiveAppearance;
@property (nonatomic, readwrite) REType      type;
@property (nonatomic, readwrite) RESubtype   subtype;
@property (nonatomic, readwrite) REState     state;
@end

@interface RemoteElement (CoreDataGeneratedAccessors)

@property (nonatomic) NSMutableSet            * primitiveConstraints;
@property (nonatomic) NSMutableSet            * primitiveFirstItemConstraints;
@property (nonatomic) NSMutableSet            * primitiveSecondItemConstraints;
@property (nonatomic) NSMutableOrderedSet     * primitiveSubelements;
@property (nonatomic) REConfigurationDelegate * primitiveConfigurationDelegate;
@property (nonatomic) RemoteElement           * primitiveParentElement;

@end

@interface RERemote (CoreDataGeneratedAccessors)

@property (nonatomic) RERemoteConfigurationDelegate * primitiveConfigurationDelegate;

@end

@interface REButtonGroup ()

- (void)updateButtons;

@end

@interface REButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic) RECommandSet                         * primitiveCommandSet;
@property (nonatomic) REButtonGroupConfigurationDelegate * primitiveConfigurationDelegate;

@end

@interface REPickerLabelButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic, strong) RECommandSetCollection * primitiveCommandSetCollection;

@end

@interface REButton () 

@property (nonatomic, strong, readwrite) REControlStateTitleSet          * titles;
@property (nonatomic, strong, readwrite) REControlStateIconImageSet      * icons;
@property (nonatomic, strong, readwrite) REControlStateColorSet          * backgroundColors;
@property (nonatomic, strong, readwrite) REControlStateButtonImageSet    * images;

@end

@interface REButton (CoreDataGeneratedAccessors)

@property (nonatomic) NSValue                       * primitiveTitleEdgeInsets;
@property (nonatomic) NSValue                       * primitiveImageEdgeInsets;
@property (nonatomic) NSValue                       * primitiveContentEdgeInsets;
@property (nonatomic) REControlStateIconImageSet    * primitiveIcons;
@property (nonatomic) REControlStateButtonImageSet  * primitiveImages;
@property (nonatomic) REControlStateColorSet        * primitiveBackgroundColors;
@property (nonatomic) REControlStateTitleSet        * primitiveTitles;
@property (nonatomic) REButtonConfigurationDelegate * primitiveConfigurationDelegate;

@end


#import "RERemoteController.h"
#import "BankObject.h"
#import "RECommand.h"
#import "RECommandContainer.h"
#import "REConfigurationDelegate.h"
#import "REControlStateSet.h"
#import "BankObject.h"
#import "CoreDataManager.h"
#import "RETheme.h"

