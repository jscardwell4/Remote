//
//  NSLayoutConstraint+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 9/30/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSKitMacros.h"
#import "NSArray+MSKitAdditions.h"
#import "NSString+MSKitAdditions.h"
#import "NSLayoutConstraint+MSKitAdditions.h"
#import "NSRegularExpression+MSKitAdditions.h"
#import <objc/runtime.h>
#import "UIView+MSKitAdditions.h"


// keys used in dictionary entries for extended visual format syntax
MSSTRING_CONST   MSExtendedVisualFormatNametagName          = @"MSExtendedVisualFormatNametagName";
MSSTRING_CONST   MSExtendedVisualFormatItem1Name            = @"MSExtendedVisualFormatItem1Name";
MSSTRING_CONST   MSExtendedVisualFormatAttribute1Name       = @"MSExtendedVisualFormatAttribute1Name";
MSSTRING_CONST   MSExtendedVisualFormatRelationName         = @"MSExtendedVisualFormatRelationName";
MSSTRING_CONST   MSExtendedVisualFormatItem2Name            = @"MSExtendedVisualFormatItem2Name";
MSSTRING_CONST   MSExtendedVisualFormatAttribute2Name       = @"MSExtendedVisualFormatAttribute2Name";
MSSTRING_CONST   MSExtendedVisualFormatMultiplierName       = @"MSExtendedVisualFormatMultiplierName";
MSSTRING_CONST   MSExtendedVisualFormatConstantName         = @"MSExtendedVisualFormatConstantName";
MSSTRING_CONST   MSExtendedVisualFormatPriorityName         = @"MSExtendedVisualFormatPriorityName";
MSSTRING_CONST   MSExtendedVisualFormatConstantOperatorName = @"MSExtendedVisualFormatConstantOperatorName";

@implementation NSLayoutConstraint (MSKitAdditions)

+ (NSLayoutAttribute)attributeForPseudoName:(NSString *) pseudoName {

	static const NSDictionary * pseudoAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pseudoAttributes = @{
            @"nil" 		: @(NSLayoutAttributeNotAnAttribute),
            @"left"    	: @(NSLayoutAttributeLeft),
            @"right" 	: @(NSLayoutAttributeRight),
            @"top" 		: @(NSLayoutAttributeTop),
            @"bottom" 	: @(NSLayoutAttributeBottom),
            @"leading" 	: @(NSLayoutAttributeLeading),
            @"trailing" : @(NSLayoutAttributeTrailing),
            @"width" 	: @(NSLayoutAttributeWidth),
            @"height" 	: @(NSLayoutAttributeHeight),
            @"centerX" 	: @(NSLayoutAttributeCenterX),
            @"centerY" 	: @(NSLayoutAttributeCenterY),
            @"baseline" : @(NSLayoutAttributeBaseline)
		};
    });

    if (![[pseudoAttributes allKeys] containsObject:pseudoName]) pseudoName = @"nil";

    return [pseudoAttributes[pseudoName] integerValue];
}

+ (NSString *)pseudoNameForAttribute:(NSLayoutAttribute) attribute {
	static const NSDictionary * pseudoNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pseudoNames = @{
            @(NSLayoutAttributeNotAnAttribute) 	: @"nil",
            @(NSLayoutAttributeLeft) 			: @"left",
            @(NSLayoutAttributeRight) 			: @"right",
            @(NSLayoutAttributeTop) 			: @"top",
            @(NSLayoutAttributeBottom) 			: @"bottom",
            @(NSLayoutAttributeLeading) 		: @"leading",
            @(NSLayoutAttributeTrailing) 		: @"trailing",
            @(NSLayoutAttributeWidth) 			: @"width",
            @(NSLayoutAttributeHeight) 			: @"height",
            @(NSLayoutAttributeCenterX) 		: @"centerX",
            @(NSLayoutAttributeCenterY) 		: @"centerY",
            @(NSLayoutAttributeBaseline) 		: @"baseline"
		};
    });

    return pseudoNames[@(attribute)];
}

