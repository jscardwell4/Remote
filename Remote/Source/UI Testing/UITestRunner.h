//
// UITestRunner.h
// Remote
//
// Created by Jason Cardwell on 1/15/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

/**
 *
 * Bit vector assignments for `UITestCode`
 *
 *  0xFF 0xFF   0xFF 0xFF  0xFF 0xFF  0xFF 0xFF
 * └───────────┴──────────┴──────────┴───────────┘
 *     ⬇           ⬇        ⬇          ⬇
 *   state       number     focus        test
 *
 */
typedef NS_OPTIONS (uint64_t, UITestCode) {
    UITestTypeUnspecified            = 0 << 0xF,
        UITestTypeRemoteEditing      = 0x1,
        UITestTypeButtonGroupEditing = 0x2,
        UITestTypeButtonEditing      = 0x4,
        UITestTypeReservedType       = 0xFFF8,
        UITestTypeMask               = 0XFFFF000000000000 >> 0x30,

        UITestFocusUnspecified = 0 << 0x1F,
        UITestFocusInfo        = 0x1 << 0x10,
        UITestFocusTranslation = 0x2 << 0x10,
        UITestFocusScale       = 0x4 << 0x10,
        UITestFocusFocus       = 0x8 << 0x10,
        UITestFocusDialog      = 0x10 << 0x10,
        UITestFocusAlignment   = 0x20 << 0x10,
        UITestFocusReserved    = 0xFFF0 << 0x10,
        UITestFocusMask        = 0XFFFF000000000000 >> 0x20,

        UITestNumberDefault = 0 << 0x20,
        UITestNumberOffset  = 0x20,
        UITestNumberMask    = 0XFFFF000000000000 >> 0x10,

        UITestOptionsMask   = 0xFFFF << 0x30,
        UITestOptionsOffset = 0x30
};

@class   MSRemoteUITest;

@interface UITestRunner : NSObject

+ (void)showDialog;

+ (void)setSuppressDialog:(BOOL)suppressDialog;

+ (BOOL)shouldSuppressDialog;

+ (void)runTests:(NSArray *)tests;

@end

#define SLEEP_DURATION        1
#define SHOULD_LOG_QUEUE_NAME NO
#define LOG_QUEUE_NAME                                                         \
    do {if (SHOULD_LOG_QUEUE_NAME) DDLogDebug(@"%@ running on queue: %@",      \
                                              ClassTagSelectorString,          \
                                              [[NSOperationQueue currentQueue] \
                                               name]);} while (0)

MSKIT_STATIC_INLINE NSString * NSStringFromUITestCode(UITestCode testCode) {
    static NSDictionary const * names = nil;
    static dispatch_once_t      onceToken;

    dispatch_once(&onceToken, ^{
        names = @{@(UITestTypeUnspecified)        : @"Unspecified",
                  @(UITestTypeRemoteEditing)      : @"RemoteEditing",
                  @(UITestTypeButtonGroupEditing) : @"ButtonGroupEditing",
                  @(UITestTypeButtonEditing)      : @"ButtonEditing",
                  @(UITestFocusUnspecified)       : @"Unspecified",
                  @(UITestFocusInfo)              : @"Info",
                  @(UITestFocusTranslation)       : @"Translation",
                  @(UITestFocusScale)             : @"Scale",
                  @(UITestFocusFocus)             : @"Focus",
                  @(UITestFocusAlignment)         : @"Alignment"};
    }

                  );

    return [NSString stringWithFormat:@"Type:%@  Focus:%@  Number:%i  Options:%i",
            names[@(testCode & UITestTypeMask)],
            names[@(testCode & UITestFocusMask)],
            (int)((testCode & UITestNumberMask) >> UITestNumberOffset),
            (int)((testCode & UITestOptionsMask) >> UITestOptionsOffset)];
}

