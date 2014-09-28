//
//  BankableModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"
#import "Bank.h"
/** Protocol to ensure all bank objects have the necessary info to display */


@interface BankableModelObject : NamedModelObject <BankableModel>

@end
