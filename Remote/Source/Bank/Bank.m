//
//  Bank.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"
#import "BankCollectionViewController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface Bank ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation Bank

+ (NSArray *)registeredClasses
{
    return @[@"IRCode", @"Image", @"ComponentDevice", @"Preset", @"Manufacturer"];
}

- (UIViewController *)viewController
{
    if (!_viewController)
        self.viewController = [[UIStoryboard storyboardWithName:@"Bank" bundle:nil]
                               instantiateInitialViewController];
    return _viewController;
}

+ (UIViewController<BankableDetailDelegate> *)detailControllerForItem:(id<Bankable>)item
{
    MSLogDebug(@"item name: %@", item.name);
    Class itemDetailClass = [[item class] detailViewControllerClass];
    assert(   itemDetailClass
           && [itemDetailClass conformsToProtocol:@protocol(BankableDetailDelegate)]);
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Bank" bundle:nil];
    UIViewController<BankableDetailDelegate> * viewController =
    (UIViewController<BankableDetailDelegate> *)
    [storyboard instantiateViewControllerWithClassNameIdentifier:itemDetailClass];
    viewController.item = item;
    return viewController;
}

+ (UIViewController<BankableDetailDelegate> *)editingControllerForItem:(id<Bankable>)item
{
    UIViewController<BankableDetailDelegate> * viewController = [self detailControllerForItem:item];
    [viewController editItem];
    return viewController;
}

@end

@class IRCode, ComponentDevice, Manufacturer, Preset, Image;

@interface BankInfo ()

@property (nonatomic, strong) IRCode          * code;
@property (nonatomic, strong) ComponentDevice * componentDevice;
@property (nonatomic, strong) Manufacturer    * manufacturer;
@property (nonatomic, strong) Preset          * preset;
@property (nonatomic, strong) Image           * image;

@end

@implementation BankInfo

@dynamic category, name, code, componentDevice, manufacturer, preset, image;

- (void)setUser:(BOOL)user
{
    [self willChangeValueForKey:@"user"];
    [self setPrimitiveValue:@(user) forKey:@"user"];
    [self didChangeValueForKey:@"user"];
}

- (BOOL)user
{
    [self willAccessValueForKey:@"user"];
    NSNumber * user = [self primitiveValueForKey:@"user"];
    [self didAccessValueForKey:@"user"];
    return [user boolValue];
}

- (NSString *)containingClass
{
    if (self.componentDevice)   return @"ComponentDevice";
    else if (self.code)         return @"IRCode";
    else if (self.manufacturer) return @"Manufacturer";
    else if (self.preset)       return @"Preset";
    else if (self.image)        return @"Image";
    else                        return @"none";
}

- (id)JSONObject { return [self.JSONDictionary JSONObject]; }

- (NSString *)JSONString { return [self.JSONDictionary JSONString]; }

- (MSDictionary *)JSONDictionary
{
    id(^defaultForKey)(BankInfo *, NSString *) = ^(BankInfo *info, NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          MSDictionary * dictionary = [MSDictionary dictionary];
                          for (NSString * name in @[@"ComponentDevice",
                                                    @"Manufacturer",
                                                    @"IRCode",
                                                    @"Preset",
                                                    @"Image",
                                                    @"none"])
                          {
                              BOOL useDefault = [@"none" isEqualToString:name];
                              MSDictionary * d = [MSDictionary dictionary];
                              d[@"category"] =
                                  CollectionSafe([self defaultValueForAttribute:@"category"
                                                                  forContainingClass:(useDefault
                                                                                      ? nil
                                                                                      : name)]);

                              d[@"user"] =
                              CollectionSafe([self defaultValueForAttribute:@"user"
                                                         forContainingClass:(useDefault
                                                                             ? nil
                                                                             : name)]);
                              [d compact];

                              if ([d count]) dictionary[name] = d;
                          }

                          index = dictionary;
                      });
        
        return index[[info containingClass]][key];
    };


    MSDictionary * dictionary = [MSDictionary dictionary];

    dictionary[@"name"] = self.name;

    if (![self.category isEqualToString:defaultForKey(self, @"category")])
        dictionary[@"category"] = self.category;

    if (![@(self.user) isEqualToNumber:defaultForKey(self, @"user")])
        dictionary[@"user"] = @(self.user);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

@end
