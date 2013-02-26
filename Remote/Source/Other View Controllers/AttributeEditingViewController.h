//
// AttributeEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
MSKIT_EXTERN_STRING   kAttributeEditingFontSizeKey;
MSKIT_EXTERN_STRING   kAttributeEditingFontNameKey;
MSKIT_EXTERN_STRING   kAttributeEditingEdgeInsetsKey;
MSKIT_EXTERN_STRING   kAttributeEditingTitleTextKey;
MSKIT_EXTERN_STRING   kAttributeEditingTitleColorKey;
MSKIT_EXTERN_STRING   kAttributeEditingColorKey;
MSKIT_EXTERN_STRING   kAttributeEditingBoundsKey;
MSKIT_EXTERN_STRING   kAttributeEditingButtonKey;
MSKIT_EXTERN_STRING   kAttributeEditingControlStateKey;
MSKIT_EXTERN_STRING   kAttributeEditingImageKey;

@interface AttributeEditingViewController : UIViewController <MSResettable>

- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues;

@end
