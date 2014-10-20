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
#import "CoreDataManager.h"

@interface Activity (CoreDataGenerateAccessors)

@property (nonatomic, strong) Remote * primitiveRemote;

@end

@implementation Activity

@dynamic launchMacro, haltMacro, remote;

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

  self.name        = data[@"name"]                                                         ?: self.name;
  self.remote      = [Remote importObjectFromData:data[@"remote"] context:moc]             ?: self.remote;
  self.launchMacro = [MacroCommand importObjectFromData:data[@"launch-macro"] context:moc] ?: self.launchMacro;
  self.haltMacro   = [MacroCommand importObjectFromData:data[@"halt-macro"] context:moc]   ?: self.haltMacro;

}

+ (BOOL)isNameAvailable:(NSString *)name {
  return ([Activity countOfObjectsWithPredicate:NSPredicateMake(@"name EQUALS %@", name)] == 0);
}

- (void)launchActivity:(void (^)(BOOL, NSError *))completion {

  RemoteController * controller = [RemoteController remoteController:self.managedObjectContext];

  if (self.launchMacro) {

    __weak Activity * weakself = self;

    [self.launchMacro execute:^(BOOL success, NSError * error) {

      if (!error && success) {

        controller.currentActivity = weakself;
        success = (controller.currentRemote == weakself.remote);

          if (completion) completion(success, nil);

      } else if (completion) completion(NO, error);

      }];

  } else {

      controller.currentActivity = self;
      BOOL success = (controller.currentRemote == self.remote);

      if (completion) completion(success, nil);

    }

}

- (void)haltActivity:(void (^)(BOOL, NSError *))completion {

  RemoteController * controller = [RemoteController remoteController:self.managedObjectContext];

  if (self.haltMacro && controller.currentActivity == self) {

    __weak Activity * weakself = self;

    [self.haltMacro execute:^(BOOL success, NSError * error) {

      if (!error && success) {

        controller.currentActivity = nil;
        success = (controller.currentRemote == controller.homeRemote);

        if (completion) completion(success, nil);

      } else if (completion) completion(NO, error);

    }];

  } else if (controller.currentActivity == self ) {

    controller.currentActivity = nil;
    BOOL success = (controller.currentRemote == controller.homeRemote);

    if (completion) completion(success, nil);

  } else if (completion) completion(NO, nil);


}

- (void)launchOrHault:(void (^)(BOOL success, NSError * error))completion {

  RemoteController * controller = [RemoteController remoteController:self.managedObjectContext];

  if (controller.currentActivity == self) [self haltActivity:completion];
  else {
    if (controller.currentActivity == nil) [self launchActivity:completion];
    else {
      __weak Activity * weakself = self;
      [controller.currentActivity haltActivity:^(BOOL success, NSError *error) {
        [weakself launchActivity:completion];
      }];
    }
  }

}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.remote.commentedUUID,       @"remote.uuid",  dictionary);
  SafeSetValueForKey(self.launchMacro.JSONDictionary, @"launch-macro", dictionary);
  SafeSetValueForKey(self.haltMacro.JSONDictionary,   @"halt-macro",   dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (NSDictionary *)deepDescriptionDictionary {
  Activity * activity = [self faultedObject];

  assert(activity);

  NSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"name"]        = (activity.name ?: @"nil");
  dd[@"remote"]      = namedModelObjectDescription(activity.remote);
  dd[@"launchMacro"] = namedModelObjectDescription(activity.launchMacro);
  dd[@"haltMacro"]   = namedModelObjectDescription(activity.haltMacro);

  return dd;
}

@end
