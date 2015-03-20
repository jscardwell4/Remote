//
//  ModelKeychainWrapper.h
//  Remote
//
//  Created by Jason Cardwell on 9/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

@import Foundation;

@interface ModelKeychainWrapper : NSObject

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)resetKeychainItem;

@end
