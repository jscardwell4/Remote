//
// MacroBuilder.h
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   MacroCommand;

@interface MacroBuilder : NSObject

+ (MacroBuilder *)macroBuilderWithContext:(NSManagedObjectContext *)context;
- (MacroCommand *)activityMacroForActivity:(NSUInteger)activity
                           toInitiateState:(BOOL)isOnState
                               switchIndex:(NSInteger *)switchIndex;
- (NSSet *)deviceConfigsForActivity:(NSUInteger)activity;
@property (nonatomic, weak) NSManagedObjectContext * buildContext;

@end
