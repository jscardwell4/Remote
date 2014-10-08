//
// BankObjectPreview.h
// Remote
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "NamedModelObject.h"

@interface BankObjectPreview : NamedModelObject

@property (nonatomic) int16_t     tag;

+ (instancetype)previewInContext:(NSManagedObjectContext *)context;

+ (instancetype)previewWithName:(NSString *)name context:(NSManagedObjectContext *)context;

//+ (NSArray *)previewImages;

@property (nonatomic, strong) UIImage * image;

@end
