//
// CommandSetManagerButtonGroup.h
// iPhonto
//
// Created by Jason Cardwell on 6/22/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ButtonGroupView.h"

@class   CommandSet, IRCode;

@interface CommandSetManagerButtonGroupView : ButtonGroupView {}

- (void)registerCommandSet:(CommandSet *)commandSet forConfiguration:(NSString *)configuration;
- (void)setButtonCommandFromIRCode:(IRCode *)irCode forKey:(NSString *)key;
- (void)setButtonCommandFromIRCode:(IRCode *)irCode forTag:(NSUInteger)tag;

@property (nonatomic, strong) NSMutableDictionary * commandSets;
@property (nonatomic, strong) CommandSet          * currentCommandSet;

@end
