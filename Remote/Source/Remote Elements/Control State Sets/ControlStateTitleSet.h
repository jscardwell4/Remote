//
// ControlStateTitleSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateTitleSet : ControlStateSet

@property (nonatomic) BOOL suppressNormalStateAttributes;

+ (Class)validClassForAttributeKey:(NSString *)key;
+ (Class)validClassForParagraphAttributeKey:(NSString *)key;
+ (Class)validClassForAttributeName:(NSString *)name;
+ (Class)validClassForParagraphAttributeName:(NSString *)name;

@end
