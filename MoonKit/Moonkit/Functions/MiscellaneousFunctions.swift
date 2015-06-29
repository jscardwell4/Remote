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

- returns: String
*/
public func nonce() -> String { return NSUUID().UUIDString }

/**
dispatchToMain:block:

- parameter synchronous: Bool = false
- parameter block: dispatch_block_t
*/
public func dispatchToMain(synchronous: Bool = false, _ block: dispatch_block_t) {
  if NSThread.isMainThread() { block() }
  else if synchronous { dispatch_sync(dispatch_get_main_queue(), block) }
  else { dispatch_async(dispatch_get_main_queue(), block) }
}

/**
delayedDispatchToMain:block:

- parameter delay: Int
- parameter block: dispatch_block_t
*/
public func delayedDispatchToMain(delay: Double, _ block: dispatch_block_t) {
  dispatch_after(
    dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
    dispatch_get_main_queue(),
    block
  )
}

/**
append:toIdentifier:

- parameter s: String
- parameter identifier: String

- returns: String
*/
public func append(s: String, toIdentifier identifier: String) -> String { return "-".join(s, identifier) }

/**
createIdentifierGenerator:suffixes:

- parameter base: String
- parameter suffixes: String...

- returns: String
*/
public func createIdentifierGenerator(base: String)(_ suffixes: String...) -> String {
  return "-".join([base] + suffixes)
}

/**
createIdentifier:suffix:

- parameter object: Any
- parameter suffix: String? = nil

- returns: String
*/
public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

/**
createIdentifier:suffix:

- parameter object: Any
- parameter suffix: String...

- returns: String
*/
public func createIdentifier(object: Any, _ suffix: String...) -> String {
  return _stdlib_getDemangledTypeName(object) + "-" + "-".join(suffix)
}

/**
createIdentifier:suffix:

- parameter object: Any
- parameter suffix: [String]? = nil

- returns: String
*/
public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}

/**
tagsFromIdentifier:

- parameter identifier: String

- returns: [String]
*/
public func tagsFromIdentifier(identifier: String) -> [String] { return "-".split(identifier) }

