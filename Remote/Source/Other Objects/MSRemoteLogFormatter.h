//
// MSRemoteLogFormatter.h
// Remote
//
// Created by Jason Cardwell on 3/22/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface MSRemoteLogFileManager : DDLogFileManagerDefault
@property (nonatomic, copy, readonly) NSString * currentLogFile;
@end

@interface MSRemoteLogFormatter : NSObject <DDLogFormatter>

+ (MSRemoteLogFormatter *)remoteLogFormatterForContext:(NSUInteger)context;

- (id)initWithContext:(NSUInteger)context;

@property (nonatomic, assign, getter = shouldIncludeLogLevel)       BOOL   includeLogLevel;
@property (nonatomic, assign, getter = shouldIncludeTimestamp)      BOOL   includeTimestamp;
@property (nonatomic, assign, getter = shouldAddReturnAfterPrefix)  BOOL   addReturnAfterPrefix;
@property (nonatomic, assign, getter = shouldAddReturnAfterMessage) BOOL   addReturnAfterMessage;
@property (nonatomic, assign, getter = shouldIndentMessageBody)     BOOL   indentMessageBody;

@end
