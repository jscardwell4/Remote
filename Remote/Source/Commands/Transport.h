//
// Transport.h
// Remote
//
// Created by Jason Cardwell on 6/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSet.h"

MSKIT_EXTERN_STRING   kTransportRewindButtonKey;
MSKIT_EXTERN_STRING   kTransportRecordButtonKey;
MSKIT_EXTERN_STRING   kTransportNextButtonKey;
MSKIT_EXTERN_STRING   kTransportStopButtonKey;
MSKIT_EXTERN_STRING   kTransportFastForwardButtonKey;
MSKIT_EXTERN_STRING   kTransportPreviousButtonKey;
MSKIT_EXTERN_STRING   kTransportPauseButtonKey;
MSKIT_EXTERN_STRING   kTransportPlayButtonKey;

typedef NS_ENUM (NSInteger, TransportButtonTag) {
    TransportRewindButtonTag      = 0,
    TransportRecordButtonTag      = 1,
    TransportNextButtonTag        = 2,
    TransportStopButtonTag        = 3,
    TransportFastForwardButtonTag = 4,
    TransportPreviousButtonTag    = 5,
    TransportPauseButtonTag       = 6,
    TransportPlayButtonTag        = 7
};

@interface Transport : CommandSet {
    @private
}
@property (nonatomic, strong) NSURL * rewind;
@property (nonatomic, strong) NSURL * record;
@property (nonatomic, strong) NSURL * next;
@property (nonatomic, strong) NSURL * stop;
@property (nonatomic, strong) NSURL * fastForward;
@property (nonatomic, strong) NSURL * previous;
@property (nonatomic, strong) NSURL * pause;
@property (nonatomic, strong) NSURL * play;

+ (Transport *)newTransportInContext:(NSManagedObjectContext *)context;

@end
