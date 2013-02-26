//
// DPad.h
// iPhonto
//
// Created by Jason Cardwell on 6/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CommandSet.h"

extern NSString * kDPadUpButtonKey;
extern NSString * kDPadDownButtonKey;
extern NSString * kDPadLeftButtonKey;
extern NSString * kDPadRightButtonKey;
extern NSString * kDPadOkButtonKey;

typedef NS_ENUM (NSInteger, DPadButtonTag) {
    DPadUpButtonTag    = 0,
    DPadDownButtonTag  = 1,
    DPadLeftButtonTag  = 2,
    DPadRightButtonTag = 3,
    DPadOkButtonTag    = 4
};

@interface DPad : CommandSet {
    @private
}
@property (nonatomic, strong) NSURL * up;
@property (nonatomic, strong) NSURL * left;
@property (nonatomic, strong) NSURL * right;
@property (nonatomic, strong) NSURL * ok;
@property (nonatomic, strong) NSURL * down;
@property (nonatomic, strong) NSSet * buttonGroups;

+ (DPad *)newDPadInContext:(NSManagedObjectContext *)context;

@end
