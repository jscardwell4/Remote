//
//  NamedModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 11/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "NamedModelObject.h"

@interface NamedModelObject (CoreDataGenerated)
@property (nonatomic) NSString * primitiveName;
@end

@implementation NamedModelObject

@dynamic name;

- (NSString *)name {
  [self willAccessValueForKey:@"name"];
  NSString * name = self.primitiveName;
  if (!name) {
    NSUInteger entityCount = [[self class] countOfObjectsWithPredicate:nil context:self.managedObjectContext];
    self.primitiveName = $(@"%@%@", self.className, @(entityCount));
    name = self.primitiveName;
  }
  [self didAccessValueForKey:@"name"];
  return name;
}

- (NSString *)commentedUUID
{
    NSString * uuid = self.uuid;
    if (uuid)
    {
        NSString * name = self.name;
        if (name) uuid.comment = MSSingleLineComment(name);
    }

    return uuid;
}

@end
