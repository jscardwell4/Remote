//
//  REView+Debugging.m
//  Remote
//
//  Created by Jason Cardwell on 4/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

@implementation REView (Debugging)

- (MSDictionary *)appearanceDescriptionDictionary
{
    RemoteElement * element = [self.model faultedObject];

    // backgroundColor, backgroundImage, backgroundImageAlpha, shape, style
    NSString * backgroundString    = namedModelObjectDescription(element.backgroundImage);
    NSString * bgAlphaString       = [@(element.backgroundImageAlpha) stringValue];
    NSString * bgColorString       = NSStringFromUIColor(element.backgroundColor);
    NSString * shapeString         = NSStringFromREShape(element.shape);
    NSString * styleString         = NSStringFromREStyle(element.style);
    NSString * proportionString    = BOOLString(element.proportionLock);
    NSString * themeString         = namedModelObjectDescription(element.theme);


    MSMutableDictionary * appearanceDictionary = [MSMutableDictionary dictionary];
    appearanceDictionary[@"theme"]                 = (themeString ?: @"nil");
    appearanceDictionary[@"shape"]                 = (shapeString ?: @"nil");
    appearanceDictionary[@"style"]                 = (styleString ?: @"nil");
    appearanceDictionary[@"backgroundImage"]       = (backgroundString ?: @"nil");
    appearanceDictionary[@"backgroundImageAlpha"]  = (bgAlphaString ?: @"nil");
    appearanceDictionary[@"backgroundColor"]       = (bgColorString ?: @"nil");
    appearanceDictionary[@"proportionLock"]        = (proportionString ?: @"nil");

    return appearanceDictionary;
}

- (NSString *)appearanceDescription
{
    MSDictionary * dd = [self appearanceDescriptionDictionary];

    NSMutableString * description = [@"" mutableCopy];
    [dd enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, NSString * value, BOOL *stop)
     {
         [description appendFormat:@"%@ %@\n",
          [[key stringByAppendingString:@":"] stringByRightPaddingToLength:22 withCharacter:' '],
          [value stringByShiftingRight:23 shiftFirstLine:NO]];
     }];

    return [description stringByShiftingRight:4];
}

- (NSString *)shortDescription { return self.name; }

- (NSString *)framesDescription
{
    NSArray * frames = [[@[self] arrayByAddingObjectsFromArray : self.subelementViews]
                        arrayByMappingToBlock:^id (REView * obj, NSUInteger idx)
                        {
                            NSString * nameString = [obj.name camelCaseString];

                            NSString * originString = $(@"(%6s,%6s)",
                                                        UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.x))),
                                                        UTF8(StripTrailingZeros($(@"%f", obj.frame.origin.y))));

                            NSString * sizeString = $(@"%6s x %6s",
                                                      UTF8(StripTrailingZeros($(@"%f", obj.frame.size.width))),
                                                      UTF8(StripTrailingZeros($(@"%f", obj.frame.size.height))));

                            return $(@"%@\t%@\t%@", nameString, originString, sizeString);
                        }];

    return [[@"Element\t    Origin       \t      Size        \n" stringByAppendingString :
             [frames componentsJoinedByString:@"\n"]] singleBarHeaderBox:20];
}

- (NSString *)constraintsDescription
{
    return $(@"%@\n%@\n\n%@",
             [$(@"%@", self.name) singleBarMessageBox],
             [self.model constraintsDescription],
             [self viewConstraintsDescription]);
}

- (NSString *)modelConstraintsDescription
{
    return [self.model constraintsDescription];
}

- (NSString *)viewConstraintsDescription
{
    NSMutableString * description        = [@"" mutableCopy];
    NSArray         * modeledConstraints = [self constraintsOfType:[RELayoutConstraint class]];

    if (modeledConstraints.count)
        [description appendFormat:@"\nview constraints (modeled):\n\t%@",
         [[modeledConstraints valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];

    NSArray * unmodeledConstraints = [self constraintsOfType:[NSLayoutConstraint class]];

    if (unmodeledConstraints.count)
        [description appendFormat:@"\n\nview constraints (unmodeled):\n\t%@",
         [[unmodeledConstraints arrayByMappingToBlock:
           ^id (id obj, NSUInteger idx){
               return prettyRemoteElementConstraint(obj);
           }] componentsJoinedByString:@"\n\t"]];

    if (!modeledConstraints.count && !unmodeledConstraints.count)
        [description appendString:@"no constraints"];

    return description;
}

@end

NSString *prettyRemoteElementConstraint(NSLayoutConstraint * constraint)
{
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view){
        return (view
                ? ([view isKindOfClass:[REView class]]
                   ?[((REView*)view).name camelCaseString]
                   : (view.accessibilityIdentifier
                       ? : $(@"<%@:%p>", ClassString([view class]), view)
                      )
                   )
                : (NSString *)nil);
    };

    NSString     * firstItem     = itemNameForView(constraint.firstItem);
    NSString     * secondItem    = itemNameForView(constraint.secondItem);
    NSDictionary * substitutions = nil;

    if (firstItem && secondItem)
        substitutions = @{
                          MSExtendedVisualFormatItem1Name : firstItem,
                          MSExtendedVisualFormatItem2Name : secondItem
                          };
    else if (firstItem)
        substitutions = @{
                          MSExtendedVisualFormatItem1Name : firstItem
                          };

    return [constraint stringRepresentationWithSubstitutions:substitutions];
}

