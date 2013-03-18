//
// REViewConstraintFunctions.h
// Remote
//
// Created by Jason Cardwell on 12/22/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#define ChildConstraintNametag(kind)     [RemoteElementChildConstraintNametag stringByAppendingFormat : @"-%@", kind]
#define IntrinsicConstraintNametag(kind) [RemoteElementIntrinsicConstraintNametag stringByAppendingFormat : @"-%@", kind]
#define ChildCenterXConstraintNametag    ChildConstraintNametag(RemoteElementConstraintAlignmentTypeCenterX)
#define ChildCenterYConstraintNametag    ChildConstraintNametag(RemoteElementConstraintAlignmentTypeCenterY)
#define ChildTopConstraintNametag        ChildConstraintNametag(RemoteElementConstraintAlignmentTypeTop)
#define ChildLeftConstraintNametag       ChildConstraintNametag(RemoteElementConstraintAlignmentTypeLeft)
#define ChildRightConstraintNametag      ChildConstraintNametag(RemoteElementConstraintAlignmentTypeRight)
#define ChildBottomConstraintNametag     ChildConstraintNametag(RemoteElementConstraintAlignmentTypeBottom)
#define ChildBaselineConstraintNametag   ChildConstraintNametag(RemoteElementConstraintAlignmentTypeBaseline)
#define ChildWidthConstraintNametag      ChildConstraintNametag(RemoteElementConstraintSizeTypeWidth)
#define ChildHeightConstraintNametag     ChildConstraintNametag(RemoteElementConstraintSizeTypeHeight)
#define IntrinsicWidthConstraintNametag  IntrinsicConstraintNametag(RemoteElementConstraintSizeTypeWidth)
#define IntrinsicHeightConstraintNametag IntrinsicConstraintNametag(RemoteElementConstraintSizeTypeHeight)

#define CenterXConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {    \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeCenterX && (*stop = YES)); \
    }                                                                                                        \
    ];
#define CenterYConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {    \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeCenterY && (*stop = YES)); \
    }                                                                                                        \
    ];
#define TopConstraint(owner, target)                                                                      \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) { \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeTop && (*stop = YES));  \
    }                                                                                                     \
    ];
#define BottomConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {   \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeBottom && (*stop = YES)); \
    }                                                                                                       \
    ];
#define LeftConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) { \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeLeft && (*stop = YES)); \
    }                                                                                                     \
    ];
#define RightConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {  \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeRight && (*stop = YES)); \
    }                                                                                                      \
    ];
#define BaselineConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {     \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeBaseline && (*stop = YES)); \
    }                                                                                                         \
    ];
#define WidthConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {  \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeWidth && (*stop = YES)); \
    }                                                                                                      \
    ];
#define HeightConstraint(owner, target)                                                                     \
    [owner.constraints objectPassingTest :^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) {   \
        return (obj.firstItem == target && obj.firstAttribute == NSLayoutAttributeHeight && (*stop = YES)); \
    }                                                                                                       \
    ];
#define TaggedConstraint(owner, target, nametag)                                  \
    [[owner constraintsWithNametag:nametag]                                       \
objectPassingTest:^BOOL (NSLayoutConstraint * obj, NSUInteger idx, BOOL * stop) { \
        return (obj.firstItem == target && (*stop = YES));                        \
    }                                                                             \
    ];
#import "REView.h"

static inline BOOL isChildParentConstraint(NSLayoutConstraint * constraint) {
    if (  !(  [constraint.firstItem isKindOfClass:[REView class]]
           && [constraint.secondItem isKindOfClass:[REView class]])
       || !(  ((REView *)constraint.firstItem).parentElementView == (REView *)constraint.secondItem
           || ((REView *)constraint.secondItem).parentElementView == (REView *)constraint.firstItem)) return NO;
    else return YES;
}

static inline BOOL isChildChildConstraint(NSLayoutConstraint * constraint) {
    if (  !(  [constraint.firstItem isKindOfClass:[REView class]]
           && [constraint.secondItem isKindOfClass:[REView class]])
       || !(((REView *)constraint.firstItem).parentElementView == ((REView *)constraint.secondItem).parentElementView)) return NO;
    else return YES;
}

