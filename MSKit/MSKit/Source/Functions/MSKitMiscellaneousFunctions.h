//
//  MSKitMiscellaneousFunctions.h
//  Remote
//
//  Created by Jason Cardwell on 4/22/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

NSString * MSNonce();

void MSRunSyncOnMain(dispatch_block_t block);
void MSRunAsyncOnMain(dispatch_block_t block);
void MSSwapInstanceMethodsForClass(Class c, SEL m1, SEL m2);
void MSSwapInstanceMethods(Class c1, SEL m1, Class c2, SEL m2);
void MSRunOnMainWithDelay(dispatch_block_t block, dispatch_time_t delay);

BOOL MSSelectorInProtocol(SEL selector, Protocol * protocol, BOOL isRequired, BOOL isInstance);