+ (NSLayoutRelation)relationForPseudoName:(NSString *) pseudoName {

	static const NSDictionary * pseudoRelations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pseudoRelations = @{
            @"=" : @(NSLayoutRelationEqual),
            @"≥" : @(NSLayoutRelationGreaterThanOrEqual),
            @"≤" : @(NSLayoutRelationLessThanOrEqual)
		};
    });

    if (![[pseudoRelations allKeys] containsObject:pseudoName])
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"%@ is not a valid pseudo name",pseudoName]
                                     userInfo:nil];
    return [pseudoRelations[pseudoName] integerValue];
}

+ (NSString *)pseudoNameForRelation:(NSLayoutRelation)relation {
	static const NSDictionary * pseudoNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pseudoNames = @{
            @(NSLayoutRelationEqual) 				: @"=",
            @(NSLayoutRelationGreaterThanOrEqual) 	: @"≥",
            @(NSLayoutRelationLessThanOrEqual) 		: @"≤"
		};
    });

    return pseudoNames[@(relation)];
}


/**

 Parses a string with 'extended' visual format into single statements from which constraints can
 be generated. Statements are separated by newline characters and
 passed to `constraintsFromFormat:options:metrics:views:` for constraint creation.

 */
+ (NSArray *)constraintsByParsingString:(NSString *)string
                                options:(NSLayoutFormatOptions)options
                                metrics:(NSDictionary *)metrics
                                  views:(NSDictionary *)views
{
    if (StringIsEmpty(string))
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"string cannot be empty or nil" userInfo:nil];

	NSMutableArray * constraintObjects = [@[] mutableCopy];

    [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (line.length > 0)
            [constraintObjects addObjectsFromArray:[self constraintsFromFormat:line
                                                                       options:options
                                                                       metrics:metrics
                                                                         views:views]
         ];
    }];

//	for (NSString * format in [self componentsBySeparatingConstraintsInString:string])
//            [constraintObjects addObjectsFromArray:[self constraintsFromFormat:format options:options metrics:metrics views:views]];

	return constraintObjects;

}

/**
 Convenience method that calls `constraintsByParsingString:options:metrics:views:` with no options
 */
+ (NSArray *)constraintsByParsingString:(NSString *)string
                                metrics:(NSDictionary *)metrics
                                  views:(NSDictionary *)views
{
	return [self constraintsByParsingString:string options:0 metrics:metrics views:views];
}

/**
 Convenience method that calls `constraintsByParsingString:options:metrics:views:` with no options or metrics
 */
+ (NSArray *)constraintsByParsingString:(NSString *)string views:(NSDictionary *)views {
	return [self constraintsByParsingString:string options:0 metrics:nil views:views];
}

+ (NSDictionary *)dictionaryFromExtendedVisualFormat:(NSString *)format {
	// regex for detecting extended format
	static const NSRegularExpression * regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         match cases:
         item1.attribute1 = item2.attribute2 * multiplier + constant @priority
         item1.attribute1 = item2.attribute2 * multiplier + constant
         item1.attribute1 = item2.attribute2 + constant @priority
         item1.attribute1 = item2.attribute2 + constant
         item1.attribute1 = item2.attribute2 * multiplier @priority
         item1.attribute1 = item2.attribute2 * multiplier
         item1.attribute1 = item2.attribute2 @priority
         item1.attribute1 = item2.attribute2
         item1.attribute1 = constant @priority
         item1.attribute1 = constant
         
         optional tag name at beginning of line: 'tag name'
         */
        NSError * error = nil;
		NSString * name = @"[a-zA-Z_][-_a-zA-Z0-9]*";
		NSString * attribute = @"[a-z]+[A-Z]?";
		NSString * priority = @"[0-9]{1,4}";
		NSString * metric = [NSString stringWithFormat:@"(?:%@)|(?:[-0-9]+\\.?[0-9]*)", name];
		NSString * regexString = [NSString stringWithFormat:
								  @"(?:'([^']+)'[ ]+)?"         // nametag
                  "(%@)\\.(%@)" 				// first item and attribute
								  "[ ]+([=≤≥]+)" 				// relation
								  "(?:[ ]+(%@)\\.(%@))?" 		// second item and attribute if present
								  "(?:[ ]+[x*][ ]+(%@))?" 		// multiplier if present
								  "(?:[ ]+([+-])?[ ]*(%@))?"	// constant if present
								  "(?:[ ]+@(%@))?", 			// priority if present
								  name, attribute, name, attribute, metric, metric, priority];
		regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
		assert(!error);
    });

    NSDictionary * dictionary =
        [regex
         captureGroupsFromFirstMatchInString:format
                                     options:0
                                       range:NSMakeRange(0, format.length)
                                        keys:@[MSExtendedVisualFormatNametagName,
                                               MSExtendedVisualFormatItem1Name,
                                               MSExtendedVisualFormatAttribute1Name,
                                               MSExtendedVisualFormatRelationName,
                                               MSExtendedVisualFormatItem2Name,
                                               MSExtendedVisualFormatAttribute2Name,
                                               MSExtendedVisualFormatMultiplierName,
                                               MSExtendedVisualFormatConstantOperatorName,
                                               MSExtendedVisualFormatConstantName,
                                               MSExtendedVisualFormatPriorityName]];
    return dictionary;
}

