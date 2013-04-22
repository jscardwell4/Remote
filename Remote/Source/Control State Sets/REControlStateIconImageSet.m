//
// ControlStateIconImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REControlStateSet.h"
#import "BankObject.h"

static int   ddLogLevel = LOG_LEVEL_OFF;
#pragma unused(ddLogLevel)

@interface REControlStateIconImageSet (CoreDataGeneratedAccessors)

@property (nonatomic, strong) REControlStateColorSet * primitiveIconColors;

@end

@implementation REControlStateIconImageSet

@dynamic iconColors;

+ (REControlStateIconImageSet *)iconSetWithColors:(NSDictionary *)colors
                                            icons:(NSDictionary *)icons
                                          context:(NSManagedObjectContext *)context
{
    assert(context && colors && icons);
    for (id obj in [colors allValues])
        assert([obj isKindOfClass:[UIColor class]]);
    for (id obj in [icons allValues])
        assert([obj isKindOfClass:[BOIconImage class]]);

    
    __block REControlStateIconImageSet * iconSet = nil;

    [context performBlockAndWait:
     ^{
         iconSet = [self controlStateSetInContext:context withObjects:icons];
         [iconSet.iconColors setValuesForKeysWithDictionary:colors];
     }];

    return iconSet;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.iconColors = [REControlStateColorSet controlStateSetInContext:self.managedObjectContext];
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

@end
