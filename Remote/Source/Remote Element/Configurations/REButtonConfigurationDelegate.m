//
// REButtonConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "REConfigurationDelegate_Private.h"
#import "REControlStateSet.h"
#import "RECommand.h"

@implementation REButtonConfigurationDelegate

@dynamic commands, titles, icons, images, backgroundColors;

+ (instancetype)delegateForRemoteElement:(REButton *)element
{
    __block REButtonConfigurationDelegate * configurationDelegate = nil;
    assert(element);
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating Configurations
////////////////////////////////////////////////////////////////////////////////
- (void)updateConfigForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    NSString * uuid = self[$(@"%@.command", configuration)];
    if (uuid)
        ((REButton *)self.element).command = (RECommand *)memberOfCollectionWithUUID(self.commands, uuid);

    uuid = self[$(@"%@.titles", configuration)];
    if (uuid && self.titlesProxy)
        [__titlesProxy
             updateProxyObject:(REControlStateSet *)memberOfCollectionWithUUID(self.titles, uuid)
                        sender:self];
    
    uuid = self[$(@"%@.icons", configuration)];
    if (uuid && self.iconsProxy)
        [__iconsProxy
             updateProxyObject:(REControlStateSet *)memberOfCollectionWithUUID(self.icons, uuid)
                        sender:self];

    uuid = self[$(@"%@.images", configuration)];
    if (uuid && self.imagesProxy)
        [__imagesProxy
             updateProxyObject:(REControlStateSet *)memberOfCollectionWithUUID(self.images, uuid)
                        sender:self];

    uuid = self[$(@"%@.backgroundColors", configuration)];
    if (uuid && self.backgroundColorsProxy)
        [__backgroundColorsProxy
             updateProxyObject:(REControlStateSet *)memberOfCollectionWithUUID(self.backgroundColors,
                                                                               uuid)
                        sender:self];
}

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)config
{
    assert(command && config);
    [self addCommandsObject:command];
    self[$(@"%@.command", config)] = command.uuid;
}

- (void)setTitles:(REControlStateTitleSet *)titles forConfiguration:(RERemoteConfiguration)config
{
    assert(titles && config);
    [self addTitlesObject:titles];
    self[$(@"%@.titles", config)] = titles.uuid;
}

- (void)setBackgroundColors:(REControlStateColorSet *)colors forConfiguration:(RERemoteConfiguration)config
{
    assert(colors && config);
    [self addBackgroundColorsObject:colors];
    self[$(@"%@.backgroundColor", config)] = colors.uuid;
}

- (void)setIcons:(REControlStateIconImageSet *)icons forConfiguration:(RERemoteConfiguration)config
{
    assert(icons && config);
    [self addIconsObject:icons];
    self[$(@"%@.icons", config)] = icons.uuid;
}

- (void)setImages:(REControlStateButtonImageSet *)images forConfiguration:(RERemoteConfiguration)config
{
    assert(images && config);
    [self addImagesObject:images];
    self[$(@"%@.images",config)] = images.uuid;
}

- (void)setTitle:(id)title forConfiguration:(RERemoteConfiguration)config
{
    if ([title isKindOfClass:[NSString class]])
        title = [NSAttributedString attributedStringWithString:(NSString *)title];

    NSString * uuid = self[$(@"%@.titles", config)];
    if (!uuid)
    {
        REControlStateTitleSet * titles = [REControlStateTitleSet
                                             MR_createInContext:self.managedObjectContext];
        titles[UIControlStateNormal] = title;
        [self setTitles:titles forConfiguration:config];
    }

    else
    {
        REControlStateTitleSet * titles =
            (REControlStateTitleSet *)memberOfCollectionWithUUID(self.titles, uuid);
        titles[UIControlStateNormal] = title;

    }


}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Proxy Accessors and Delegate Methods
////////////////////////////////////////////////////////////////////////////////

- (void)didInstantiateProxyObject:(NSString *)uuid forProxy:(REControlStateSetProxy *)proxy
{

}

- (REControlStateColorSetProxy *)backgroundColorsProxy
{
    if (!__backgroundColorsProxy)
    {
        __backgroundColorsProxy = [REControlStateColorSetProxy proxyWithDelegate:self];
        __weak REButtonConfigurationDelegate * weakself = self;
        __backgroundColorsProxy.instanstiationBlock =
        ^id (REControlStateSetProxy * proxy)
        {
            REControlStateColorSet * colorSet =
                [REControlStateColorSet controlStateSetInContext:weakself.managedObjectContext];
            RERemoteConfiguration config = [weakself.currentConfiguration copy];
            [weakself setBackgroundColors:colorSet forConfiguration:config];
            return colorSet;
        };
    }
    return __backgroundColorsProxy;
}

- (REControlStateIconImageSetProxy *)iconsProxy
{
    if (!__iconsProxy)
    {
        __iconsProxy = [REControlStateIconImageSetProxy proxyWithDelegate:self];
        __weak REButtonConfigurationDelegate * weakself = self;
        __iconsProxy.instanstiationBlock =
        ^id (REControlStateSetProxy * proxy)
        {
            REControlStateIconImageSet * iconSet =
                [REControlStateIconImageSet controlStateSetInContext:weakself.managedObjectContext];
            RERemoteConfiguration config = [weakself.currentConfiguration copy];
            [weakself setIcons:iconSet forConfiguration:config];
            return iconSet;
        };
    }
    return __iconsProxy;
}

- (REControlStateButtonImageSetProxy *)imagesProxy
{
    if (!__imagesProxy)
    {
        __weak REButtonConfigurationDelegate * weakself = self;
        __imagesProxy.instanstiationBlock =
        ^id (REControlStateSetProxy * proxy)
        {
            REControlStateButtonImageSet * imageSet =
                [REControlStateButtonImageSet controlStateSetInContext:weakself.managedObjectContext];
            RERemoteConfiguration config = [weakself.currentConfiguration copy];
            [weakself setImages:imageSet forConfiguration:config];
            return imageSet;
        };
        __imagesProxy = [REControlStateButtonImageSetProxy proxyWithDelegate:self];
    }
    return __imagesProxy;
}

- (REControlStateTitleSetProxy *)titlesProxy
{
    if (!__titlesProxy)
    {
        __titlesProxy = [REControlStateTitleSetProxy proxyWithDelegate:self];
        __weak REButtonConfigurationDelegate * weakself = self;
        __titlesProxy.instanstiationBlock =
        ^id (REControlStateSetProxy * proxy)
        {
            REControlStateTitleSet * titleSet =
                [REControlStateTitleSet controlStateSetInContext:weakself.managedObjectContext];
            RERemoteConfiguration config = [weakself.currentConfiguration copy];
            [weakself setTitles:titleSet forConfiguration:config];
            return titleSet;
        };
    }
    return __titlesProxy;
}



@end
