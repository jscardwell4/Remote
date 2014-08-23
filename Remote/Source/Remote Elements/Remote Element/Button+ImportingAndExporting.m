//
//  Button+ImportingAndExporting.m
//  Remote
//
//  Created by Jason Cardwell on 11/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Button.h"
#import "RemoteElement_Private.h"

@implementation Button (ImportingAndExporting)


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


/*
- (void)didImport:(id)data
{
    [super didImport:data];
    if (![data isKindOfClass:[NSDictionary class]]) return;

    if ([data hasKey:@"titles"])
        [self importTitles:data[@"titles"]];

    else if ([data hasKey:@"title"])
        [self importTitles:@{@"default":@{@"normal":data[@"title"]}}];

    if ([data hasKey:@"commands"])
        [self importCommands:data[@"commands"]];

    else if ([data hasKey:@"command"])
        [self importCommands:@{@"default":data[@"command"]}];

    if ([data hasKey:@"icons"])
        [self importIcons:data[@"icons"]];

    else if ([data hasKey:@"icon"])
        [self importIcons:@{@"default":@{@"normal":data[@"icon"]}}];

    if ([data hasKey:@"images"])
        [self importImages:data[@"images"]];

    else if ([data hasKey:@"image"])
        [self importImages:@{@"default":@{@"normal":data[@"image"]}}];

    if ([data hasKey:@"backgroundColors"])
        [self importBackgroundColors:data[@"backgroundColors"]];

    else if ([data hasKey:@"backgroundColor"])
        [self importBackgroundColors:@{@"default":@{@"normal":data[@"backgroundColor"]}}];
}
*/

/** called by MagicalRecord **/

- (BOOL)shouldImportCommand:(id)data {return YES;}

- (BOOL)shouldImportLongPressCommand:(id)data {return YES;}

- (void)importContentEdgeInsets:(id)data {self.contentEdgeInsets = UIEdgeInsetsFromString(data);}
- (void)importTitleEdgeInsets:(id)data {self.titleEdgeInsets = UIEdgeInsetsFromString(data);}
- (void)importImageEdgeInsets:(id)data {self.imageEdgeInsets = UIEdgeInsetsFromString(data);}

/** called from didImportData: **/

- (void)importTitles:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        ControlStateTitleSet * titleSet = [ControlStateTitleSet
                                           importObjectFromData:data[mode]
                                                     inContext:self.managedObjectContext];

        if (titleSet) [self.buttonConfigurationDelegate setTitles:titleSet mode:mode];
    }
}

- (void)importIcons:(NSDictionary *)data
{
    // iterate over modes
    for (NSString * mode in data)
    {
        ControlStateImageSet * imageSet = [ControlStateImageSet
                                           importObjectFromData:data[mode]
                                                     inContext:self.managedObjectContext];

        if (imageSet) [self.buttonConfigurationDelegate setIcons:imageSet mode:mode];
    }
}

- (void)importImages:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        ControlStateImageSet * imageSet = [ControlStateImageSet
                                           importObjectFromData:data[mode]
                                                     inContext:self.managedObjectContext];

        if (imageSet) [self.buttonConfigurationDelegate setImages:imageSet mode:mode];
    }
}

- (void)importCommands:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        Command * command = [Command importObjectFromData:data[mode]
                                               inContext:self.managedObjectContext];
        if (command) [self.buttonConfigurationDelegate setCommand:command mode:mode];
    }
}

- (void)importBackgroundColors:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        ControlStateColorSet * colorSet = [ControlStateColorSet
                                           importObjectFromData:data[mode]
                                                     inContext:self.managedObjectContext];

        if (colorSet) [self.buttonConfigurationDelegate setBackgroundColors:colorSet mode:mode];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    dictionary[@"backgroundColor"] = NullObject;

    ButtonConfigurationDelegate * delegate = self.buttonConfigurationDelegate;
    NSArray * configurations = delegate.modeKeys;

    MSDictionary * titles           = [MSDictionary dictionary];
    MSDictionary * backgroundColors = [MSDictionary dictionary];
    MSDictionary * icons            = [MSDictionary dictionary];
    MSDictionary * images           = [MSDictionary dictionary];
    MSDictionary * commands         = [MSDictionary dictionary];

    for (RERemoteMode mode in configurations)
    {
        ControlStateSet * stateSet = [delegate titlesForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) titles[mode] = [stateSet JSONDictionary];

        stateSet = [delegate backgroundColorsForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) backgroundColors[mode] = [stateSet JSONDictionary];

        stateSet = [delegate iconsForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) icons[mode] = [stateSet JSONDictionary];

        stateSet = [delegate imagesForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) images[mode] = [stateSet JSONDictionary];

        Command * command = [delegate commandForMode:mode];
        if (command) commands[mode] = [command JSONDictionary];

    }

    dictionary[@"commands"]          = ([commands count] ? commands : NullObject);
    dictionary[@"titles"]            = ([titles count] ? titles : NullObject) ;
    dictionary[@"icons"]             = ([icons count] ? icons : NullObject);
    dictionary[@"backgroundColors"]  = ([backgroundColors count] ? backgroundColors : NullObject);
    dictionary[@"images"]            = ([images count] ? images : NullObject);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.titleEdgeInsets))
        dictionary[@"titleEdgeInsets"] = NSStringFromUIEdgeInsets(self.titleEdgeInsets);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.imageEdgeInsets))
        dictionary[@"imageEdgeInsets"] = NSStringFromUIEdgeInsets(self.imageEdgeInsets);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.contentEdgeInsets))
        dictionary[@"contentEdgeInsets"] = NSStringFromUIEdgeInsets(self.contentEdgeInsets);

    [dictionary compact];
    [dictionary compress];
    
    return dictionary;
}

@end
