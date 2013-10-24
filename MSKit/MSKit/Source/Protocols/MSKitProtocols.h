//
//  MSKitProtocols.h
//  Remote
//
//  Created by Jason Cardwell on 3/27/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//


@protocol MSDebugDescription <NSObject>

- (NSString *)debugDescriptionWithVerbosity:(NSUInteger)verbosity 
								   tabDepth:(NSUInteger)tabDepth
									  inset:(NSUInteger)inset;

@end

@protocol MSDismissable <NSObject>

- (IBAction)dismiss:(id)sender;

@end

@protocol MSCaching <NSObject>

@property BOOL shouldUseCache;

- (void)emptyCache;


@end

@protocol MSResettable <NSObject>

- (void)resetToInitialState;

@end

@class MSDictionary;

@protocol MSJSONExport <NSObject>

@property (nonatomic, weak, readonly) id         JSONObject;
@property (nonatomic, weak, readonly) NSString * JSONString;

@optional
@property (nonatomic, weak, readonly) MSDictionary * JSONDictionary;

@end

