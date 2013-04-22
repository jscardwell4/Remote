//
//  OCHamcrest_SelectiveShorthand.h
//  Remote
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
#import <OCHamcrestIOS/OCHamcrestIOS.h>

/**
 * Extracted the shorthand preprocessor define statements from the OCHamcrest
 * framework so that clashing names could be selectively ommitted.
 */
#define allOf                      HC_allOf
#define anyOf                      HC_anyOf
#define assertThat                 HC_assertThat
#define conformsTo                 HC_conformsTo
#define describedAs                HC_describedAs
#define hasCount                   HC_hasCount
#define hasCountOf                 HC_hasCountOf
#define hasDescription             HC_hasDescription
#define hasProperty                HC_hasProperty
#define is                         HC_is
#define anything()                 HC_anything()
#define anythingWithDescription    HC_anythingWithDescription
#define closeTo                    HC_closeTo
#define hasItem                    HC_hasItem
#define hasItems                   HC_hasItems
#define containsInAnyOrder         HC_containsInAnyOrder
#define contains                   HC_contains
#define onlyContains               HC_onlyContains
#define hasEntry                   HC_hasEntry
#define hasEntries                 HC_hasEntries
//#define hasKey                     HC_hasKey
#define hasValue                   HC_hasValue
#define empty()                    HC_empty()
#define equalTo                    HC_equalTo
#define equalToIgnoringCase        HC_equalToIgnoringCase
#define equalToIgnoringWhiteSpace  HC_equalToIgnoringWhiteSpace
#define equalToBool                HC_equalToBool
#define equalToChar                HC_equalToChar
#define equalToDouble              HC_equalToDouble
#define equalToFloat               HC_equalToFloat
#define equalToInt                 HC_equalToInt
#define equalToLong                HC_equalToLong
#define equalToLongLong            HC_equalToLongLong
#define equalToShort               HC_equalToShort
#define equalToUnsignedChar        HC_equalToUnsignedChar
#define equalToUnsignedInt         HC_equalToUnsignedInt
#define equalToUnsignedLong        HC_equalToUnsignedLong
#define equalToUnsignedLongLong    HC_equalToUnsignedLongLong
#define equalToUnsignedShort       HC_equalToUnsignedShort
#define equalToInteger             HC_equalToInteger
#define equalToUnsignedInteger     HC_equalToUnsignedInteger
#define isIn                       HC_isIn
#define instanceOf                 HC_instanceOf
#define nilValue()                 HC_nilValue()
#define notNilValue()              HC_notNilValue()
#define isNot                      HC_isNot
#define sameInstance               HC_sameInstance
#define isA                        HC_isA
#define assertThatBool             HC_assertThatBool
#define assertThatChar             HC_assertThatChar
#define assertThatDouble           HC_assertThatDouble
#define assertThatFloat            HC_assertThatFloat
#define assertThatInt              HC_assertThatInt
#define assertThatLong             HC_assertThatLong
#define assertThatLongLong         HC_assertThatLongLong
#define assertThatShort            HC_assertThatShort
#define assertThatUnsignedChar     HC_assertThatUnsignedChar
#define assertThatUnsignedInt      HC_assertThatUnsignedInt
#define assertThatUnsignedLong     HC_assertThatUnsignedLong
#define assertThatUnsignedLongLong HC_assertThatUnsignedLongLong
#define assertThatUnsignedShort    HC_assertThatUnsignedShort
#define assertThatInteger          HC_assertThatInteger
#define assertThatUnsignedInteger  HC_assertThatUnsignedInteger
#define greaterThan                HC_greaterThan
#define greaterThanOrEqualTo       HC_greaterThanOrEqualTo
#define lessThan                   HC_lessThan
#define lessThanOrEqualTo          HC_lessThanOrEqualTo
#define containsString             HC_containsString
#define stringContainsInOrder      HC_stringContainsInOrder
#define endsWith                   HC_endsWith
#define startsWith                 HC_startsWith
