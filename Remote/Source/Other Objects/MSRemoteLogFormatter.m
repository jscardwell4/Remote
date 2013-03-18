//
// RemoteLogFormatter.m
// Remote
//
// Created by Jason Cardwell on 3/22/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSRemoteLogFormatter.h"

@interface MSRemoteLogFileManager ()
@property (nonatomic, copy, readwrite) NSString * currentLogFile;
@end

@implementation MSRemoteLogFileManager

- (NSString *)createNewLogFile {
    self.currentLogFile = [super createNewLogFile];

    return _currentLogFile;
}

- (void)didRollAndArchiveLogFile:(NSString *)logFilePath {}

@end

#define SURROUNDING_NEWLINES NO

@interface MSRemoteLogFormatter ()

- (NSString *)formattedLogMessageForMessage:(DDLogMessage *)logMessage;

@end

@implementation MSRemoteLogFormatter {
    NSUInteger   _context;
}

+ (MSRemoteLogFormatter *)remoteLogFormatterForContext:(NSUInteger)context {
    return [[MSRemoteLogFormatter alloc] initWithContext:context];
}

- (id)initWithContext:(NSUInteger)context {
    if ((self = [super init])) {
        _context           = context;
        _includeLogLevel   = YES;
        _indentMessageBody = YES;
    }

    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return ((  (logMessage->logContext & _context)
            || (  !logMessage->logContext
               && (  (_context & TTY_LOG_CONTEXT)
                  || (_context & ASL_LOG_CONTEXT))))
            ?[self formattedLogMessageForMessage:logMessage]
            : nil);
}

- (NSString *)formattedLogMessageForMessage:(DDLogMessage *)logMessage {
    NSMutableString * formattedLogMessage = [@"" mutableCopy];

    if (_includeLogLevel) {
        NSString * logLevel = nil;

        switch (logMessage->logFlag) {
            case LOG_FLAG_ERROR :    logLevel                                     = @"E"; break;
            case LOG_FLAG_WARN :     logLevel                                     = @"W"; break;
            case LOG_FLAG_INFO :     logLevel                                     = @"I"; break;
            case LOG_FLAG_DEBUG :    logLevel                                     = @"D"; break;
            case LOG_FLAG_SELECTOR : logLevel                                     = @"S"; break;
            case LOG_FLAG_VERBOSE :  logLevel                                     = @"V"; break;
            default :                                                    logLevel = @"?"; break;
        }  /* switch */
        [formattedLogMessage appendFormat:@"[%@", logLevel];
    }

    if (_includeTimestamp) {
        NSDateFormatter * df = [NSDateFormatter new];

        df.dateFormat = @"M/d/yy h:mm a";
        [formattedLogMessage appendFormat:@"(%@)", [df stringFromDate:logMessage->timestamp]];
    }

    if (_includeLogLevel) [formattedLogMessage appendString:@"]"];

    if (_addReturnAfterPrefix && formattedLogMessage.length > 0) [formattedLogMessage appendString:@"\n"];

    NSString * message = [logMessage->logMsg stringByUnescapingControlCharacters];

    if (_indentMessageBody) message = [message stringByReplacingOccurrencesOfRegEx:@"\n" withString:@"\n\t"];

    [formattedLogMessage appendString:message];

    if (_addReturnAfterMessage) [formattedLogMessage appendString:@"\n"];

    return formattedLogMessage;
}

@end
