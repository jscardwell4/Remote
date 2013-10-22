//
//  UIStoryboard+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSKitMacros.h"

@interface UIStoryboard (MSKitAdditions)

- (UIViewController *)instantiateViewControllerWithClassNameIdentifier:(Class)controllerClass;

@end


#define UIStoryboardInstantiateSceneByClassName(CLASSNAME) \
((CLASSNAME *)[self.storyboard instantiateViewControllerWithIdentifier:NSStringify(CLASSNAME)])
