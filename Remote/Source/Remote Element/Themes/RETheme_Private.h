//
//  RETheme_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RETheme.h"
#import "REControlStateSet.h"

@interface RETheme () {
    @protected
    BOOL _shouldInitializeColors;
}

@property (nonatomic, strong) REControlStateColorSet * backgroundColors;
@property (nonatomic, strong) REControlStateColorSet * iconColors;
@property (nonatomic, strong) REControlStateTitleSet * titleStyles;
@property (nonatomic, strong) NSNumber               * theme;
@property (nonatomic, copy)   NSString               * name;

@end
