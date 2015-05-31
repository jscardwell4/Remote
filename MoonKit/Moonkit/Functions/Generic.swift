//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation


public func ~=<T:Equatable>(lhs: T?, rhs: T?) -> Bool {
  if let l = lhs, r = rhs where l ~= r { return true }
  else if lhs == nil && rhs == nil { return true }
  else { return false }
}

public func typeCast<T,U>(t: T, u: U.Type) -> U? { return t as? U }
public func typeCast<T,U>(t: T?, u: U.Type) -> U? { return t != nil ? typeCast(t!, u) : nil }

public func **<T:IntegerArithmeticType>(lhs: T, rhs: T) -> T {
  return reduce(1..<rhs.toIntMax(), lhs, {n, _ in n * lhs})
}

public func **(lhs: Float, rhs: Int) -> Float {
  return reduce(0..<rhs, Float(0.0), {n, _ in n * lhs})
}

public func **(lhs: Double, rhs: Int) -> Double {
  return reduce(0..<rhs, 0.0, {n, _ in n * lhs})
}

public func **(lhs: CGFloat, rhs: Int) -> CGFloat {
  return reduce(0..<rhs, CGFloat(0.0), {n, _ in n * lhs})
}

public func sum<S:SequenceType where S.Generator.Element == CGFloat>(s: S) -> CGFloat {
  return reduce(s, CGFloat(), {$0 + $1})
}

public func sum<S:SequenceType where S.Generator.Element == Float>(s: S) -> Float {
  return reduce(s, Float(), {$0 + $1})
}

public func sum<S:SequenceType where S.Generator.Element == Double>(s: S) -> Double {
  return reduce(s, 0.0, {$0 + $1})
}

public func sum<S:SequenceType where S.Generator.Element:IntegerArithmeticType>(s: S) -> IntMax {
  return reduce(s, 0, {$0 + $1.toIntMax()})
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
findFirst:predicate:

:param: domain S
:param: predicate (S.Generator.Element) -> Bool

:returns: (C.Generator.Element)?
*/
public func findFirst<S: SequenceType>(domain: S?, predicate: (S.Generator.Element) -> Bool) -> (S.Generator.Element)? {
  if let sequence = domain { for element in sequence { if predicate(element) { return element } } }
  return nil
}

/**
length:

:param: interval ClosedInterval<T>

:returns: T.Stride
*/
public func length<T:Strideable>(interval: ClosedInterval<T>) -> T.Stride { return interval.start.distanceTo(interval.end) }


/**
toString:

:param: x T?

:returns: String
*/
public func toString<T>(x: T?) -> String { if let xx = x { return toString(xx) } else { return "nil" } }


public func +(lhs: Range<Int>, rhs: Int) -> Range<Int> { return lhs.startIndex + rhs ..< lhs.endIndex + rhs }


/**
The Box class is used to box values and as a workaround to the limitations with generics in the compiler. 
From "Functional Programming in Swift", www.objc.io
*/
public class Box<T> { public let unbox: T; public init(_ value: T) { unbox = value } }


