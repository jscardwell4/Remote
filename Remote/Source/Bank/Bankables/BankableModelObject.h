//
//  BankableModelObject.h
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ModelObject.h"
#import "Bank.h"

@interface BankableModelObject : ModelObject<Bankable>

@property (nonatomic, strong, readonly) BankInfo * info;

@end
