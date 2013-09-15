//
// ControlStateIconImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "BankObject.h"

static int   ddLogLevel = LOG_LEVEL_OFF;
#pragma unused(ddLogLevel)

@interface ControlStateIconImageSet (CoreDataGeneratedAccessors)

@property (nonatomic, strong) ControlStateColorSet * primitiveIconColors;

@end

@implementation ControlStateIconImageSet

@dynamic iconColors;

+ (ControlStateIconImageSet *)iconSetWithIcons:(NSDictionary *)icons
                                         context:(NSManagedObjectContext *)context
{
    return [self iconSetWithColors:@{} icons:icons context:context];
}

+ (ControlStateIconImageSet *)iconSetWithColors:(NSDictionary *)colors
                                            icons:(NSDictionary *)icons
                                          context:(NSManagedObjectContext *)context
{
//    assert(context && colors && icons);
//    for (id obj in [colors allValues])
//        assert([obj isKindOfClass:[UIColor class]]);
//    for (id obj in [icons allValues])
//        assert([obj isKindOfClass:[BOIconImage class]]);

    
    __block ControlStateIconImageSet * iconSet = nil;
    NSMutableDictionary * filteredIcons = [icons mutableCopy];
    [icons enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         if ([obj isKindOfClass:[NSNumber class]])
             filteredIcons[key] = [BOIconImage fetchImageWithTag:[(NSNumber *)obj integerValue]
                                                         context:context];
     }];

    [context performBlockAndWait:
     ^{
         iconSet = [self controlStateSetInContext:context withObjects:filteredIcons];
         [iconSet.iconColors setValuesForKeysWithDictionary:colors];
     }];

    return iconSet;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        self.iconColors = [ControlStateColorSet controlStateSetInContext:self.managedObjectContext];
}

- (UIImage *)UIImageForState:(NSUInteger)state
{
    BOIconImage * icon = self[state];
    UIColor * color = self.iconColors[state];
    UIImage * image = [icon imageWithColor:color];
    return image;
}

- (BOIconImage *)objectAtIndexedSubscript:(NSUInteger)state
{
    return (BOIconImage *)[super objectAtIndexedSubscript:state];
}

- (void)copyObjectsFromSet:(ControlStateIconImageSet *)set
{
    [super copyObjectsFromSet:set];
    [self.iconColors copyObjectsFromSet:set.iconColors];
}

@end