+ (NSArray *)constraintDictionariesByParsingString:(NSString *)string
{
	NSMutableArray * dictionaries = [@[] mutableCopy];

    [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
     {
         if (line.length > 0)
         {
             NSDictionary * dictionary = [self dictionaryFromExtendedVisualFormat:line];
             if (dictionary) [dictionaries addObject:dictionary];
         }
     }];
    return dictionaries;
}

/**
 Generates constraints represented by a single extended visual format statement. Standard visual 
 formats are used as is, pseudo code 'extended' visual formats are parsed to call non-visual format
 method for creation of the constraint.
 
 Syntax: ('=' could also be '≥' or '≤')
     item1.attribute1 = item2.attribute2 * multiplier + constant @priority
     item1.attribute1 = item2.attribute2 * multiplier + constant
     item1.attribute1 = item2.attribute2 + constant @priority
     item1.attribute1 = item2.attribute2 + constant
     item1.attribute1 = item2.attribute2 * multiplier @priority
     item1.attribute1 = item2.attribute2 * multiplier
     item1.attribute1 = item2.attribute2 @priority
     item1.attribute1 = item2.attribute2
     item1.attribute1 = constant @priority
     item1.attribute1 = constant

 	 NSLayoutAttributeLeft 		⇒	left
	 NSLayoutAttributeRight		⇒	right
	 NSLayoutAttributeTop 		⇒	top
	 NSLayoutAttributeBottom 	⇒	bottom
	 NSLayoutAttributeLeading 	⇒	leading
	 NSLayoutAttributeTrailing 	⇒	trailing
	 NSLayoutAttributeWidth 	⇒	width
	 NSLayoutAttributeHeight 	⇒	height
	 NSLayoutAttributeCenterX 	⇒	centerX
	 NSLayoutAttributeCenterY 	⇒	centerY
	 NSLayoutAttributeBaseline 	⇒	baseline

 */
+ (NSArray *)constraintsFromFormat:(NSString *)format
                           options:(NSLayoutFormatOptions)options
                           metrics:(NSDictionary *)metrics
                             views:(NSDictionary *)views
{

    NSDictionary * formatDictionary = [self dictionaryFromExtendedVisualFormat:format];
    if (formatDictionary) {
        formatDictionary = [self replaceObjectPlaceHolders:formatDictionary
                                                   metrics:metrics
                                                     views:views];
        return @[[self constraintFromDictionary:formatDictionary]];
    }

    else
        return [self constraintsWithVisualFormat:format
                                         options:options
                                         metrics:metrics
                                           views:views];
}

/**
 Takes a dictionary with attribute, view, and metric names and replaces the strings with real objects.
 */
