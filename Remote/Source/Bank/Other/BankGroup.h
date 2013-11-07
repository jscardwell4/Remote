//
// BankGroup.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Group
////////////////////////////////////////////////////////////////////////////////
@interface BankGroup : NamedModelObject

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@end
