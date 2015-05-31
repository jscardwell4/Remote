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
public func delayedDispatchToMain(delay: Double, block: dispatch_block_t) {
  dispatch_after(
    dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
    dispatch_get_main_queue(),
    block
  )
}

/**
append:toIdentifier:

:param: s String
:param: identifier String

:returns: String
*/
public func append(s: String, toIdentifier identifier: String) -> String { return "-".join(s, identifier) }

/**
createIdentifierGenerator:suffixes:

:param: base String
:param: suffixes String...

:returns: String
*/
public func createIdentifierGenerator(base: String)(suffixes: String...) -> String {
  return "-".join([base] + suffixes)
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix String? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix String...

:returns: String
*/
public func createIdentifier(object: Any, suffix: String...) -> String {
  return _stdlib_getDemangledTypeName(object) + "-" + "-".join(suffix)
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix [String]? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}

/**
tagsFromIdentifier:

:param: identifier String

:returns: [String]
*/
public func tagsFromIdentifier(identifier: String) -> [String] { return "-".split(identifier) }

