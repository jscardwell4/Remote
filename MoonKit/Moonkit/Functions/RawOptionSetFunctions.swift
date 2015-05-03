//
//  RawOptionSetFunctions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/**
setOption:s:

:param: o T The option
:param: s T The option set
*/
public func setOption<T:RawOptionSetType>(o: T, inout s: T) { s |= o }

/**
unsetOption:s:

:param: o T The option
:param: s T The option set
*/
public func unsetOption<T:RawOptionSetType>(o: T, inout s: T) { s &= ~o }

/**
isOption:s:

:param: o T The option
:param: s T The option set

:returns: Bool
*/
public func hasOption<T:RawOptionSetType>(o: T, s: T) -> Bool { return o & s != nil }

/**
toggleOption:s:

:param: o T The option
:param: s T The option set
*/
public func toggleOption<T:RawOptionSetType>(o: T, inout s: T) {
  if hasOption(o, s) { unsetOption(o, &s) } else { setOption(o, &s) }
}


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs | rhs }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs & ~rhs }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }
