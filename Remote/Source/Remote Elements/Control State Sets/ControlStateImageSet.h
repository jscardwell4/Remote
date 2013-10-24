//
// ControlStateImageSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class Image, ControlStateColorSet;

@interface ControlStateImageSet : ControlStateSet

+ (ControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

+ (ControlStateImageSet *)imageSetWithColors:(id)colors
                                        images:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

- (UIImage *)UIImageForState:(NSUInteger)state;

- (Image *)objectAtIndexedSubscript:(NSUInteger)state;

@property (nonatomic, strong) ControlStateColorSet * colors;

@end

