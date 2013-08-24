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

@interface RemoteElement ()

@property (nonatomic, assign, readwrite) REType                    type;
@property (nonatomic, strong, readwrite) REConstraintManager     * constraintManager;
@property (nonatomic, strong, readwrite) RELayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong, readwrite) REConfigurationDelegate * configurationDelegate;

@end

@interface RemoteElement (CoreDataGeneratedAccessors)

@property (nonatomic) NSNumber                * primitiveType;
@property (nonatomic) NSNumber                * primitiveSubtype;
@property (nonatomic) NSNumber                * primitiveOptions;
@property (nonatomic) NSNumber                * primitiveState;
@property (nonatomic) NSNumber                * primitiveShape;
@property (nonatomic) NSNumber                * primitiveStyle;
@property (nonatomic) NSNumber                * primitiveThemeFlags;
@property (nonatomic) NSMutableSet            * primitiveConstraints;
@property (nonatomic) NSMutableSet            * primitiveFirstItemConstraints;
@property (nonatomic) NSMutableSet            * primitiveSecondItemConstraints;
@property (nonatomic) NSMutableOrderedSet     * primitiveSubelements;
@property (nonatomic) REConfigurationDelegate * primitiveConfigurationDelegate;
@property (nonatomic) RemoteElement           * primitiveParentElement;
@property (nonatomic) NSString                * primitiveName;
@property (nonatomic) NSString                * primitiveKey;
@property (nonatomic) UIColor                 * primitiveBackgroundColor;

@end


@interface RERemote ()

@property (nonatomic, strong, readonly)  RERemoteController * controller;
@property (nonatomic, strong, readwrite) NSDictionary       * panels;

@end

@interface RERemote (CoreDataGeneratedAccessors)

@property (nonatomic) RERemoteController * primitiveController;
@property (nonatomic) NSDictionary       * primitivePanels;

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

@property (nonatomic, strong, readwrite) REButtonGroup      * parentElement;
@property (nonatomic, weak,   readonly)  RERemoteController * controller;

@end

@interface REButton (CoreDataGeneratedAccessors)

@property (nonatomic) RECommand * primitiveCommand;
@property (nonatomic) NSValue   * primitiveTitleEdgeInsets;
@property (nonatomic) NSValue   * primitiveImageEdgeInsets;
@property (nonatomic) NSValue   * primitiveContentEdgeInsets;

@end


#import "RERemoteController.h"
#import "BankObjects.h"
#import "RECommand.h"
#import "RECommandContainer.h"
#import "REConfigurationDelegate.h"
#import "REControlStateSet.h"
#import "BankObject.h"
#import "CoreDataManager.h"
#import "RETheme.h"
#import "MSRemoteImportSupportFunctions.h"
