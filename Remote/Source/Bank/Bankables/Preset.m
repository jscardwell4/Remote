//
// Preset.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Preset.h"
#import "RemoteElement.h"
#import "CoreDataManager.h"
#import "RemoteElementView_Private.h"
#import "Bank.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@implementation Preset

@dynamic element, info;

+ (instancetype)presetWithElement:(RemoteElement *)element
{
    assert(element);
    __block Preset * preset = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         preset = [self createInContext:element.managedObjectContext];
         preset.element = element;
         NSString * category = nil;
         switch (element.elementType)
         {
             case RETypeRemote:
                 category = @"Remote";
                 break;

             case RETypeButtonGroup:
                 category = @"Button Group";
                 break;

             case RETypeButton:
                 category = @"Button";
                 break;

             default:
                 category = @"Uncategorized";
                 break;
         }
         preset.category = category;
     }];
    return preset;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    if (ModelObjectShouldInitialize) self.user = YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Presets"; }

+ (BankFlags)bankFlags { return (BankPreview|BankThumbnail|BankEditable|BankDetail); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