+ (NSDictionary *)replaceObjectPlaceHolders:(NSDictionary *)dictionary
                                    metrics:(NSDictionary *)metrics
                                      views:(NSDictionary *)views
{

	if (!dictionary)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"dictionary cannot be nil" userInfo:nil];

	// replace item names with views
	NSMutableDictionary * newDictionary = [@{} mutableCopy];
    __block BOOL isConstantNegative = NO;
    
	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
		 if (obj == [NSNull null])
		 {
			 return;
		 }
         else if (key == MSExtendedVisualFormatNametagName)
         {
             newDictionary[key] = dictionary[key];
         }
		 else if (   key == MSExtendedVisualFormatItem1Name
				  || key == MSExtendedVisualFormatItem2Name)
		 {
             if (!views[(NSString *)obj]) {
                 NSLog(@"obj:%@ not found in views:%@", obj, views);
                 assert(views[(NSString *)obj]);
             }
			 newDictionary[key] = views[(NSString *)obj];
		 }
		 else if (   key == MSExtendedVisualFormatAttribute1Name
				  || key == MSExtendedVisualFormatAttribute2Name)
		 {
			 newDictionary[key] = @([self attributeForPseudoName:(NSString *)obj]);
		 }
         else if (key == MSExtendedVisualFormatConstantOperatorName && [(NSString *)obj characterAtIndex:0] == '-')
         {
             isConstantNegative = YES;
             if (newDictionary[MSExtendedVisualFormatConstantName])
                 newDictionary[MSExtendedVisualFormatConstantName] = @(0 - [newDictionary[MSExtendedVisualFormatConstantName] floatValue]);
         }
		 else if (   key == MSExtendedVisualFormatMultiplierName
				  || key == MSExtendedVisualFormatConstantName
				  || key == MSExtendedVisualFormatPriorityName)
		 {
			 NSRange charRange = [(NSString *)obj rangeOfCharacterFromSet:
								  [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]
								   invertedSet]];
             CGFloat val;
			 if (charRange.location == NSNotFound) {
                 val = [(NSString *)obj floatValue];
             } else {
                 assert(metrics[obj]);
                 val = [metrics[obj] floatValue];
             }

             if (key == MSExtendedVisualFormatConstantName && isConstantNegative) {
                 val = 0 - val;
             }

             newDictionary[key] = @(val);
		 }
		 else if (key == MSExtendedVisualFormatRelationName)
		 {
             // ≤ = 8804
             // ≥ = 8805
             // = = 61
             switch ([(NSString *)obj characterAtIndex:0]) {
                 case 61:
                     newDictionary[key] = @(NSLayoutRelationEqual);
                     break;
                 case 8804:
                     newDictionary[key] = @(NSLayoutRelationLessThanOrEqual);
                     break;
                 case 8805:
                     newDictionary[key] = @(NSLayoutRelationGreaterThanOrEqual);
                     break;
                 default:
                     assert(NO);
                     break;
             }
		 }
	  }
	 ];

    return newDictionary;
}

/**
 Creates a constraint using the objects in the specified dictionary.
 */
+ (NSLayoutConstraint *)constraintFromDictionary:(NSDictionary *)dictionary {
	if (!dictionary) @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                    reason:@"dictionary cannot be nil" userInfo:nil];

    NSString * nametag              = dictionary[MSExtendedVisualFormatNametagName];
    UIView * item1 					= dictionary[MSExtendedVisualFormatItem1Name];
    NSLayoutAttribute attribute1	= [dictionary[MSExtendedVisualFormatAttribute1Name] integerValue];
    NSLayoutRelation relatedBy 	= [dictionary[MSExtendedVisualFormatRelationName] integerValue];
    UIView * item2 					= dictionary[MSExtendedVisualFormatItem2Name];
    NSLayoutAttribute attribute2 	= (dictionary[MSExtendedVisualFormatAttribute2Name]
                                       ? [dictionary[MSExtendedVisualFormatAttribute2Name] integerValue]
                                       : NSLayoutAttributeNotAnAttribute);
    CGFloat multiplier 				= (dictionary[MSExtendedVisualFormatMultiplierName]
                                       ? [dictionary[MSExtendedVisualFormatMultiplierName] floatValue]
                                       : 1.0f);
    CGFloat constant 				= (dictionary[MSExtendedVisualFormatConstantName]
                                       ? [dictionary[MSExtendedVisualFormatConstantName] floatValue]
                                       : 0.0f);
    UILayoutPriority priority 		= (dictionary[MSExtendedVisualFormatPriorityName]
                                       ? [dictionary[MSExtendedVisualFormatPriorityName] floatValue]
                                       : UILayoutPriorityRequired);

	NSLayoutConstraint * constraint =  [self constraintWithItem:item1
                                                      attribute:attribute1
                                                      relatedBy:relatedBy
                                                         toItem:item2
                                                      attribute:attribute2
                                                     multiplier:multiplier
                                                       constant:constant];

	constraint.priority = priority;
    constraint.nametag = nametag;
	return constraint;
}

