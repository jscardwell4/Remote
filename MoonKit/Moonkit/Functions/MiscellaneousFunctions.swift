//
//  MiscellaneousFunctions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/8/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/**
nonce

:returns: String
*/
public func nonce() -> String { return NSUUID().UUIDString }

/**
dispatchToMain:block:

:param: synchronous Bool = false
:param: block dispatch_block_t
*/
public func dispatchToMain(synchronous: Bool = false, block: dispatch_block_t) {
  if NSThread.isMainThread() { block() }
  else if synchronous { dispatch_sync(dispatch_get_main_queue(), block) }
  else { dispatch_async(dispatch_get_main_queue(), block) }
}

/**
delayedDispatchToMain:block:

:param: delay Int
:param: block dispatch_block_t
*/
public func delayedDispatchToMain(delay: Int, block: dispatch_block_t) {
  dispatch_after(
    dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delay) * NSEC_PER_MSEC)),
    dispatch_get_main_queue(),
    block
  )
}