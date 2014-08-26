//
//  BankableModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "NamedModelObject.h"
#import "Bank.h"

@interface BankableModelObject : NamedModelObject<Bankable>

@property (nonatomic, copy, readwrite) NSString * category;
@property (nonatomic, copy, readwrite) NSNumber * user;

+ (NSFetchedResultsController *)bankableItems;

@end
