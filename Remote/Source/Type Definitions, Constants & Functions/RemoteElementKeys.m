//
//  RemoteElementKeys.m
//  Remote
//
//  Created by Jason Cardwell on 11/7/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementKeys.h"
#import "JSONObjectKeys.h"
#import "RemoteElementExportSupportFunctions.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Functions
////////////////////////////////////////////////////////////////////////////////

NSArray * remoteElementAttributeKeys()
{
    static NSArray const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = @[REFontAttributeKey,
                               REParagraphStyleAttributeKey,
                               REForegroundColorAttributeKey,
                               REBackgroundColorAttributeKey,
                               RELigatureAttributeKey,
                               REKernAttributeKey,
                               REStrikethroughStyleAttributeKey,
                               REUnderlineStyleAttributeKey,
                               REStrokeColorAttributeKey,
                               REStrokeWidthAttributeKey,
                               REShadowAttributeKey,
                               RETextEffectAttributeKey,
                               REBaselineOffsetAttributeKey,
                               REUnderlineColorAttributeKey,
                               REStrikethroughColorAttributeKey,
                               REObliquenessAttributeKey,
                               REExpansionAttributeKey,
                               RETitleTextAttributeKey];
                  });
    return (NSArray *)keys;
}

NSArray * remoteElementParagraphAttributeKeys()
{
    static NSArray const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = @[RELineSpacingAttributeKey,
                               REParagraphSpacingAttributeKey,
                               RETextAlignmentAttributeKey,
                               REFirstLineHeadIndentAttributeKey,
                               REHeadIndentAttributeKey,
                               RETailIndentAttributeKey,
                               RELineBreakModeAttributeKey,
                               REMinimumLineHeightAttributeKey,
                               REMaximumLineHeightAttributeKey,
                               RELineHeightMultipleAttributeKey,
                               REParagraphSpacingBeforeAttributeKey,
                               REHyphenationFactorAttributeKey,
                               RETabStopsAttributeKey,
                               REDefaultTabIntervalAttributeKey];
                  });
    return (NSArray *)keys;
}

NSArray * remoteElementAttributeNames()
{
    static NSArray const * names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      names = @[NSFontAttributeName,
                               NSParagraphStyleAttributeName,
                               NSForegroundColorAttributeName,
                               NSBackgroundColorAttributeName,
                               NSLigatureAttributeName,
                               NSKernAttributeName,
                               NSStrikethroughStyleAttributeName,
                               NSUnderlineStyleAttributeName,
                               NSStrokeColorAttributeName,
                               NSStrokeWidthAttributeName,
                               NSShadowAttributeName,
                               NSTextEffectAttributeName,
                               NSBaselineOffsetAttributeName,
                               NSUnderlineColorAttributeName,
                               NSStrikethroughColorAttributeName,
                               NSObliquenessAttributeName,
                               NSExpansionAttributeName,
                               NullObject];
                  });
    return (NSArray *)names;
}

NSArray * remoteElementParagraphAttributeNames()
{
    static NSArray const * names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      names = @[RELineSpacingAttributeName,
                               REParagraphSpacingAttributeName,
                               RETextAlignmentAttributeName,
                               REFirstLineHeadIndentAttributeName,
                               REHeadIndentAttributeName,
                               RETailIndentAttributeName,
                               RELineBreakModeAttributeName,
                               REMinimumLineHeightAttributeName,
                               REMaximumLineHeightAttributeName,
                               RELineHeightMultipleAttributeName,
                               REParagraphSpacingBeforeAttributeName,
                               REHyphenationFactorAttributeName,
                               RETabStopsAttributeName,
                               REDefaultTabIntervalAttributeName];
                  });
    return (NSArray *)names;
}

NSString * remoteElementAttributeNameForKey(NSString * key)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = [NSDictionary dictionaryWithObjects:remoteElementAttributeNames()
                                                          forKeys:remoteElementAttributeKeys()];
                  });
    return index[key];
}

NSString * remoteElementParagraphAttributeNameForKey(NSString * key)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = [NSDictionary
                               dictionaryWithObjects:remoteElementParagraphAttributeNames()
                                             forKeys:remoteElementParagraphAttributeKeys()];
                  });
    return index[key];
}

NSString * remoteElementAttributeKeyForName(NSString * name)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = [NSDictionary dictionaryWithObjects:remoteElementAttributeKeys()
                                                          forKeys:remoteElementAttributeNames()];
                  });
    return index[name];
}

NSString * remoteElementParagraphAttributeKeyForName(NSString * name)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = [NSDictionary
                               dictionaryWithObjects:remoteElementParagraphAttributeKeys()
                                             forKeys:remoteElementParagraphAttributeNames()];
                  });
    return index[name];
}


NSSet * remoteElementJSONAttributeKeys()
{
    static NSSet const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = [[[remoteElementAttributeKeys()
                                arrayByMappingToBlock:^id(id obj, NSUInteger idx)
                                {
                                    return titleSetAttributeJSONKeyForKey(obj);
                                }] arrayByAddingObject:REFontAwesomeIconJSONKey] set];
                  });
    return (NSSet *)keys;
}

