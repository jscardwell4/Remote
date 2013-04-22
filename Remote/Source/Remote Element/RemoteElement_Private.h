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
}

@property (nonatomic, strong, readwrite) REConstraintManager     * constraintManager;
@property (nonatomic, strong, readwrite) RELayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong, readwrite) REConfigurationDelegate * configurationDelegate;

@end

@interface RemoteElement (FlagsAndOptionsPrivate)

@property (nonatomic, assign)    uint64_t    primitiveFlags;
@property (nonatomic, assign)    uint64_t    primitiveAppearance;
@property (nonatomic, readwrite) REType      type;
@property (nonatomic, readwrite) RESubtype   subtype;
@property (nonatomic, readwrite) REState     state;

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
- (BOOL)isAppearanceSetForBits:(uint64_t)bits;

@end

@interface RemoteElement (CoreDataGeneratedAccessors)

@property (nonatomic) NSMutableSet            * primitiveConstraints;
@property (nonatomic) NSMutableSet            * primitiveFirstItemConstraints;
@property (nonatomic) NSMutableSet            * primitiveSecondItemConstraints;
@property (nonatomic) NSMutableOrderedSet     * primitiveSubelements;
@property (nonatomic) REConfigurationDelegate * primitiveConfigurationDelegate;
@property (nonatomic) RemoteElement           * primitiveParentElement;
@property (nonatomic) NSString                * primitiveDisplayName;
@property (nonatomic) NSString                * primitiveKey;

@end


@interface RERemote ()

@property (nonatomic, strong, readonly)  RERemoteController * controller;

@end

@interface RERemote (CoreDataGeneratedAccessors)

@property (nonatomic) RERemoteController * primitiveController;

@end

@interface REButtonGroup ()

@property (nonatomic, strong, readwrite) RERemote           * parentElement;
@property (nonatomic, weak,   readonly)  RERemoteController * controller;

@end

@interface REButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic) RECommandSet * primitiveCommandSet;

@end

@interface REPickerLabelButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic, strong) RECommandSetCollection * primitiveCommandSetCollection;

@end

@class REControlStateButtonImageSetProxy,
       REControlStateColorSetProxy,
       REControlStateIconImageSetProxy,
       REControlStateTitleSetProxy;

@interface REButton ()
{
    REControlStateTitleSetProxy          * __titles;
    REControlStateIconImageSetProxy      * __icons;
    REControlStateColorSetProxy          * __backgroundColors;
    REControlStateButtonImageSetProxy    * __images;
}

@property (nonatomic, strong, readwrite) REButtonGroup      * parentElement;
@property (nonatomic, weak,   readonly)  RERemoteController * controller;

@end

@interface REButton (CoreDataGeneratedAccessors)

@property (nonatomic) NSValue * primitiveTitleEdgeInsets;
@property (nonatomic) NSValue * primitiveImageEdgeInsets;
@property (nonatomic) NSValue * primitiveContentEdgeInsets;

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