/**
 Creates a dictionary containing the objects from the specified constraint
 */
+ (NSDictionary *)dictionaryFromConstraint:(NSLayoutConstraint *)constraint {
	if (!constraint) @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                    reason:@"constraint cannot be nil" userInfo:nil];

    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:8];
    dictionary[MSExtendedVisualFormatItem1Name] = constraint.firstItem;
    dictionary[MSExtendedVisualFormatAttribute1Name] = @(constraint.firstAttribute);
    dictionary[MSExtendedVisualFormatRelationName] = @(constraint.relation);
    dictionary[MSExtendedVisualFormatItem2Name] = NilSafeValue(constraint.secondItem);
    dictionary[MSExtendedVisualFormatAttribute2Name] = @(constraint.secondAttribute);
    dictionary[MSExtendedVisualFormatMultiplierName] = @(constraint.multiplier);
    dictionary[MSExtendedVisualFormatConstantName] = @(constraint.constant);
    dictionary[MSExtendedVisualFormatPriorityName] = @(constraint.priority);
    dictionary[MSExtendedVisualFormatNametagName] = NilSafeValue(constraint.nametag);

	return dictionary;
}

- (NSString *)stringRepresentationWithSubstitutions:(NSDictionary *)substitutions {
    NSString * firstItem = (substitutions[MSExtendedVisualFormatItem1Name]
                            ? substitutions[MSExtendedVisualFormatItem1Name]
                            : @"firstItem");
    NSString * firstAttribute = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    NSString * relation = (self.relation == NSLayoutRelationEqual
                           ? @"="
                           : (self.relation == NSLayoutRelationGreaterThanOrEqual
                              ? @"≥"
                              : @"≤"));
    NSString * secondItem = (self.secondItem
                             ? (substitutions[MSExtendedVisualFormatItem2Name]
                                ? substitutions[MSExtendedVisualFormatItem2Name]
                                : @"secondItem")
                             : nil);
    NSString * secondAttribute = (self.secondAttribute != NSLayoutAttributeNotAnAttribute
                                  ? [NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute]
                                  : nil);
    NSString * multiplier = (self.multiplier == 1.0f
                             ? nil
                             : [[NSString stringWithFormat:@"%f",self.multiplier] stringByStrippingTrailingZeroes]);
    NSString * constant = (self.constant == 0.0f
                             ? nil
                             : [[NSString stringWithFormat:@"%f",self.constant] stringByStrippingTrailingZeroes]);
    NSString * priority = (self.priority == UILayoutPriorityRequired
                           ? nil
                           : [NSString stringWithFormat:@"@%d",(int)self.priority]);

    NSMutableString * stringRep = [NSMutableString stringWithFormat:@"%@.%@ %@ ",
                                   firstItem, firstAttribute, relation];
    if (secondItem && secondAttribute) {
        [stringRep appendFormat:@"%@.%@", secondItem, secondAttribute];
        if (multiplier)
            [stringRep appendFormat:@" * %@", multiplier];
        if (constant) {
            if (self.constant < 0) {
                constant = [constant substringFromIndex:1];
                [stringRep appendString:@" - "];
            } else
                [stringRep appendString:@" + "];
        }
    }
    if (constant)
        [stringRep appendString:constant];

    if (priority) {
        [stringRep appendFormat:@" %@", priority];
    }

    if (self.nametag) {
        [stringRep appendFormat:@" '%@'", self.nametag];
    }
    return stringRep;
}

