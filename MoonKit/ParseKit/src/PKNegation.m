//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PKNegation.h"
#import "PKAny.h"
#import "PKDifference.h"
@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@interface PKNegation ()
@property (nonatomic, retain, readwrite) PKParser *subparser;
@property (nonatomic, retain) PKParser *difference;
@end

@implementation PKNegation

+ (PKNegation *)negationWithSubparser:(PKParser *)s {
    return [[[self alloc] initWithSubparser:s] autorelease];
}


- (id)initWithSubparser:(PKParser *)s {
    self = [super init];
    if (self) {
        self.subparser = s;
    }
    return self;
}


- (void)dealloc {
    self.subparser = nil;
    self.difference = nil;
    [super dealloc];
}


- (PKParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    } else {
        return [subparser parserNamed:s];
    }
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    
    return [difference allMatchesFor:inAssemblies];
}


- (void)add:(PKParser *)p {
    NSParameterAssert([p isKindOfClass:[PKParser class]]);
    NSAssert(!subparser, @"");
    self.subparser = p;
}


- (void)setSubparser:(PKParser *)p {
    if (p != subparser) {
        [subparser autorelease];
        subparser = [p retain];
        
        self.difference = [PKDifference differenceWithSubparser:[PKAny any] minus:subparser];
    }
}

@synthesize subparser;
@synthesize difference;
@end
