//
// Constants.h
// Remote
//
// Created by Jason Cardwell on 6/19/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
// #import <UIKit/UIKit.h>
// #import <Foundation/Foundation.h>

extern const int   kQueueKey;

MSKIT_EXTERN_STRING MSDefaultFontName;
MSKIT_EXTERN_STRING MSArrowFontName;
MSKIT_EXTERN_STRING MSUpArrow;
MSKIT_EXTERN_STRING MSDownArrow;
MSKIT_EXTERN_STRING MSLeftArrow;
MSKIT_EXTERN_STRING MSRightArrow;

/**
 * Returns the default color for highlighted icons or text.
 * @return `UIColor` object for the default color.
 */
UIColor * defaultTitleHighlightColor(void);

/**
 * Returns the default color for text.
 * @return `UIColor` object for the default color.
 */
UIColor * defaultTitleColor(void);

/**
 * Returns the default color for button backgrounds.
 * @return `UIColor` object for the default color.
 */
UIColor * defaultBGColor(void);

/**
 * Returns the default color for gloss effects
 * @return `UIColor` object for the default color.
 */
UIColor * defaultGlossColor(void);

/**
 * Returns the default font for button and button group text.
 * @return `UIFont` object with the default font.
 */
UIFont * defaultFont(void);
