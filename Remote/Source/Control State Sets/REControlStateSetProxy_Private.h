//
//  REControlStateSetProxy_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REControlStateSetProxy.h"

@interface REControlStateSetProxy (AbstractProperties)

@property (nonatomic, strong) REControlStateSet * proxiedObject;

@end

@interface REControlStateSetProxy () {
    __weak id<REControlStateSetProxyDelegate> _delegate;
}

@end

@interface REControlStateTitleSetProxy ()

@property (nonatomic, strong) REControlStateTitleSet * proxiedObject;

@end

@interface REControlStateIconImageSetProxy ()

@property (nonatomic, strong) REControlStateIconImageSet * proxiedObject;

@end

@interface REControlStateColorSetProxy ()

@property (nonatomic, strong) REControlStateColorSet * proxiedObject;

@end

@interface REControlStateButtonImageSetProxy ()

@property (nonatomic, strong) REControlStateButtonImageSet * proxiedObject;

@end

#import "REControlStateSet.h"
