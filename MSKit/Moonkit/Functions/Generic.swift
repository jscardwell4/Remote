//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public func advance<T: ForwardIndexType>(inout range: Range<T>, amount: T.Distance) {
  let d = distance(range.startIndex, range.endIndex)
  let start: T = advance(range.startIndex, amount)
  let end: T = advance(range.startIndex, amount + d)
  range = Range<T>(start: start, end: end)
}


public func advance<T: ForwardIndexType>(range: Range<T>, amount: T.Distance) -> Range<T> {
  return Range<T>(start: advance(range.startIndex, amount), end: advance(range.endIndex, amount))
}

prefix operator ∀⦱ {}

postfix operator ‽ {}

public postfix func ‽<T>(lhs: [Optional<T>]) -> [T] { return lhs.filter{$0 != nil}.map{$0!} }

public func compressed<T>(array:[Optional<T>]) -> [T] { return array.filter{$0 != nil}.map{$0!} }

public func flattened<T>(array:[[T]]) -> [T] { var a: [T] = []; for s in array { a += s}; return a }

/**
The function is a simple wrapper around `reduce` that ignores the actual reduction as a way to visit every element

:param: sequence S
:param: block (S.Generator.Element) -> Void
*/
public func apply<S:SequenceType>(sequence: S, block: (S.Generator.Element) -> Void) { reduce(sequence, Void()){block($0.1)} }

/**
unique<T:Equatable>:

:param: array [T]

:returns: [T]
*/
public func unique<T:Equatable>(array:[T]) -> [T] {
  var u: [T] = []
  for e in array { if e ∉ u { u.append(e) } }
  return u
}

/**
unique<T:Equatable>:

:param: array [T]
*/
public func unique<T:Equatable>(inout array:[T]) { array = unique(array) }

infix operator ⩢ {}
infix operator ∈ 	{  // element of
associativity none
precedence 130
}
infix operator ∉ 	{  // not an element of
associativity none
precedence 130
}
infix operator ∋ 	{  // has as member
associativity none
precedence 130
}
infix operator ∌ 	{  // does not have as member
associativity none
precedence 130
}
infix operator ∖ 	{  // minus
associativity none
precedence 130
}
infix operator ∪ 	{  // union
associativity none
precedence 130
}
infix operator ∩ 	{  // intersection
associativity none
precedence 130
}
infix operator ∖= 	{  // minus equals
associativity right
precedence 90
}
infix operator ∪= 	{  // union equals
associativity right
precedence 90
assignment
}
infix operator ∩= 	{  // intersection equals
associativity right
precedence 90
assignment
}
infix operator ⊂ 	{  // subset of
associativity none
precedence 130
}
infix operator ⊄ 	{  // not a subset of
associativity none
precedence 130
}
infix operator ⊃ 	{  // superset of
associativity none
precedence 130
}
infix operator ⊅ 	{  // not a superset of
associativity none
precedence 130
}
postfix operator ⭆ {}

infix operator ⥢ {
associativity right
precedence 90
}
prefix operator ⇇ {}

/**
Prefix operator that extracts the first two elements of an array and returns as a tuple

:param: array [T]
:returns: (T, T)
*/
public prefix func ⇇<T>(array:[T]) -> (T, T) { return (array[0], array[1]) }

/**
Function for extracting first two elements of rhs into lhs

:param: lhs (T, T)
:param: rhs [T]
*/
public func ⥢<T>(inout lhs:(T, T), rhs:[T]) { lhs = (rhs[0], rhs[1]) }

/**
Union set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∪<T>(lhs:[T], rhs:[T]) -> [T] { var u = lhs; u += rhs; return u }

/**
Minus set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∖<T:Equatable>(lhs:[T], rhs:[T]) -> [T] { return lhs.filter { $0 ∉ rhs } }

/**
Intersection set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∩<T:Equatable>(lhs:[T], rhs:[T]) -> [T] { return unique(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }

/**
Union set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∪=<T>(inout lhs:[T], rhs:[T]) -> [T] { lhs += rhs; return lhs }

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
public func ∩=<T:Equatable>(inout lhs:[T], rhs:[T]) { lhs = unique(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }

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

/**
Postfix operator that turns a generator into its generated array

:param: generator T
:returns: [T.Element]
*/
public postfix func ⭆<T where T:GeneratorType>(var generator: T) -> [T.Element] {
  var result: [T.Element] = []
  var done = false
  while !done { if let e = generator.next() { result += [e] } else { done = true } }
  return result
}

public func collect<T where T:GeneratorType>(generator: T) -> [T.Element] {
  return generator⭆
}

public func collectFrom<C:CollectionType, S:SequenceType where C.Index == S.Generator.Element>(source: C, indexes: S) -> [C.Generator.Element] {
  var result: [C.Generator.Element] = []
  for idx in indexes { result.append(source[idx]) }
  return result
}

/**
Returns true if rhs is equal to lhs or if rhs is nil

:param: lhs T
:param: rhs T!
:returns: Bool
*/
public func ⩢ <T:Equatable>(lhs: T, rhs: T!) -> Bool { return rhs == nil || lhs == rhs }

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∈<T:Equatable>(lhs:T, rhs:[T]) -> Bool { return contains(rhs, lhs) }
public func ∈ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return rhs.contains(lhs) }

/**
Returns true if lhs contains rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∋<T:Equatable>(lhs:[T], rhs:T) -> Bool { return rhs ∈ lhs }
public func ∋ <T, U where U:IntervalType, T == U.Bound>(lhs:U, rhs:T) -> Bool { return lhs.contains(rhs) }

/**
Returns true if rhs does not contain lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∉<T:Equatable>(lhs:T, rhs:[T]) -> Bool { return !(lhs ∈ rhs) }
public func ∉ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return !(lhs ∈ rhs) }

/**
Returns true if lhs does not contain rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∌ <T, U:IntervalType where T == U.Bound>(lhs:U, rhs:T) -> Bool { return !(lhs ∋ rhs) }
public func ∌<T:Equatable>(lhs:[T], rhs:T) -> Bool { return !(lhs ∋ rhs) }

