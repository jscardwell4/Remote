//
//  SequenceManipulation.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public struct InfiniteSequenceOf<T>: SequenceType {
  private let value: T
  public init(_ v: T) { value = v }
  public func generate() -> GeneratorOf<T> { return GeneratorOf<T>({self.value}) }
}

public func zip<S:SequenceType, T>(seq: S, value: T) -> [(S.Generator.Element, T)] {
  return Array(zip(seq, InfiniteSequenceOf(value)))
}

/**
sequence:T):

:param: v (T
:param: T)

:returns: SequenceOf<T>
*/
public func sequence<T>(v: (T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1]) }

/**
sequence:T:T):

:param: v (T
:param: T
:param: T)

:returns: SequenceOf<T>
*/
public func sequence<T>(v: (T,T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1, v.2]) }

/**
sequence:T:T:T):

:param: v (T
:param: T
:param: T
:param: T)

:returns: SequenceOf<T>
*/
public func sequence<T>(v: (T,T,T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1, v.2, v.3]) }

/**
disperse2:

:param: s S

:returns: (T, T)
*/
public func disperse2<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T) {
  let array = Array(s)
  return (array[0], array[1])
}

/**
disperse3:

:param: s S

:returns: (T, T, T)
*/
public func disperse3<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T, T) {
  let array = Array(s)
  return (array[0], array[1], array[2])
}

/**
disperse4:

:param: s S

:returns: (T, T, T, T)
*/
public func disperse4<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T, T, T) {
  let array = Array(s)
  return (array[0], array[1], array[2], array[3])
}

/**
Zip together two sequences as an array of tuples formed via cross product

:param: s1 S1
:param: s2 S2

:returns: [(S1.Generator.Element, S2.Generator.Element)]
*/
public func crossZip<S1:SequenceType, S2:SequenceType>(s1: S1, s2: S2) -> [(S1.Generator.Element, S2.Generator.Element)] {
  var result: [(S1.Generator.Element, S2.Generator.Element)] = []
  for outter in s1 {
    for inner in s2 {
      result.append((outter, inner))
    }
  }
  return result
}

/**
unzip:S1>:

:param: z Zip2<S0
:param: S1>

:returns: ([E0], [E1])
*/
public func unzip<S0:SequenceType, S1:SequenceType, E0, E1 where E0 == S0.Generator.Element, E1 == S1.Generator.Element>(z: Zip2<S0, S1>) -> ([E0], [E1]) {
  return reduce(z, ([], []), { (var result: ([E0], [E1]), p: (E0, E1)) -> ([E0], [E1]) in
    result.0.append(p.0)
    result.1.append(p.1)
    return result
  })
}

/**
unzip:

:param: s S

:returns: ([E0], [E1])
*/
public func unzip<E0, E1, S:SequenceType where S.Generator.Element == (E0, E1)>(s: S) -> ([E0], [E1]) {
  return reduce(s, ([], []), { (var result: ([E0], [E1]), p: (E0, E1)) -> ([E0], [E1]) in
    result.0.append(p.0)
    result.1.append(p.1)
    return result
  })
}

public func collect<T where T:GeneratorType>(var generator: T) -> [T.Element] {
  var result: [T.Element] = []
  var done = false
  while !done { if let e = generator.next() { result += [e] } else { done = true } }
  return result
}

public func collectFrom<C:CollectionType, S:SequenceType where C.Index == S.Generator.Element>(source: C, indexes: S)
  -> [C.Generator.Element]
{
  var result: [C.Generator.Element] = []
  for idx in indexes { result.append(source[idx]) }
  return result
}


