//
//  REView+Debugging.m
//  Remote
//
//  Created by Jason Cardwell on 4/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

@implementation REView (Debugging)

- (NSString *)shortDescription { return self.displayName; }

- (NSString *)framesDescription
{
    NSArray * frames = [[@[self] arrayByAddingObjectsFromArray : self.subelementViews]
                        arrayByMappingToBlock:^id (REView * obj, NSUInteger idx)
                        {
                            NSString * nameString = [obj.displayName camelCaseString];

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
             [$(@"%@", self.displayName) singleBarMessageBox],
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
                   ?[((REView*)view).displayName camelCaseString]
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

