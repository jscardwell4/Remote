//
// CommandSet.h
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CommandContainer.h"

@class   Command, IRCode, REButtonGroup;

@interface CommandSet : CommandContainer {
    @private
}

@property (nonatomic, strong) NSString    * name;
@property (nonatomic, strong) REButtonGroup * buttonGroup;

+ (NSString *)keyForTag:(NSUInteger)tag;

- (void)setCommand:(Command *)command forKey:(NSString *)key;
- (void)setCommand:(Command *)command forTag:(NSUInteger)tag;
- (void)setCommandFromIRCode:(IRCode *)irCode forKey:(NSString *)key;
- (void)setCommandFromIRCode:(IRCode *)irCode forTag:(NSUInteger)tag;

- (Command *)commandForKey:(NSString *)key;
- (Command *)commandForTag:(NSUInteger)tag;
- (Command *)commandForURI:(NSURL *)commandURI;

@end
