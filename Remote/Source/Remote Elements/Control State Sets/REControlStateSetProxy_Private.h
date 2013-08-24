//
//  REControlStateSetProxy_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REControlStateSetProxy.h"

@interface REControlStateSetProxy () {
    __weak id<REControlStateSetProxyDelegate> _delegate;
}

@property (nonatomic, strong) REControlStateSet * proxiedObject;

@end

@interface REControlStateTitleSetProxy ()

//@property (nonatomic, strong) REControlStateTitleSet * proxiedObject;

- (REControlStateTitleSet *)proxiedObject;

@end

@interface REControlStateColorSetProxy ()

//@property (nonatomic, strong) REControlStateColorSet * proxiedObject;
- (REControlStateColorSet *)proxiedObject;

@end

#import "REControlStateSet.h"
