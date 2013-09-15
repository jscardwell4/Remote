//
// RemoteElement_Private.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"
#import "LayoutConfiguration.h"
#import "Constraint.h"

@interface RemoteElement ()

@property (nonatomic, assign, readwrite) REType                    type;
@property (nonatomic, strong, readwrite) ConstraintManager     * constraintManager;
@property (nonatomic, strong, readwrite) LayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong, readwrite) ConfigurationDelegate * configurationDelegate;

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
@property (nonatomic) ConfigurationDelegate * primitiveConfigurationDelegate;
@property (nonatomic) RemoteElement           * primitiveParentElement;
@property (nonatomic) NSString                * primitiveName;
@property (nonatomic) NSString                * primitiveKey;
@property (nonatomic) UIColor                 * primitiveBackgroundColor;

@end


@interface Remote ()

@property (nonatomic, strong, readonly)  RemoteController * controller;
@property (nonatomic, strong, readwrite) NSDictionary       * panels;

@end

@interface Remote (CoreDataGeneratedAccessors)

@property (nonatomic) RemoteController * primitiveController;
@property (nonatomic) NSDictionary       * primitivePanels;

@end

@interface ButtonGroup ()

@property (nonatomic, strong, readwrite) Remote           * parentElement;
@property (nonatomic, weak,   readonly)  RemoteController * controller;

@end

@interface ButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic) CommandSet * primitiveCommandSet;

@end

@interface PickerLabelButtonGroup (CoreDataGeneratedAccessors)

@property (nonatomic, strong) CommandSetCollection * primitiveCommandSetCollection;

@end

@class ControlStateButtonImageSetProxy,
       ControlStateColorSetProxy,
       ControlStateIconImageSetProxy,
       ControlStateTitleSetProxy;

@interface Button ()

@property (nonatomic, strong, readwrite) ButtonGroup      * parentElement;
@property (nonatomic, weak,   readonly)  RemoteController * controller;

@end

@interface Button (CoreDataGeneratedAccessors)

@property (nonatomic) Command * primitiveCommand;
@property (nonatomic) NSValue   * primitiveTitleEdgeInsets;
@property (nonatomic) NSValue   * primitiveImageEdgeInsets;
@property (nonatomic) NSValue   * primitiveContentEdgeInsets;

@end


#import "RemoteController.h"
#import "BankObjects.h"
#import "Command.h"
#import "CommandContainer.h"
#import "ConfigurationDelegate.h"
#import "ControlStateSet.h"
#import "CoreDataManager.h"
#import "Theme.h"
#import "MSRemoteImportSupportFunctions.h"
