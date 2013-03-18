//
// BankObjectButtonPreview.m
// Remote
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BankObjectPreview_Private.h"

@implementation BankObjectButtonPreview

+ (BankObjectButtonPreview *)buttonPreviewWithName:(NSString *)name
                                        context:(NSManagedObjectContext *)context {
    return (BankObjectButtonPreview *)[super previewWithName:name context:context];
}

@end
