//
// ControlStateButtonImageSet.m
// iPhonto
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"
#import "Button.h"
#import "GalleryImage.h"

@implementation ControlStateButtonImageSet

+ (ControlStateButtonImageSet *)imageSetForButton:(Button *)button {
    if (ValueIsNil(button)) return nil;

    ControlStateButtonImageSet * imageSet =
        [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateButtonImageSet"
                                      inManagedObjectContext:button.managedObjectContext];

    imageSet.button = button;

    return imageSet;
}

@end
