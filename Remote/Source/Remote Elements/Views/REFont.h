//
//  REFont.h
//  Remote
//
//  Created by Jason Cardwell on 10/30/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"

@import Foundation;

@interface REFont : NSObject <NSCoding>

@property (nonatomic, copy)     NSString * fontName;
@property (nonatomic, copy)     NSNumber * pointSize;
@property (nonatomic, readonly) NSString * stringValue;
@property (nonatomic, readonly) UIFont   * UIFontValue;

+ (instancetype)fontWithName:(NSString *)name size:(NSNumber *)size;
+ (instancetype)fontFromString:(NSString *)string;
+ (instancetype)fontFromFont:(UIFont *)font;

@end

#define REFontMake(NAME, SIZE) [REFont fontWithName:NAME size:SIZE]
#define REFontFromString(STRING) [REFont fontFromString:STRING]

@interface NSString (REFont)

- (NSArray *)fontComponents;

@end