NSSet * remoteElementJSONParagraphAttributeKeys()
{
    static NSSet const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = [[[remoteElementParagraphAttributeKeys()
                                arrayByMappingToBlock:^id(id obj, NSUInteger idx)
                                {
                                    return titleSetAttributeJSONKeyForKey(obj);
                                }] arrayByAddingObject:REFontAwesomeIconJSONKey] set];
                  });
    return (NSSet *)keys;
}

NSSet * remoteElementJSONUnderlineStyleKeys()
{
    static NSSet const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = [@[REUnderlineStyleNoneJSONKey,
                                REUnderlineStyleSingleJSONKey,
                                REUnderlineStyleThickJSONKey,
                                REUnderlineStyleDoubleJSONKey,
                                REUnderlinePatternSolidJSONKey,
                                REUnderlinePatternDotJSONKey,
                                REUnderlinePatternDashJSONKey,
                                REUnderlinePatternDashDotJSONKey,
                                REUnderlinePatternDashDotDotJSONKey,
                                REUnderlineByWordJSONKey] set];
                  });
    return (NSSet *)keys;
}

NSSet * remoteElementJSONLineBreakModeKeys()
{
    static NSSet const * keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      keys = [@[RELineBreakByWordWrappingJSONKey,
                                RELineBreakByCharWrappingJSONKey,
                                RELineBreakByClippingJSONKey,
                                RELineBreakByTruncatingHeadJSONKey,
                                RELineBreakByTruncatingTailJSONKey,
                                RELineBreakByTruncatingMiddleJSONKey] set];
                  });
    return (NSSet *)keys;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Keys
////////////////////////////////////////////////////////////////////////////////


MSKEY_DEFINITION(REFontAttribute);
MSKEY_DEFINITION(REParagraphStyleAttribute);
MSKEY_DEFINITION(REForegroundColorAttribute);
MSKEY_DEFINITION(REBackgroundColorAttribute);
MSKEY_DEFINITION(RELigatureAttribute);
MSKEY_DEFINITION(REKernAttribute);
MSKEY_DEFINITION(REStrikethroughStyleAttribute);
MSKEY_DEFINITION(REUnderlineStyleAttribute);
MSKEY_DEFINITION(REStrokeColorAttribute);
MSKEY_DEFINITION(REStrokeWidthAttribute);
MSKEY_DEFINITION(REShadowAttribute);
MSKEY_DEFINITION(RETextEffectAttribute);
MSKEY_DEFINITION(REBaselineOffsetAttribute);
MSKEY_DEFINITION(REUnderlineColorAttribute);
MSKEY_DEFINITION(REStrikethroughColorAttribute);
MSKEY_DEFINITION(REObliquenessAttribute);
MSKEY_DEFINITION(REExpansionAttribute);
MSKEY_DEFINITION(RETitleTextAttribute);

MSKEY_DEFINITION(RELineSpacingAttribute);
MSKEY_DEFINITION(REParagraphSpacingAttribute);
MSKEY_DEFINITION(RETextAlignmentAttribute);
MSKEY_DEFINITION(REFirstLineHeadIndentAttribute);
MSKEY_DEFINITION(REHeadIndentAttribute);
MSKEY_DEFINITION(RETailIndentAttribute);
MSKEY_DEFINITION(RELineBreakModeAttribute);
MSKEY_DEFINITION(REMinimumLineHeightAttribute);
MSKEY_DEFINITION(REMaximumLineHeightAttribute);
MSKEY_DEFINITION(RELineHeightMultipleAttribute);
MSKEY_DEFINITION(REParagraphSpacingBeforeAttribute);
MSKEY_DEFINITION(REHyphenationFactorAttribute);
MSKEY_DEFINITION(RETabStopsAttribute);
MSKEY_DEFINITION(REDefaultTabIntervalAttribute);

MSSTRING_CONST   RELineSpacingAttributeName            = @"lineSpacing";
MSSTRING_CONST   REParagraphSpacingAttributeName       = @"paragraphSpacing";
MSSTRING_CONST   RETextAlignmentAttributeName          = @"alignment";
MSSTRING_CONST   REFirstLineHeadIndentAttributeName    = @"firstLineHeadIndent";
MSSTRING_CONST   REHeadIndentAttributeName             = @"headIndent";
MSSTRING_CONST   RETailIndentAttributeName             = @"tailIndent";
MSSTRING_CONST   RELineBreakModeAttributeName          = @"lineBreakMode";
MSSTRING_CONST   REMinimumLineHeightAttributeName      = @"minimumLineHeight";
MSSTRING_CONST   REMaximumLineHeightAttributeName      = @"maximumLineHeight";
MSSTRING_CONST   RELineHeightMultipleAttributeName     = @"lineHeightMultiple";
MSSTRING_CONST   REParagraphSpacingBeforeAttributeName = @"paragraphSpacingBefore";
MSSTRING_CONST   REHyphenationFactorAttributeName      = @"hyphenationFactor";
MSSTRING_CONST   RETabStopsAttributeName               = @"tabStops";
MSSTRING_CONST   REDefaultTabIntervalAttributeName     = @"defaultTabInterval";


