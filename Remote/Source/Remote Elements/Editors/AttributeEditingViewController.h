//
// AttributeEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
MSEXTERN_STRING   kAttributeEditingFontSizeKey;
MSEXTERN_STRING   kAttributeEditingFontNameKey;
MSEXTERN_STRING   kAttributeEditingEdgeInsetsKey;
MSEXTERN_STRING   kAttributeEditingTitleTextKey;
MSEXTERN_STRING   kAttributeEditingTitleColorKey;
MSEXTERN_STRING   kAttributeEditingColorKey;
MSEXTERN_STRING   kAttributeEditingBoundsKey;
MSEXTERN_STRING   kAttributeEditingButtonKey;
MSEXTERN_STRING   kAttributeEditingControlStateKey;
MSEXTERN_STRING   kAttributeEditingImageKey;

@interface AttributeEditingViewController : UIViewController <MSResettable>

- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues;

@end
