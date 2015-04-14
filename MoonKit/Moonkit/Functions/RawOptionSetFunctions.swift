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

:param: o T
:param: s T

:returns: T
*/
public func setOption<T:RawOptionSetType>(o: T, s: T) -> T { return o | s }

/**
unsetOption:s:

:param: o T
:param: s T

:returns: T
*/
public func unsetOption<T:RawOptionSetType>(o: T, s: T) -> T { return s & ~o }

/**
isOptionSet:s:

:param: o T
:param: s T

:returns: Bool
*/
public func isOptionSet<T:RawOptionSetType>(o: T, s: T) -> Bool { return o & s != nil }

/**
toggleOption:s:

:param: o T
:param: s T

:returns: T
*/
public func toggleOption<T:RawOptionSetType>(o: T, s: T) -> T {
  return isOptionSet(o, s) ? unsetOption(o, s) : setOption(o, s)
}


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return setOption(rhs, lhs) }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return unsetOption(rhs, lhs) }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }
