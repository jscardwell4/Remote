//
// BankObjectPreview.h
// Remote
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"

@interface BankObjectPreview : ModelObject <NamedModelObject>

@property (nonatomic) 			 		int16_t     tag;
@property (nonatomic, strong)   NSString  * name;

+ (instancetype)previewInContext:(NSManagedObjectContext *)context;

+ (instancetype)previewWithName:(NSString *)name context:(NSManagedObjectContext *)context;

//+ (NSArray *)previewImages;

@property (nonatomic, strong) UIImage * image;

@end
