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

/** called by MagicalRecord **/

- (BOOL)shouldImportCommand:(id)data {return YES;}

- (BOOL)shouldImportLongPressCommand:(id)data {return YES;}

- (void)importContentEdgeInsets:(id)data {self.contentEdgeInsets = UIEdgeInsetsFromString(data);}
- (void)importTitleEdgeInsets:(id)data {self.titleEdgeInsets = UIEdgeInsetsFromString(data);}
- (void)importImageEdgeInsets:(id)data {self.imageEdgeInsets = UIEdgeInsetsFromString(data);}

/** called from didImportData: **/

- (void)importTitles:(NSDictionary *)data
{
    // iterate over modes
    for (NSString * mode in data)
        [self.buttonConfigurationDelegate
         setTitles:[ControlStateTitleSet MR_importFromObject:data[mode]
                                                   inContext:self.managedObjectContext]
         mode:mode];
}

- (void)importIcons:(NSDictionary *)data
{
    // iterate over modes
    for (NSString * mode in data)
    {
        assert(isStringKind(mode));

        // get the data for this mode
        MSDictionary * icons = [MSDictionary dictionaryWithDictionary:data[mode]];
        if (!icons) continue;

        // grab the colors and replace values with actual color objects
        ControlStateColorSet * colorSet = nil;
        MSDictionary * colors = [MSDictionary dictionaryWithDictionary:icons[@"colors"]];
        if (colors)
        {
            // remove colors from icons dictionary
            [icons removeObjectForKey:@"colors"];

            [colors enumerateKeysAndObjectsUsingBlock:
             ^(id key, id obj, BOOL *stop)
             {
                 if ([ControlStateSet stateForProperty:key] == NSUIntegerMax)
                     colors[key] = NullObject;
                 else
                     colors[key] = CollectionSafe(colorFromImportValue(colors[key]));
             }];

            [colors compact];

            colorSet = [ControlStateColorSet controlStateSetInContext:self.managedObjectContext
                                                          withObjects:colors];
        }

        // grab icon objects
        for (NSString * key in icons)
        {
            // replace icon data with icon object
            NSDictionary * iconData = icons[key];
            NSString * uuid = iconData[@"uuid"];

            icons[key] = CollectionSafe([Image objectWithUUID:uuid
                                                      context:self.managedObjectContext]);
        }

        [icons compact];

        ControlStateImageSet * iconSet = [ControlStateImageSet
                                          imageSetWithColors:colorSet
                                          images:icons
                                          context:self.managedObjectContext];
        if (iconSet)
            [self.buttonConfigurationDelegate setIcons:iconSet mode:mode];
    }
}

- (void)importImages:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        MSDictionary * images = data[mode];
        if (!images) continue;

        ControlStateColorSet * colorSet = nil;
        NSDictionary * colors = images[@"colors"];
        if (colors)
        {
            [images removeObjectForKey:@"colors"];

            MSDictionary * filteredColors = [MSDictionary dictionary];
            [colors enumerateKeysAndObjectsUsingBlock:
             ^(id key, id obj, BOOL *stop)
             {
                 UIColor * color = colorFromImportValue(colors[key]);
                 if (color) filteredColors[key] = color;
             }];

            colorSet = [ControlStateColorSet controlStateSetInContext:self.managedObjectContext
                                                          withObjects:filteredColors];
        }

        for (NSString * key in images)
        {
            NSString * uuid = images[key][@"uuid"];
            if (!uuid)
                [images removeObjectForKey:key];

            else
                images[key] = uuid;
        }

        ControlStateImageSet * imageSet = [ControlStateImageSet
                                           imageSetWithColors:colorSet
                                           images:images
                                           context:self.managedObjectContext];
        if (imageSet)
            [self.buttonConfigurationDelegate setImages:imageSet mode:mode];
    }
}

- (void)importCommands:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        NSDictionary * commandData = data[mode];
        if (!commandData) continue;

        NSString * classKey = commandData[@"class"];
        Class commandClass = commandClassForImportKey(classKey);
        if (!commandClass) continue;

        Command * command = [commandClass MR_importFromObject:commandData
                                                    inContext:self.managedObjectContext];
        if (command)
        {
            if ([mode isEqualToString:REDefaultMode])
                self.command = command;

            else
                [self.buttonConfigurationDelegate setCommand:command mode:mode];
        }
    }
}

- (void)importBackgroundColors:(NSDictionary *)data
{
    for (NSString * mode in data)
    {
        NSDictionary * colors = data[mode];
        if (!colors) continue;

        MSDictionary * filteredColors = [MSDictionary dictionary];
        [colors enumerateKeysAndObjectsUsingBlock:
         ^(id key, id obj, BOOL *stop)
         {
             UIColor * color = colorFromImportValue(colors[key]);
             if (color)
             {
                 filteredColors[key] = color;

                 if ([mode isEqualToString:REDefaultMode] && [key isEqualToString:@"normal"])
                     self.backgroundColor = color;
             }
         }];

        ControlStateColorSet * colorSet = [ControlStateColorSet
                                           controlStateSetInContext:self.managedObjectContext
                                           withObjects:filteredColors];
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

    ButtonConfigurationDelegate * delegate = (ButtonConfigurationDelegate *)self.configurationDelegate;
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
