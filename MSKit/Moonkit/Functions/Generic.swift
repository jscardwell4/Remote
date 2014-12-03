//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

@inline(__always) prefix func ⩨ <T : _UnsignedIntegerType, U: _SignedIntegerType>   (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _SignedIntegerType,   U: _UnsignedIntegerType> (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _UnsignedIntegerType, U: _UnsignedIntegerType> (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _SignedIntegerType,   U: _SignedIntegerType>   (x: T) -> U { return numericCast(x) }

public func map<K,V,U>(dict: [K:V], block: (K, V) -> U) -> [K:U] {
  var result: [K:U] = [:]
  for (key, value) in dict { result[key] = block(key, value) }
  return result
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
:param: suffix [String]? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}


/**
advance:amount:

:param: range Range<T>
:param: amount T.Distance
*/
public func advance<T: ForwardIndexType>(inout range: Range<T>, amount: T.Distance) {
  let d = distance(range.startIndex, range.endIndex)
  let start: T = advance(range.startIndex, amount)
  let end: T = advance(range.startIndex, amount + d)
  range = Range<T>(start: start, end: end)
}

/**
join:elements:

:param: seperator T
:param: elements [T]

:returns: [T]
*/
public func join<T>(seperator: T, elements: [T]) -> [T] {
  if elements.count > 1 {
    var joinedElements: [T] = []
    for element in elements[0..<(elements.count - 1)] {
      joinedElements.append(element)
      joinedElements.append(seperator)
    }
    joinedElements.append(elements.last!)
    return joinedElements
  } else {
    return elements
  }
}

/**
function for recursively reducing a property of an element that contains child elements of its kind

:param: initial U The initial value for the reduction
:param: subitems (T) -> [T] Closure for producing child elements of the item
:param: combine (U, T) -> Closure for producing the reduction for the item without recursing
:param: item T The initial item

:returns: U The result of the reduction
*/
public func recursiveReduce<T, U>(initial: U, subitems: (T) -> [T], combine: (U, T) -> U, item: T) -> U {
  var body: ((U, (T) -> [T], (U,T) -> U, T) -> U)!
  body = { (i: U, s: (T) -> [T], c: (U,T) -> U, x: T) -> U in reduce(s(x), c(i, x)){body($0.0, s, c, $0.1)} }
  return body(initial, subitems, combine, item)
}

/**
advance:amount:

:param: range Range<T>
:param: amount T.Distance

:returns: Range<T>
*/
public func advance<T: ForwardIndexType>(range: Range<T>, amount: T.Distance) -> Range<T> {
  return Range<T>(start: advance(range.startIndex, amount), end: advance(range.endIndex, amount))
}

/**
find:value:

:param: domain C
:param: value C.Generator.Element?

:returns: C.Index?
*/
public func find<C: CollectionType where C.Generator.Element: Equatable>(domain: C, value: C.Generator.Element?) -> C.Index? {
  if let v = value { return find(domain, v) } else { return nil }
}

/**
length:

:param: interval ClosedInterval<T>

:returns: T.Stride
*/
public func length<T:Strideable>(interval: ClosedInterval<T>) -> T.Stride { return interval.start.distanceTo(interval.end) }

public postfix func ‽<T>(lhs: [Optional<T>]) -> [T] { return lhs.filter{$0 != nil}.map{$0!} }

/**
compressed:

:param: array [Optional<T>]

:returns: [T]
*/
public func compressed<T>(array: [Optional<T>]) -> [T] { return array.filter{$0 != nil}.map{$0!} }
public prefix func ‽<T>(array: [Optional<T>]) -> [T] { return compressed(array) }

/**
flattened:

:param: array [[T]]

:returns: [T]
*/
public func flattened<T>(array:[[T]]) -> [T] { var a: [T] = []; for s in array { a += s}; return a }
public prefix func ∪<T>(array: [[T]]) -> [T] { return flattened(array) }

public prefix func ‽∪<T>(array:[Optional<[T]>]) -> [T] { return flattened(compressed(array)) }

/**
spliced:newElements:atIndex:

:param: x C
:param: newElements S
:param: i C.Index

:returns: C
*/
public func spliced<C : RangeReplaceableCollectionType, S : CollectionType
                   where C.Generator.Element == S.Generator.Element>(x: C, newElements: S, atIndex i: C.Index) -> C
{
  var xPrime = x
  splice(&xPrime, newElements, atIndex: i)
  return xPrime
}

public func removedAtIndex<C : RangeReplaceableCollectionType>(x: C, index: C.Index) -> C {
  var xPrime = x
  removeAtIndex(&xPrime, index)
  return xPrime
}


/**
The function is a simple wrapper around `reduce` that ignores the actual reduction as a way to visit every element

:param: sequence S
:param: block (S.Generator.Element) -> Void
*/
public func apply<S:SequenceType>(sequence: S, block: (S.Generator.Element) -> Void) { reduce(sequence, Void()){block($0.1)} }

/**
unique<T:Equatable>:

:param: seq S

:returns: [T]
*/
public func uniqued<S:SequenceType where S.Generator.Element:Equatable>(seq:S) -> [S.Generator.Element] {
  var u: [S.Generator.Element] = []
  for e in seq { if e ∉ u { u.append(e) } }
  return u
}

/**
unique<T:Equatable>:

:param: array [T]
*/
public func unique<T:Equatable>(inout array:[T]) { array = uniqued(array) }


/**
Returns true if `lhs` is nil or `rhs` evaluates to true

:param: lhs Optional<T>
:param: rhs @autoclosure () -> Bool

:returns: Bool
*/
public func ∅||<T>(lhs: Optional<T>, rhs: @autoclosure () -> Bool) -> Bool {
  return lhs == nil || rhs()
}


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
public func ∪<T, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  var u = Array(lhs)
  u += Array(rhs)
  return u
}

/**
Minus set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∖<T:Equatable, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  return filter(lhs) { $0 ∉ rhs }
}

/**
Intersection set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∩<T:Equatable, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  return filter(uniqued(lhs ∪ rhs)) {$0 ∈ lhs && $0 ∈ rhs}
}

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

public func collectFrom<C:CollectionType, S:SequenceType where C.Index == S.Generator.Element>(source: C, indexes: S)
  -> [C.Generator.Element]
{
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
:param: rhs S
:returns: Bool
*/
public func ∈<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T, rhs:S) -> Bool {
  return contains(rhs, lhs)
}

/**
Returns true if rhs contains lhs

:param: lhs T?
:param: rhs S
:returns: Bool
*/
public func ∈<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T?, rhs:S) -> Bool {
  return lhs != nil && contains(rhs, lhs!)
}

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs U
:returns: Bool
*/
public func ∈ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return rhs.contains(lhs) }

/**
Returns true if lhs contains rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∋<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:S, rhs:T) -> Bool { return rhs ∈ lhs }
public func ∋ <T, U where U:IntervalType, T == U.Bound>(lhs:U, rhs:T) -> Bool { return lhs.contains(rhs) }

/**
Returns true if rhs does not contain lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∉<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T, rhs:S) -> Bool { return !(lhs ∈ rhs) }
public func ∉ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return !(lhs ∈ rhs) }

/**
Returns true if lhs does not contain rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∌ <T, U:IntervalType where T == U.Bound>(lhs:U, rhs:T) -> Bool { return !(lhs ∋ rhs) }
public func ∌<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:S, rhs:T) -> Bool { return !(lhs ∋ rhs) }

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
public func toggleOption<T:RawOptionSetType>(o: T, s: T) -> T { return isOptionSet(o, s) ? unsetOption(o, s) : setOption(o, s) }


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return setOption(rhs, lhs) }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return unsetOption(rhs, lhs) }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }
