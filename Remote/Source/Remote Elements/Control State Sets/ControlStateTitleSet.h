//
// ControlStateTitleSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateTitleSet : ControlStateSet

@property (nonatomic) BOOL suppressNormalStateAttributes;

+ (Class)validClassForAttributeKey:(NSString *)key;
+ (Class)validClassForParagraphAttributeKey:(NSString *)key;
+ (Class)validClassForAttributeName:(NSString *)name;
+ (Class)validClassForParagraphAttributeName:(NSString *)name;

@end

MSEXTERN_KEY(REFontAttribute);               // REFont
MSEXTERN_KEY(REParagraphStyleAttribute);     // NSParagraphStyle
MSEXTERN_KEY(REForegroundColorAttribute);    // UIColor
MSEXTERN_KEY(REBackgroundColorAttribute);    // UIColor
MSEXTERN_KEY(RELigatureAttribute);           // NSNumber
MSEXTERN_KEY(REKernAttribute);               // NSNumber
MSEXTERN_KEY(REStrikethroughStyleAttribute); // NSNumber
MSEXTERN_KEY(REUnderlineStyleAttribute);     // NSNumber
MSEXTERN_KEY(REStrokeColorAttribute);        // UIColor
MSEXTERN_KEY(REStrokeWidthAttribute);        // NSNumber
MSEXTERN_KEY(REShadowAttribute);             // NSShadow
MSEXTERN_KEY(RETextEffectAttribute);         // NSString
MSEXTERN_KEY(REBaselineOffsetAttribute);     // UIColor
MSEXTERN_KEY(REUnderlineColorAttribute);     // UIColor
MSEXTERN_KEY(REStrikethroughColorAttribute); // UIColor
MSEXTERN_KEY(REObliquenessAttribute);        // NSNumber
MSEXTERN_KEY(REExpansionAttribute);          // NSNumber
MSEXTERN_KEY(RETitleTextAttribute);          // NSString

MSEXTERN_KEY(RELineSpacingAttribute);            // CGFloat
MSEXTERN_KEY(REParagraphSpacingAttribute);       // CGFloat
MSEXTERN_KEY(RETextAlignmentAttribute);          // NSTextAlignment
MSEXTERN_KEY(REFirstLineHeadIndentAttribute);    // CGFloat
MSEXTERN_KEY(REHeadIndentAttribute);             // CGFloat
MSEXTERN_KEY(RETailIndentAttribute);             // NSLineBreakMode
MSEXTERN_KEY(RELineBreakModeAttribute);          // CGFloat
MSEXTERN_KEY(REMinimumLineHeightAttribute);      // CGFloat
MSEXTERN_KEY(REMaximumLineHeightAttribute);      // CGFloat
MSEXTERN_KEY(RELineHeightMultipleAttribute);     // CGFloat
MSEXTERN_KEY(REParagraphSpacingBeforeAttribute); // CGFloat
MSEXTERN_KEY(REHyphenationFactorAttribute);      // float
MSEXTERN_KEY(RETabStopsAttribute);               // NSArray
MSEXTERN_KEY(REDefaultTabIntervalAttribute);     // CGFloat

MSEXTERN_NAME(RELineSpacingAttribute);           
MSEXTERN_NAME(REParagraphSpacingAttribute);      
MSEXTERN_NAME(RETextAlignmentAttribute);         
MSEXTERN_NAME(REFirstLineHeadIndentAttribute);   
MSEXTERN_NAME(REHeadIndentAttribute);            
MSEXTERN_NAME(RETailIndentAttribute);            
MSEXTERN_NAME(RELineBreakModeAttribute);         
MSEXTERN_NAME(REMinimumLineHeightAttribute);     
MSEXTERN_NAME(REMaximumLineHeightAttribute);     
MSEXTERN_NAME(RELineHeightMultipleAttribute);    
MSEXTERN_NAME(REParagraphSpacingBeforeAttribute);
MSEXTERN_NAME(REHyphenationFactorAttribute);     
MSEXTERN_NAME(RETabStopsAttribute);              
MSEXTERN_NAME(REDefaultTabIntervalAttribute);    
