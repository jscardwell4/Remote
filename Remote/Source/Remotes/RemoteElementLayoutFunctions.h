//
// RemoteElementLayoutFunctions.h
// iPhonto
//
// Created by Jason Cardwell on 1/20/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

/*
 * typedef NS_ENUM(uint8_t, RemoteElementLayoutAxisDimension) {
 *  RemoteElementLayoutXAxis,
 *  RemoteElementLayoutYAxis,
 *  RemoteElementLayoutWidthDimension,
 *  RemoteElementLayoutHeightDimension
 * };
 *
 * typedef NS_ENUM(uint8_t, RemoteElementLayoutAttribute) {
 *  RemoteElementLayoutAttributeHeight  = 1 << 0,
 *  RemoteElementLayoutAttributeWidth   = 1 << 1,
 *  RemoteElementLayoutAttributeCenterY = 1 << 2,
 *  RemoteElementLayoutAttributeCenterX = 1 << 3,
 *  RemoteElementLayoutAttributeBottom  = 1 << 4,
 *  RemoteElementLayoutAttributeTop     = 1 << 5,
 *  RemoteElementLayoutAttributeRight   = 1 << 6,
 *  RemoteElementLayoutAttributeLeft    = 1 << 7
 * };
 */

/*
 * typedef NS_ENUM(uint8_t, RemoteElementLayout) {
 *  RemoteElementLayoutConfigurationXYWH = 0xF,  // 15
 *  RemoteElementLayoutConfigurationXYWT = 0x2E, // 46
 *  RemoteElementLayoutConfigurationXYWB = 0x1E, // 30
 *  RemoteElementLayoutConfigurationXYLH = 0x8D, // 141
 *  RemoteElementLayoutConfigurationXYLT = 0xAC, // 172
 *  RemoteElementLayoutConfigurationXYLB = 0x9C, // 156
 *  RemoteElementLayoutConfigurationXYRH = 0x4D, // 77
 *  RemoteElementLayoutConfigurationXYRT = 0x6C, // 108
 *  RemoteElementLayoutConfigurationXYRB = 0x5C, // 92
 *  RemoteElementLayoutConfigurationXTBW = 0x3A, // 58
 *  RemoteElementLayoutConfigurationXTBL = 0xB8, // 184
 *  RemoteElementLayoutConfigurationXTBR = 0x78, // 120
 *  RemoteElementLayoutConfigurationXTHW = 0x2B, // 43
 *  RemoteElementLayoutConfigurationXTHL = 0xA9, // 169
 *  RemoteElementLayoutConfigurationXTHR = 0x69, // 105
 *  RemoteElementLayoutConfigurationXBHW = 0x1B, // 27
 *  RemoteElementLayoutConfigurationXBHL = 0x99, // 153
 *  RemoteElementLayoutConfigurationXBHR = 0x59, // 89
 *  RemoteElementLayoutConfigurationLRYH = 0xC5, // 197
 *  RemoteElementLayoutConfigurationLRYT = 0xE4, // 228
 *  RemoteElementLayoutConfigurationLRYB = 0xD4, // 212
 *  RemoteElementLayoutConfigurationLRTB = 0xF0, // 240
 *  RemoteElementLayoutConfigurationLRTH = 0xE1, // 225
 *  RemoteElementLayoutConfigurationLRBH = 0xD1, // 209
 *  RemoteElementLayoutConfigurationLWYH = 0x87, // 135
 *  RemoteElementLayoutConfigurationLWYT = 0xA6, // 166
 *  RemoteElementLayoutConfigurationLWYB = 0x96, // 150
 *  RemoteElementLayoutConfigurationLWTB = 0xB2, // 178
 *  RemoteElementLayoutConfigurationLWTH = 0xA3, // 163
 *  RemoteElementLayoutConfigurationLWBH = 0x93, // 147
 *  RemoteElementLayoutConfigurationRWYL = 0x47, // 71
 *  RemoteElementLayoutConfigurationRWYT = 0x66, // 102
 *  RemoteElementLayoutConfigurationRWYB = 0x56, // 86
 *  RemoteElementLayoutConfigurationRWTB = 0x72, // 114
 *  RemoteElementLayoutConfigurationRWTH = 0x63, // 99
 *  RemoteElementLayoutConfigurationRWBH = 0x53  // 83
 * };
 */

// BOOL isValidLayoutConfiguration(RemoteElementLayout configuration);

// NSArray * conflictsForLayoutAttribute(RemoteElementLayoutAttribute attribute);

// RemoteElementLayoutAttribute configurationAttributeForAxisDimension(RemoteElementLayout
// configuration, RemoteElementLayoutAxisDimension axisDimension);

// NSString * NSStringFromRemoteElementLayoutConfiguration(RemoteElementLayoutConfiguration
// configuration);