+ (id)valueForAttribute:(NSLayoutAttribute)attribute item:(UIView *)item {
    assert(item);
    CGRect alignmentRect = [item alignmentRectForFrame:item.frame];
    switch (attribute) {
        case NSLayoutAttributeBaseline:
            if ([item viewForBaselineLayout] != item) {
                UIView * v = [item viewForBaselineLayout];
                alignmentRect = [v alignmentRectForFrame:v.frame];
            }
        case NSLayoutAttributeBottom:
        case NSLayoutAttributeTop:
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
        case NSLayoutAttributeCenterX:
        case NSLayoutAttributeCenterY:
        case NSLayoutAttributeWidth:
        case NSLayoutAttributeHeight:
            return [self valueForAttribute:attribute alignmentRect:alignmentRect];
        case NSLayoutAttributeNotAnAttribute:
        default:
            return nil;
    }
}

+ (id)valueForAttribute:(NSLayoutAttribute)attribute alignmentRect:(CGRect)rect {
    switch (attribute) {
        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:
            return @(CGRectGetMaxY(rect));
        case NSLayoutAttributeTop:
            return @(CGRectGetMinY(rect));
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
            return @(CGRectGetMinX(rect));
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
            return @(CGRectGetMaxX(rect));
        case NSLayoutAttributeCenterX:
            return @(CGRectGetMidX(rect));
        case NSLayoutAttributeCenterY:
            return @(CGRectGetMidY(rect));
        case NSLayoutAttributeWidth:
            return @(rect.size.width);
        case NSLayoutAttributeHeight:
            return @(rect.size.height);
        case NSLayoutAttributeNotAnAttribute:
        default:
            return nil;
    }
}

- (id)firstAttributeValue {
    return [NSLayoutConstraint valueForAttribute:self.firstAttribute item:self.firstItem];
}

- (id)secondAttributeValue {
    return [NSLayoutConstraint valueForAttribute:self.secondAttribute item:self.secondItem];
}

static const char *MSNSLayoutConstraintNametagKey = "MSNSLayoutConstraintNametagKey";
static const char *MSNSLayoutConstraintTagKey = "MSNSLayoutConstraintTagKey";

- (NSUInteger)tag {
    NSNumber * tagObj = objc_getAssociatedObject(self, (void *)MSNSLayoutConstraintTagKey);
    return (tagObj ? tagObj.integerValue : 0);
}

- (void)setTag:(NSUInteger)tag {
    objc_setAssociatedObject(self,
                             (void *)MSNSLayoutConstraintTagKey,
                             @(tag),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)nametag {
    return objc_getAssociatedObject(self, (void *)MSNSLayoutConstraintNametagKey);
}

- (void)setNametag:(NSString *)nametag {
    objc_setAssociatedObject(self,
                             (void *)MSNSLayoutConstraintNametagKey,
                             nametag,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)copyWithMultiplier:(CGFloat)multiplier {
    NSLayoutConstraint * c = [NSLayoutConstraint constraintWithItem:self.firstItem
                                                          attribute:self.firstAttribute
                                                          relatedBy:self.relation
                                                             toItem:self.secondItem
                                                          attribute:self.secondAttribute
                                                         multiplier:multiplier
                                                           constant:self.constant];
    c.priority = self.priority;
    c.shouldBeArchived = self.shouldBeArchived;
    c.nametag = self.nametag;
    c.tag = self.tag;
    return c;
}

- (NSLayoutConstraint *)copyWithZone:(NSZone *)zone {
    return [self copyWithMultiplier:self.multiplier];
}

- (NSString *)prettyDescription
{
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view)
    {
        return (view
                ? (view.nametag ?: $(@"<%@:%p>", ClassString([view class]), view))
                : (NSString *)nil);
    };

    NSString     * firstItem     = itemNameForView(self.firstItem);
    NSString     * secondItem    = itemNameForView(self.secondItem);
    NSDictionary * substitutions = nil;

    if (firstItem && secondItem)
        substitutions = @{MSExtendedVisualFormatItem1Name : firstItem,
                          MSExtendedVisualFormatItem2Name : secondItem};
    else if (firstItem)
        substitutions = @{MSExtendedVisualFormatItem1Name : firstItem};

    return [self stringRepresentationWithSubstitutions:substitutions];

}

@end