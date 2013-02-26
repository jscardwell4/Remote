//
// FactoryIRCode.h
// iPhonto
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IRCode.h"

@class   IRCodeSet;

@interface FactoryIRCode : IRCode
+ (IRCode *)newCodeInCodeSet:(IRCodeSet *)set;
+ (IRCode *)newCodeFromProntoHex:(NSString *)hex inCodeSet:(IRCodeSet *)set;

@property (nonatomic, strong) IRCodeSet * codeSet;

@end
