//
// RELabelView.h
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface RELabelView : UILabel

@property (nonatomic, assign) CGFloat        baseWidth;
@property (nonatomic, assign) CGFloat        fontScale;
@property (nonatomic, assign) BOOL           preserveLines;
@property (nonatomic, readonly) NSUInteger   lineBreaks;

@end


@interface REButtonLabelView : RELabelView

@end