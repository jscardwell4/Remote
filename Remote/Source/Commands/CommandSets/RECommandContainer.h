//
// RECommandContainer.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command Container
////////////////////////////////////////////////////////////////////////////////

@interface RECommandContainer : MSModelObject

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context;
- (BOOL)isValidKey:(NSString *)key;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set
////////////////////////////////////////////////////////////////////////////////
@class   RECommand, BOIRCode, REButtonGroup;

@interface RECommandSet : RECommandContainer

+ (instancetype)commandSetWithType:(RECommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(RECommandSetType)type;
+ (instancetype)commandSetWithType:(RECommandSetType)type
                              name:(NSString *)name
                            values:(NSDictionary *)values;

- (void)setObject:(RECommand *)command forKeyedSubscript:(NSString *)key;
- (RECommand *)objectForKeyedSubscript:(NSString *)key;

@property (nonatomic, strong)   NSString         * name;
@property (nonatomic, readonly) RECommandSetType   type;

@end

/// DPad keys
MSKIT_EXTERN_STRING   REDPadUpButtonKey;
MSKIT_EXTERN_STRING   REDPadDownButtonKey;
MSKIT_EXTERN_STRING   REDPadLeftButtonKey;
MSKIT_EXTERN_STRING   REDPadRightButtonKey;
MSKIT_EXTERN_STRING   REDPadOkButtonKey;

/// Numberpad keys
MSKIT_EXTERN_STRING   REDigitZeroButtonKey;
MSKIT_EXTERN_STRING   REDigitOneButtonKey;
MSKIT_EXTERN_STRING   REDigitTwoButtonKey;
MSKIT_EXTERN_STRING   REDigitThreeButtonKey;
MSKIT_EXTERN_STRING   REDigitFourButtonKey;
MSKIT_EXTERN_STRING   REDigitFiveButtonKey;
MSKIT_EXTERN_STRING   REDigitSixButtonKey;
MSKIT_EXTERN_STRING   REDigitSevenButtonKey;
MSKIT_EXTERN_STRING   REDigitEightButtonKey;
MSKIT_EXTERN_STRING   REDigitNineButtonKey;
MSKIT_EXTERN_STRING   REAuxOneButtonKey;
MSKIT_EXTERN_STRING   REAuxTwoButtonKey;

/// Rocker keys
MSKIT_EXTERN_STRING   RERockerButtonPlusButtonKey;
MSKIT_EXTERN_STRING   RERockerButtonMinusButtonKey;

/// Transport keys
MSKIT_EXTERN_STRING   RETransportRewindButtonKey;
MSKIT_EXTERN_STRING   RETransportRecordButtonKey;
MSKIT_EXTERN_STRING   RETransportNextButtonKey;
MSKIT_EXTERN_STRING   RETransportStopButtonKey;
MSKIT_EXTERN_STRING   RETransportFastForwardButtonKey;
MSKIT_EXTERN_STRING   RETransportPreviousButtonKey;
MSKIT_EXTERN_STRING   RETransportPauseButtonKey;
MSKIT_EXTERN_STRING   RETransportPlayButtonKey;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set Collections
////////////////////////////////////////////////////////////////////////////////


@interface RECommandSetCollection : RECommandContainer

@property (nonatomic, strong) NSOrderedSet * commandSets;

- (void)setObject:(NSAttributedString *)label forKeyedSubscript:(RECommandSet *)commandSet;
- (NSAttributedString *)objectForKeyedSubscript:(RECommandSet *)commandSet;

@end

@interface RECommandSetCollection (CommandSetAccessors)

- (void)insertObject:(RECommandSet *)value inCommandSetsAtIndex:(NSUInteger)index;
- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index;
- (void)insertCommandSets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommandSetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommandSetsAtIndex:(NSUInteger)index withObject:(RECommandSet *)value;
- (void)replaceCommandSetsAtIndexes:(NSIndexSet *)indexes withCommandSets:(NSArray *)values;
- (void)addCommandSetsObject:(RECommandSet *)value;
- (void)removeCommandSetsObject:(RECommandSet *)value;
- (void)addCommandSets:(NSOrderedSet *)values;
- (void)removeCommandSets:(NSOrderedSet *)values;

@end
