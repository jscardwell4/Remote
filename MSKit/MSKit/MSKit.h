//
//  MSKit/MSKit.h
//  MSKit
//
//  Created by Jason Cardwell on 9/4/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

/* Functions, definitions, typedefs, macros, protocols */
#import <MSKit/MSKitDefines.h>
#import <MSKit/MSKitMiscellaneousFunctions.h>
#import <MSKit/MSKitLoggingFunctions.h>
#import <MSKit/MSKitMacros.h>

/* Categories */
#import <MSKit/NSObject+MSKitAdditions.h>
#import <MSKit/NSMapTable+MSKitAdditions.h>
#import <MSKit/NSDictionary+MSKitAdditions.h>
#import <MSKit/NSString+MSKitAdditions.h>
#import <MSKit/NSArray+MSKitAdditions.h>
#import <MSKit/NSNull+MSKitAdditions.h>
#import <MSKit/NSSet+MSKitAdditions.h>
#import <MSKit/NSUserDefaults+MSKitAdditions.h>
#import <MSKit/PKAssembly+MSKitAdditions.h>
#import <MSKit/NSRegularExpression+MSKitAdditions.h>
#import <MSKit/NSValue+MSKitAdditions.h>
#import <MSKit/NSOrderedSet+MSKitAdditions.h>
#import <MSKit/NSHashTable+MSKitAdditions.h>
#import <MSKit/NSOperationQueue+MSKitAdditions.h>
#import <MSKit/NSPointerArray+MSKitAdditions.h>

/* objects */
#import <MSKit/MSAssertionHandler.h>
#import <MSKit/MSError.h>
#import <MSKit/MSLog.h>
#import <MSKit/MSBitVector.h>
#import <MSKit/MSQueue.h>
#import <MSKit/MSStack.h>
#import <MSKit/MSDictionary.h>
#import <MSKit/MSDictionaryIndex.h>
#import <MSKit/MSJSONSerialization.h>
#import <MSKit/MSSingleton.h>
#import <MSKit/MSPainter.h>

#if TARGET_OS_IPHONE
#import <MSKit/MSKitGeometryFunctions.h>
#import <MSKit/MSKitProtocols.h>


/* Views */
#import <MSKit/MSView.h>
#import <MSKit/MSMultiselectView.h>
#import <MSKit/MSCheckboxView.h>
#import <MSKit/MSNumberPadView.h>
#import <MSKit/MSTouchReporterView.h>
#import <MSKit/MSPickerInputButton.h>
#import <MSKit/MSPickerInputView.h>
#import <MSKit/MSReplicatorView.h>
#import <MSKit/MSReflectingView.h>
#import <MSKit/MSColorInputView.h>
#import <MSKit/MSColorInputButton.h>

/* Layers */
#import <MSKit/MSResizingLayer.h>

/* Controllers */
#import <MSKit/MSPickerInputViewController.h>
#import <MSKit/MSColorInputViewController.h>

/* Categories */
#import <MSKit/NSFetchRequest+MSKitAdditions.h>
#import <MSKit/UIGestureRecognizer+MSKitAdditions.h>
#import <MSKit/UIImage+MSKitAdditions.h>
#import <MSKit/UIImage+ImageEffects.h>
#import <MSKit/UIColor+MSKitAdditions.h>
#import <MSKit/UIView+MSKitAdditions.h>
#import <MSKit/UIAlertView+MSKitAdditions.h>
#import <MSKit/UIWindow+MSKitAdditions.h>
#import <MSKit/CALayer+MSKitAdditions.h>
#import <MSKit/UIFont+MSKitAdditions.h>
#import <MSKit/NSLayoutConstraint+MSKitAdditions.h>
#import <MSKit/NSManagedObjectContext+MSKitAdditions.h>
#import <MSKit/NSManagedObject+MSKitAdditions.h>
#import <MSKit/UICollectionViewFlowLayout+MSKitAdditions.h>
#import <MSKit/NSURL+MSKitAdditions.h>
#import <MSKit/NSAttributedString+MSKitAdditions.h>
#import <MSKit/UIStoryboard+MSKitAdditions.h>
#import <MSKit/UITableView+MSKitAdditions.h>
#import <MSKit/NSFetchedResultsController+MSKitAdditions.h>
#import <MSKit/UIControl+MSKitAdditions.h>
#import <MSKit/NSNumber+MSKitAdditions.h>
#import <MSKit/MagicalRecord+MSKitAdditions.h>

/* Objects */
#import <MSKit/MSCompletionBlockOperation.h>
#import <MSKit/MSNetworkReachability.h>
#import <MSKit/MSPinchGestureRecognizer.h>
#import <MSKit/MSLongPressGestureRecognizer.h>
#import <MSKit/MSSwipeGestureRecognizer.h>
#import <MSKit/MSMultiselectGestureRecognizer.h>
#import <MSKit/MSPopupBarButton.h>
#import <MSKit/MSValueTransformers.h>
#import <MSKit/MSBarButtonItem.h>
#import <MSKit/MSGestureManager.h>
#import <MSKit/MSKVOReceptionist.h>
#import <MSKit/MSContextChangeReceptionist.h>
#import <MSKit/MSSingletonController.h>

#endif
