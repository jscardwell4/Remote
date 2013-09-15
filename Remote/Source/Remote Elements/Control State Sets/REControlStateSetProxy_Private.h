//
//  ControlStateSetProxy_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ControlStateSetProxy.h"

@interface ControlStateSetProxy () {
    __weak id<ControlStateSetProxyDelegate> _delegate;
}

@property (nonatomic, strong) ControlStateSet * proxiedObject;

@end

@interface ControlStateTitleSetProxy ()

//@property (nonatomic, strong) ControlStateTitleSet * proxiedObject;

- (ControlStateTitleSet *)proxiedObject;

@end

@interface ControlStateColorSetProxy ()

//@property (nonatomic, strong) ControlStateColorSet * proxiedObject;
- (ControlStateColorSet *)proxiedObject;

@end

#import "ControlStateSet.h"
