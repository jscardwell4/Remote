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

- parameter option: T The option
- parameter optionSet: T The option set
*/
public func setOption<T:RawOptionSetType>(option: T, inout optionSet: T) { optionSet |= option }

/**
unsetOption:optionSet:

- parameter option: T The option
- parameter optionSet: T The option set
*/
public func unsetOption<T:RawOptionSetType>(option: T, inout optionSet: T) { optionSet &= ~option }

/**
isOption:optionSet:

- parameter option: T The option
- parameter optionSet: T The option set

- returns: Bool
*/
public func hasOption<T:RawOptionSetType>(option: T, optionSet: T) -> Bool { return optionSet & option == option }

/**
toggleOption:optionSet:

- parameter option: T The option
- parameter optionSet: T The option set
*/
public func toggleOption<T:RawOptionSetType>(option: T, inout optionSet: T) {
  if hasOption(option, optionSet: optionSet) { unsetOption(option, optionSet: &optionSet) } else { setOption(option, optionSet: &optionSet) }
}


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs | rhs }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return lhs & ~rhs }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }
