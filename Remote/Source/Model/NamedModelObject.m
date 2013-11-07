//
//  NamedModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 11/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "NamedModelObject.h"

@implementation NamedModelObject

@dynamic name;

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
