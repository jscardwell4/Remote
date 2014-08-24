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


- (void)updateFromData:(NSDictionary *)data {

    [super updateWithData:data];

    NSDictionary * titles            = data[@"titles"];
    NSDictionary * commands          = data[@"commands"];
    NSDictionary * icons             = data[@"icons"];
    NSDictionary * images            = data[@"images"];
    NSDictionary * backgroundColors  = data[@"backgroundColors"];
    NSString     * titleEdgeInsets   = data[@"titleEdgeInsets"];
    NSString     * contentEdgeInsets = data[@"contentEdgeInsets"];
    NSString     * imageEdgeInsets   = data[@"imageEdgeInsets"];
    NSManagedObjectContext * moc = self.managedObjectContext;

    if (titles) {
        for (NSString * mode in titles) {
            ControlStateTitleSet * titleSet = [self.buttonConfigurationDelegate titlesForMode:mode];
            if (titleSet) { [moc deleteObject:titleSet]; titleSet = nil; }
            titleSet = [ControlStateTitleSet importObjectFromData:titles[mode] inContext:moc];
            if (titleSet) [self.buttonConfigurationDelegate setTitles:titleSet mode:mode];
        }
    }

    if (icons) {
        for (NSString * mode in icons) {
            ControlStateImageSet * iconSet = [self.buttonConfigurationDelegate iconsForMode:mode];
            if (iconSet) { [moc deleteObject:iconSet]; iconSet = nil; }
            iconSet = [ControlStateImageSet importObjectFromData:icons[mode] inContext:moc];
            if (iconSet) [self.buttonConfigurationDelegate setIcons:iconSet mode:mode];
        }
    }

    if (images) {
        for (NSString * mode in images) {
            ControlStateImageSet * imageSet = [self.buttonConfigurationDelegate imagesForMode:mode];
            if (imageSet) { [moc deleteObject:imageSet]; imageSet = nil; }
            imageSet = [ControlStateImageSet importObjectFromData:images[mode] inContext:moc];
            if (imageSet) [self.buttonConfigurationDelegate setImages:imageSet mode:mode];
        }
    }

    if (backgroundColors) {
        for (NSString * mode in backgroundColors) {
            ControlStateColorSet * colorSet = [self.buttonConfigurationDelegate backgroundColorsForMode:mode];
            if (colorSet) { [moc deleteObject:colorSet]; colorSet = nil; }
            colorSet = [ControlStateColorSet importObjectFromData:backgroundColors[mode]
                                                        inContext:moc];
            if (colorSet) [self.buttonConfigurationDelegate setBackgroundColors:colorSet mode:mode];
        }
    }

    if (commands) {
        for (NSString * mode in commands) {
            Command * command = [Command importObjectFromData:commands inContext:moc];
            if (command) [self.buttonConfigurationDelegate setCommand:command mode:mode];
        }
    }

    if (titleEdgeInsets)   self.titleEdgeInsets   = UIEdgeInsetsFromString(titleEdgeInsets);
    if (contentEdgeInsets) self.contentEdgeInsets = UIEdgeInsetsFromString(contentEdgeInsets);
    if (imageEdgeInsets)   self.imageEdgeInsets   = UIEdgeInsetsFromString(imageEdgeInsets);

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
