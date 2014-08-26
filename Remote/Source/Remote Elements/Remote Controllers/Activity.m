//
//  Activity.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Activity.h"
#import "Command.h"
#import "RemoteController.h"
#import "RemoteElement.h"
#import "Remote.h"
#import "RemoteElementImportSupportFunctions.h"

@interface Activity ()

@property (nonatomic, strong) RemoteController * controller;

@end

@interface Activity (CoreDataGenerateAccessors)

@property (nonatomic, strong) Remote * primitiveRemote;

@end

@implementation Activity

@dynamic launchMacro, haltMacro, remote, name;
@synthesize controller = _controller;

+ (instancetype)activityWithName:(NSString *)name {
  return [self activityWithName:name inContext:[CoreDataManager defaultContext]];
}

+ (instancetype)activityWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
  Activity * activity = [self createInContext:context];

  activity.name = name;

  return activity;
}

- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  NSManagedObjectContext * moc = self.managedObjectContext;

  self.name        = data[@"name"]                                                        ?: self.name;
  self.remote      = [Remote importObjectFromData:data[@"remote"] context:moc]            ?: self.remote;
  self.launchMacro = [MacroCommand importObjectFromData:data[@"launchMacro"] context:moc] ?: self.launchMacro;
  self.haltMacro   = [MacroCommand importObjectFromData:data[@"haltMacro"] context:moc]   ?: self.haltMacro;

}

- (BOOL)updateName:(NSString *)name {

  if ([Activity countOfObjectsWithPredicate:NSPredicateMake(@"name EQUALS %@", name)])
    return NO;

  self.name = name;
  return YES;

}

- (void)awakeFromFetch {
  [super awakeFromFetch];
  self.controller = [RemoteController remoteController:self.managedObjectContext];
}

- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.controller = [RemoteController remoteController:self.managedObjectContext];
}

- (BOOL)launchActivity {

  if (!self.controller) return NO;

  __block BOOL launchReturned  = NO;
  __block BOOL launchSucceeded = NO;

  if (self.launchMacro)
    [self.launchMacro execute:^(BOOL success, NSError * error) {
      if (!error && success) {
        self.controller.currentRemote = self.remote;
        launchSucceeded = self.controller.currentRemote == self.remote;
      }
      launchReturned = YES;
    }];

  else {
    self.controller.currentRemote = self.remote;
    launchSucceeded               = self.controller.currentRemote == self.remote;
    launchReturned                = YES;
  }

  while (!launchReturned) ;

  return launchSucceeded;

}

- (void)launchActivity:(void (^)(BOOL, NSError *))completion {

  if (self.controller) {

    if (self.launchMacro)

      [self.launchMacro execute:^(BOOL success, NSError * error) {
        if (!error && success) {
          self.controller.currentRemote = self.remote;
          success = self.controller.currentRemote == self.remote;

          if (completion) completion(success, nil);
        }

        else if (completion) completion(NO, nil);
      }];

    else {

      self.controller.currentRemote = self.remote;
      BOOL success = self.controller.currentRemote == self.remote;

      if (completion) completion(success, nil);
    }

  } else completion(NO, nil);

}

- (BOOL)haltActivity {

  __block BOOL haltReturned  = NO;
  __block BOOL haltSucceeded = NO;

  if (!self.controller) return NO;

  if (self.haltMacro) {

    [self.haltMacro execute:^(BOOL success, NSError * error) {
      if (!error && success)
        self.controller.currentRemote = self.controller.homeRemote;
        haltSucceeded = self.controller.currentRemote == self.controller.homeRemote;

      haltReturned = YES;
    }];

  } else {

    self.controller.currentRemote = self.controller.homeRemote;
    haltSucceeded = self.controller.currentRemote == self.controller.homeRemote;
    haltReturned  = YES;

  }

  while (!haltReturned) ;

  return haltSucceeded;
}

- (void)haltActivity:(void (^)(BOOL, NSError *))completion {

  if (self.controller) {

    if (self.haltMacro)
      [self.haltMacro execute:^(BOOL success, NSError * error) {
        if (!error && success) {
          self.controller.currentRemote = self.controller.homeRemote;
          success = self.controller.currentRemote == self.controller.homeRemote;

          if (completion) completion(success, nil);

        } else if (completion) completion(NO, nil);
      }];

    else {
      self.controller.currentRemote = self.controller.homeRemote;
      BOOL success = self.controller.currentRemote == self.controller.homeRemote;

      if (completion) completion(success, nil);
    }

  } else completion(NO, nil);

}

- (BOOL)launchOrHault {
  if (!self.controller) return NO;
  else return (self.controller.currentActivity == self ? [self haltActivity] : [self launchActivity]);
}

- (void)launchOrHault:(void (^)(BOOL success, NSError * error))completion {
  if (self.controller.currentActivity == self)
    [self haltActivity:completion];

  else if (self.controller)
    [self launchActivity:completion];

  else if (completion)
    completion(NO, nil);
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  dictionary[@"name"]             = CollectionSafe(self.name);
  dictionary[@"remote.uuid"]      = CollectionSafe(self.remote.commentedUUID);

  MSDictionary * launch = self.launchMacro.JSONDictionary;
  if (launch) {
    [launch removeObjectForKey:@"class"];
    dictionary[@"launchMacro"] = launch;
  }

  MSDictionary * halt = self.haltMacro.JSONDictionary;
  if (halt) {
    [halt removeObjectForKey:@"class"];
    dictionary[@"haltMacro"] = halt;
  }

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (NSDictionary *)deepDescriptionDictionary {
  Activity * activity = [self faultedObject];

  assert(activity);

  NSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"name"]        = (activity.name ?: @"nil");
  dd[@"controller"]  = (activity.controller.uuid ?: @"nil");
  dd[@"remote"]      = namedModelObjectDescription(activity.remote);
  dd[@"launchMacro"] = namedModelObjectDescription(activity.launchMacro);
  dd[@"haltMacro"]   = namedModelObjectDescription(activity.haltMacro);

  return dd;
}

@end
