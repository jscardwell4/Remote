//
//  Bank.h
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ModelObject.h"

@protocol Bankable <NamedModelObject>

// Class info
+ (NSString *)directoryLabel;
+ (BOOL)isPreviewable;
+ (BOOL)isEditable;
+ (NSOrderedSet *)directoryItems;

// Object info
- (NSString *)category;
- (UIImage *)thumbnail;
- (UIImage *)preview;
- (UIViewController *)editingViewController;
- (NSOrderedSet *)subBankables;

@end

@interface Bank : MSSingletonController

@end
