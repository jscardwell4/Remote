//
// BankObjectPreview.m
// Remote
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObjectPreview.h"
#import "CoreDataManager.h"

@interface BankObjectPreview ()
@property (nonatomic, strong) NSData * imageData;
@end

@interface BankObjectPreview (CoreDataGeneratedAccessors)
@property (nonatomic) NSString * primitiveUuid;
@end

@implementation BankObjectPreview

@dynamic imageData, tag, name, uuid;

@synthesize image = _image;

+ (instancetype)previewInContext:(NSManagedObjectContext *)context
{
    assert(context);
    __block BankObjectPreview * preview = nil;
    [context performBlockAndWait:^{ preview = NSManagedObjectFromClass(context); }];
    return preview;
}

+ (instancetype)previewWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(name && context);

    __block BankObjectPreview * preview = nil;
    [context performBlockAndWait:
     ^{
         preview = [self previewInContext:context];
         preview.name = name;
     }];

    return preview;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.primitiveUuid = MSNonce();
}

- (void)setImage:(UIImage *)image
{
    assert(image);
    _image = image;
    self.imageData = UIImagePNGRepresentation(_image);
}

- (UIImage *)image
{
    if (!_image && self.imageData)
        _image = [UIImage imageWithData:self.imageData scale:MainScreenScale];
    return _image;
}

@end