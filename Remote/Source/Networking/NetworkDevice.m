//
// NetworkDevice.m
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "NetworkDevice.h"
#import "CoreDataManager.h"
#import "ITachDevice.h"
#import "ISYDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract
////////////////////////////////////////////////////////////////////////////////


@interface NetworkDevice ()
@property (nonatomic, copy, readwrite) NSString * uniqueIdentifier;
@end

@implementation NetworkDevice

@dynamic uniqueIdentifier, componentDevices;

/// deviceExistsWithDeviceUUID:
/// @param identifier
/// @return BOOL
+ (BOOL)deviceExistsWithUniqueIdentifier:(NSString *)identifier {
  return [self countOfObjectsWithPredicate:NSPredicateMake(@"uniqueIdentifer == %@", identifier)] > 0;
}

/// importObjectFromData:context:
/// @param data
/// @param moc
/// @return instancetype
+ (instancetype)importObjectFromData:(NSDictionary *)data context:(NSManagedObjectContext *)moc {

  if (self == [NetworkDevice class] && [@"itach" isEqualToString:data[@"type"]])
    return [ITachDevice importObjectFromData:data context:moc];

  else if (self == [NetworkDevice class] && [@"isy" isEqualToString:data[@"type"]])
    return [ISYDevice importObjectFromData:data context:moc];

  else
    return [super importObjectFromData:data context:moc];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Import/Export
////////////////////////////////////////////////////////////////////////////////


/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.uniqueIdentifier = data[@"unique-identifier"];
  self.name             = data[@"name"];

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.name,             @"name",              dictionary);
  SafeSetValueForKey(self.uniqueIdentifier, @"unique-identifier", dictionary);


  return dictionary;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////


/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"Network Devices"; }

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"937-gray-wifi-signal"]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }


@end
