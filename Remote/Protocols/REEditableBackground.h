//
//  REEditableBackground.h
//  Remote
//
//  Created by Jason Cardwell on 3/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class   BOBackgroundImage;

@protocol REEditableBackground <NSObject>

@property (nonatomic, strong) UIColor * backgroundColor;
@property (nonatomic, strong) BOBackgroundImage * backgroundImage;

@end
