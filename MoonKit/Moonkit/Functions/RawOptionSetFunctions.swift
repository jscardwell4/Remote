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

:param: option T The option
:param: optionSet T The option set
*/
public func setOption<T:RawOptionSetType>(option: T, inout optionSet: T) { optionSet |= option }

/**
unsetOption:optionSet:

:param: option T The option
:param: optionSet T The option set
*/
public func unsetOption<T:RawOptionSetType>(option: T, inout optionSet: T) { optionSet &= ~option }

/**
isOption:optionSet:

:param: option T The option
:param: optionSet T The option set

:returns: Bool
*/
public func hasOption<T:RawOptionSetType>(option: T, optionSet: T) -> Bool { return optionSet & option == option }

/**
toggleOption:optionSet:

:param: option T The option
:param: optionSet T The option set
*/
public func toggleOption<T:RawOptionSetType>(option: T, inout optionSet: T) {
  if hasOption(option, optionSet) { unsetOption(option, &optionSet) } else { setOption(option, &optionSet) }
}


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs | rhs }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs & ~rhs }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }
