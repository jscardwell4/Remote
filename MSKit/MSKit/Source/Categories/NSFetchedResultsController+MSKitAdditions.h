//
//  NSFetchedResultsController+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 9/28/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (MSKitAdditions)

- (id)objectForKeyedSubscript:(id)key;

@end
