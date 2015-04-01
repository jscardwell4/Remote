//
//  Array+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension NSArray: JSONExport {
  public var JSONString: String { return JSONSerialization.JSONFromObject(JSONObject) ?? "" }
  public var JSONObject: AnyObject { return self }
}

/**
flattened:

:param: array [[T]]

:returns: [T]
*/
public func flattened<T>(array:[[T]]) -> [T] { var a: [T] = []; for s in array { a += s}; return a }
public prefix func ∪<T>(array: [[T]]) -> [T] { return flattened(array) }

public prefix func ‽∪<T>(array:[Optional<[T]>]) -> [T] { return flattened(compressed(array)) }

/**
compressed:

:param: array [Optional<T>]

:returns: [T]
*/
public func compressed<T>(array: [Optional<T>]) -> [T] { return array.filter{$0 != nil}.map{$0!} }
public prefix func ‽<T>(array: [Optional<T>]) -> [T] { return compressed(array) }
public postfix func ‽<T>(array: [Optional<T>]) -> [T] { return compressed(array) }

/** unpacking an array into a tuple */
public func disperse2<T>(v: [T]) -> (T,T) { return (v[0], v[1]) }
public func disperse3<T>(v: [T]) -> (T,T,T) { return (v[0], v[1], v[2]) }
public func disperse4<T>(v: [T]) -> (T,T,T,T) { return (v[0], v[1], v[2], v[3]) }

/**
unique<T:Equatable>:

:param: array [T]
*/
public func unique<T:Equatable>(inout array:[T]) { array = uniqued(array) }

/**
Union set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
*/
public func ∪=<T>(inout lhs:[T], rhs:[T]) { lhs += rhs }

/**
Minus set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∖=<T:Equatable>(inout lhs:[T], rhs:[T]) -> [T] { lhs = lhs.filter { $0 ∉ rhs }; return lhs }

/**
Intersection set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∩=<T:Equatable>(inout lhs:[T], rhs:[T]) { lhs = uniqued(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }

/**
Returns true if lhs is a subset of rhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊂<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }

/**
Returns true if lhs is not a subset of rhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊄<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊂ rhs) }

/**
Returns true if rhs is a subset of lhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊃<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return rhs ⊂ lhs }

/**
Returns true if rhs is not a subset of lhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊅<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊃ rhs) }
